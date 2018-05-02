#!/bin/bash
#
## Upgrade AIO-1.7.3 --> +2018.1

VERSION_FILE_CHECK="AIO-1.7.3*.ver"

set -u  # fail on unset variables

prog="$0"
my_dir="$(dirname "$0")"
pip="pip"
cp="cp -v"
rm="rm -v"

## Utilities
#
log () {    
    echo -e "$prog: $@" >&2
}
yell () {
    log "$@"
    exit 1
}
keep_going=''  # Fail early on any error while script init.
err_report () {
    ## From: https://stackoverflow.com/a/185900/548792
    if [ -z "$keep_going" ]; then
        yell "aborted in line $1: ${2:-unspecified error}\n  (use -k to keep going, -v to debug it)"
    else
        log "error in line $1:${2:-unspecified error}\n  ...but KEEP GOING."
    fi
}
trap 'err_report $LINENO  $BASH_COMMAND' ERR


## Prefer `cat` instead of `read` command below (from https://serverfault.com/a/72511/215750)
#  because its exit-status is 1 when EOF.
# read -r -d '' help <<'EOF'
help=$(cat <<EOF
SYNTAX: 
    $prog [options]
OPTIONS:
    -f|--force:         upgrade even if not "$VERSION_FILE_CHECK"
    -k|--keep-going:    continue working on errors
    -n|--dry-run:       pretend commands executed
    -v|--verbose:       print commands as executed
    -h|--help           display this message
EOF
)

## Cmdline parsing & validation.
#
declare -i verbose
bad_opts='' bad_args='' dry_run='' force='' verbose=0
while [ $# -ne 0 ]; do
    case "$1" in
        (-h|--help) 
            echo "$help"
            exit
            ;;
        (-k|--keep-going) 
            keep_going=true
            ;;
        (-f|--force) 
            force=true
            ;;
        (-n|--dry-run) 
            dry_run=true
            ;;
        (-v|--verbose) 
            verbose=$((verbose + 1))
            ;;
        (--*|-*) 
            bad_opts="$bad_opts $1"
            ;;
        (*) 
            bad_args="$bad_args $1"
            ;;
    esac
    shift
done
if [ -n "$bad_opts$bad_args" ]; then
    yell "command received invalid options or arguments:\n" \
        " bad options: $bad_opts\n" " unexpected args: $bad_args\nAborting!\n\n$help" 
fi

if [ -n "$dry_run" ]; then
    log "PRETEND actions..."
    pip="echo $pip"
    cp="echo $cp"
    rm="echo $rm"
fi
[ $verbose -gt 0 ] && set -x && [ $verbose -gt 1 ] && set -v

check_environ () {
    AIODIR="$(cygpath "$AIODIR")"
    if [ ! -f  "$AIODIR/"$VERSION_FILE_CHECK ]; then
        yell "cannot locate file: $AIODIR/"$VERSION_FILE_CHECK "\n" \
            "  Command must launch from an AIO-1.7.3+ console!\nAborting!\n\n" >&2
    fi
}

do_upgrade () {

    cd "$my_dir"
    $pip install --no-index --no-dependencies wheels/*.whl
    $rm -f "$AIODIR/"$VERSION_FILE_CHECK
    $cp -rv AIO/* $AIODIR/.
}
if [ -z "$force" ]; then
    check_environ
fi
do_upgrade
