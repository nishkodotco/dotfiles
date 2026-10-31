"""Generate a Windows keybindings.json from the Mac one.

Mapping: Mac Cmd -> Win Ctrl, Mac Ctrl -> Win Alt, Mac Cmd+Ctrl -> Win Ctrl+Alt,
Mac Alt -> Win Alt (if Alt is already used by the Mac Ctrl mapping, add Shift).
Clashes between two active rules on the same key are reported and resolved.
"""
import re, json, sys, collections
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
src = sys.argv[1] if len(sys.argv) > 1 else str(ROOT / 'editors/Code/keybindings.json')
dst = sys.argv[2] if len(sys.argv) > 2 else str(ROOT / 'editors/Code/keybindings.windows.json')
report = sys.argv[3] if len(sys.argv) > 3 else '/dev/stdout'
s = open(src).read()
t = re.sub(r'(?m)^\s*//.*$', '', s)
t = re.sub(r'\}\s*,\s*//[^\n]*', '},', t)
t = re.sub(r',(\s*[\]\}])', r'\1', t)
kb = json.loads(t)

ORDER = ['ctrl', 'shift', 'alt']

def map_chord(chord):
    parts = chord.split('+')
    keyname, m = parts[-1], set(parts[:-1])
    out = set()
    if 'cmd' in m:
        out.add('ctrl')
    if 'ctrl' in m:
        out.add('alt')  # Mac Ctrl -> Win Alt
    if 'alt' in m:
        if 'alt' in out:
            out.add('shift') if 'shift' not in m else None
        out.add('alt')
    if 'shift' in m:
        out.add('shift')
    return '+'.join([x for x in ORDER if x in out] + [keyname])

def map_key(key):
    return ' '.join(map_chord(c) for c in key.split(' '))

# Hand-picked Windows keys where the plain mapping would clash (Mac key, command) -> Windows key.
# None = drop on Windows (the command already has another key).
OVERRIDES = {
    ('cmd+ctrl+t', 'workbench.action.tasks.runTask'): 'ctrl+shift+alt+t',
    ('cmd+ctrl+alt+l', 'workbench.action.tasks.runTask'): None,
    ('cmd+ctrl+b', 'workbench.action.debug.start'): 'f5',
    ('ctrl+alt+r', 'workbench.files.action.showActiveFileInExplorer'): 'ctrl+shift+alt+r',
    ('ctrl+alt+c', 'workbench.files.action.collapseExplorerFolders'): 'ctrl+shift+alt+x',
    ('cmd+ctrl+shift+d', 'git.openChange'): 'ctrl+shift+alt+v',
    ('cmd+ctrl+shift+p', 'git.push'): 'ctrl+shift+alt+y',
    # Option+Tab would be Alt+Tab, the Windows app switcher: Ctrl+Tab does the same there.
    ('alt+tab', 'workbench.action.quickOpenPreviousRecentlyUsedEditorInGroup'): None,
    ('alt+tab', 'workbench.action.quickOpenNavigateNextInEditorPicker'): None,
    ('alt+shift+tab', 'workbench.action.quickOpenNavigatePreviousInEditorPicker'): None,
}

notes = []
out = []
for k in kb:
    w = k.get('when', '')
    if 'isMacNative' in w:
        notes.append('skipped (Mac-only): %s %s' % (k['key'], k['command']))
        continue
    n = dict(k)
    o = (k['key'], k['command'])
    if o in OVERRIDES:
        if OVERRIDES[o] is None:
            notes.append('dropped (duplicate): %s %s' % o)
            continue
        n['key'] = OVERRIDES[o]
        notes.append('override: mac %s %s -> %s' % (o[0], o[1], OVERRIDES[o]))
        n['_mac'] = k['key']
        out.append(n)
        continue
    n['key'] = map_key(k['key'])
    n['_mac'] = k['key']
    out.append(n)

# clash detection among active (positive) rules: same key and same when, or one without a when
pos = [k for k in out if not k['command'].startswith('-')]
by = collections.defaultdict(list)
for k in pos:
    by[k['key']].append(k)
clashes = []
for key, lst in by.items():
    if len(lst) < 2:
        continue
    macs = {x['_mac'] for x in lst}
    if len(macs) < 2:
        continue  # same Mac key with several when-clauses: intended
    clashes.append((key, lst))

with open(report, 'w') as f:
    for key, lst in clashes:
        f.write('CLASH %s:\n' % key)
        for x in lst:
            f.write('   mac %-18s %s | %s\n' % (x['_mac'], x['command'], x.get('when', '')))
    for n in notes:
        f.write(n + '\n')
print('entries', len(out), 'active', len(pos), 'clashes', len(clashes))

with open(dst, 'w') as f:
    f.write('// VS Code key bindings for Windows, generated from keybindings.json (Mac).\n')
    f.write('// Mapping: Mac Cmd -> Ctrl, Mac Ctrl -> Alt, Mac Cmd+Ctrl -> Ctrl+Alt, Mac Alt -> Alt.\n')
    f.write('// Regenerate after changing the Mac file: python3 scripts/make-windows-keybindings.py\n')
    f.write('[\n')
    for i, k in enumerate(out):
        mac = k.pop('_mac')
        line = json.dumps(k, ensure_ascii=False)
        f.write('  ' + line + (',' if i < len(out) - 1 else '') + '  // mac: ' + mac + '\n')
    f.write(']\n')
