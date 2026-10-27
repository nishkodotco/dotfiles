#!/usr/bin/env python3
"""Install only allowlisted non-secret configuration as symlinks."""
import argparse
import datetime
import hashlib
import io
import os
from pathlib import Path
import platform
import shutil
import subprocess
import tarfile
import urllib.request

ROOT = Path(__file__).resolve().parents[1]
VERSION = '0.113.1'
DIGESTS = {
    'x86_64': '9008d309aaa35e29ed5d5985306a83e2bf5093e31677d4cd969914552d12b8fb',
    'aarch64': '08b94c6fd9c66881616df4c89adc03e8a42a57fdf6876cfd1b16cec7e82348b4',
}

def links(home, system):
    config = home / '.config'
    nu = home / 'Library/Application Support/nushell' if system == 'Darwin' else Path(os.environ.get('XDG_CONFIG_HOME', config)) / 'nushell'
    result = [(ROOT / '.config/nushell' / name, nu / name) for name in ['config.nu', 'env.nu']]
    result += [(ROOT / name, home / name) for name in ['.zshrc', '.zprofile', '.bashrc', '.bash_profile', '.gitconfig']]
    result += [(ROOT / '.config' / name, config / name) for name in ['ghostty/config', 'shell/path.sh', 'git/config', 'tmux/tmux.conf']]
    result += [(ROOT / '.config' / name, config / name) for name in ['nvim', 'fish']]
    result += [(ROOT / 'scripts/dotfiles', home / '.local/bin/dotfiles')]
    if system == 'Darwin':
        result += [(ROOT / 'editors' / app / name, home / 'Library/Application Support' / app / 'User' / name) for app in ['Code', 'Antigravity'] for name in ['settings.json', 'keybindings.json']]
    if system == 'Darwin':
        marker = home / '.local/state/dotfiles/xponent-profile-path'
        profile = Path(marker.read_text().strip()) if marker.is_file() else None
        if profile is not None and profile.is_dir():
            result += [(home / 'workspace/github/xponent/app.xponent.automation/vscode-profile' / name, profile / name) for name in ['settings.json', 'keybindings.json']]
    return result

def install_nu(home):
    if shutil.which('nu'):
        return
    if platform.system() != 'Linux':
        raise SystemExit('Install Nushell with brew install nushell, then rerun install.sh.')
    machine = platform.machine()
    machine = {'arm64': 'aarch64', 'amd64': 'x86_64'}.get(machine, machine)
    if machine not in DIGESTS:
        raise SystemExit('Unsupported Linux architecture: ' + machine)
    archive = f'nu-{VERSION}-{machine}-unknown-linux-gnu.tar.gz'
    url = f'https://github.com/nushell/nushell/releases/download/{VERSION}/{archive}'
    with urllib.request.urlopen(url, timeout=120) as response:
        data = response.read()
    if hashlib.sha256(data).hexdigest() != DIGESTS[machine]:
        raise SystemExit('Nushell download checksum failed.')
    target = home / '.local/bin/nu'
    target.parent.mkdir(parents=True, exist_ok=True)
    with tarfile.open(fileobj=io.BytesIO(data), mode='r:gz') as bundle:
        member = next(m for m in bundle.getmembers() if m.isfile() and m.name.split('/')[-1] == 'nu')
        with bundle.extractfile(member) as source, target.open('wb') as output:
            shutil.copyfileobj(source, output)
    target.chmod(0o755)
    print(f'Installed checksum-verified Nushell {VERSION}.')

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--home', type=Path, default=Path.home())
    parser.add_argument('--platform', choices=['Darwin', 'Linux'], default=platform.system())
    parser.add_argument('--check', action='store_true')
    parser.add_argument('--install-tools', action='store_true')
    parser.add_argument('--codespaces-shell', action='store_true')
    parser.add_argument('--xponent-profile', type=Path)
    args = parser.parse_args()
    home = args.home.resolve()
    if args.check and (args.install_tools or args.codespaces_shell or args.xponent_profile):
        parser.error('--check cannot install tools or change the shell')
    if args.xponent_profile:
        profile = args.xponent_profile.resolve()
        if not profile.is_dir():
            raise SystemExit('Create the Xponent profile in VS Code before linking its settings.')
        marker = home / '.local/state/dotfiles/xponent-profile-path'
        marker.parent.mkdir(parents=True, exist_ok=True)
        marker.write_text(str(profile) + '\n')
    if args.install_tools or (os.environ.get('CODESPACES') == 'true' and not args.check):
        install_nu(home)
    backup = home / '.local/state/dotfiles/backups' / datetime.datetime.now().strftime('%Y%m%d-%H%M%S-%f')
    failed = False
    for source, target in links(home, args.platform):
        if target.is_symlink() and target.resolve() == source:
            continue
        if args.check:
            print('Unmanaged configuration: ' + str(target))
            failed = True
            continue
        target.parent.mkdir(parents=True, exist_ok=True)
        if target.exists() or target.is_symlink():
            saved = backup / target.relative_to(home)
            saved.parent.mkdir(parents=True, exist_ok=True)
            shutil.move(str(target), saved)
            print('Backed up: ' + str(target))
        target.symlink_to(source)
        print('Linked: ' + str(target))
    if failed:
        raise SystemExit(1)
    if not args.check:
        print('Configuration source: ' + str(ROOT))
    if args.codespaces_shell or (os.environ.get('CODESPACES') == 'true' and not args.check):
        nu = shutil.which('nu') or str(home / '.local/bin/nu')
        sudo = shutil.which('sudo')
        if sudo and subprocess.run([sudo, '-n', 'true'], capture_output=True).returncode == 0:
            subprocess.run([sudo, 'sh', '-c', 'grep -qxF "$1" /etc/shells || printf "%s\n" "$1" >> /etc/shells', 'dotfiles', nu], check=True)
            subprocess.run([sudo, 'chsh', '-s', nu, __import__('getpass').getuser()], check=True)
        else:
            print('Default shell unchanged. Run nu to open Nushell.')

if __name__ == '__main__':
    main()
