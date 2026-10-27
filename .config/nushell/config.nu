# Edit this file in nishkodotco/dotfiles. Installed paths are symlinks.
# Preserve raw Docker output when an explicit output format is requested.
def --wrapped "docker ps" [...args] {
    let arguments = ($args | each {|arg| $arg | into string})
    let raw = ($arguments | any {|arg|
        $arg in ['--help', '-h', '--format', '--quiet', '-q'] or ($arg | str starts-with '--format=') or ($arg | str starts-with '-q') or ($arg | str starts-with '-aq')
    })
    if $raw {
        ^docker ps ...$args
    } else {
        ^docker ps ...$args --format '{{json .}}'
        | from json --objects
        | select Names Status Ports
    }
}
