# Shared PATH for macOS, Linux, development containers, and Codespaces.
$env.PATH = ($env.PATH | prepend [
    ($env.HOME | path join '.local' 'bin')
    '/opt/homebrew/bin'
    '/opt/homebrew/sbin'
    '/usr/local/bin'
    '/usr/local/sbin'
    ($env.HOME | path join 'Library' 'Android' 'sdk' 'platform-tools')
    ($env.HOME | path join 'Android' 'Sdk' 'platform-tools')
    ($env.HOME | path join '.antigravity-ide' 'antigravity-ide' 'bin')
    '/usr/bin'
    '/bin'
    '/usr/sbin'
    '/sbin'
] | uniq | where {|entry| $entry | path exists})
