#!/bin/bash
#
## Upgrade AIO

VERSION_FILE_CHECK="AIO-1.7.3*.ver"
INFLATE_DIR="$TMP/CO2MPAS_AIO/UpgradePack-1.7.3+2018.1.ver"

set -u  # fail on unset variables

##################
# Utilities
##################
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
        yell "aborted in line $1: ${2:-unspecified error}" \
            "\n  (use -k to keep going, -v to debug it)"
    else
        log "error in line $1:${2:-unspecified error}\n  ...but KEEP GOING."
    fi
}
trap 'err_report $LINENO  $BASH_COMMAND' ERR

prog="$0"
my_dir="$(dirname "$0")"
pip="pip"
cp="cp -v"
rm="rm -v"
AIODIR="$(cygpath "$AIODIR")"
AIOVERSION="$(find "$AIODIR" -maxdepth 1 -name $VERSION_FILE_CHECK)"


##################
# MAIN FUNCTIONS
##################
#
prompt_for_abort() {
    local msg="upgrade $AIOVERSION..."
    if [ -n "$all_yes" ]; then
        log "started $msg"
    else
        log "ready to $msg\n  Press any key to continue, or [Ctrl+C] to cancel?"
        read
    fi
}


check_environ () {
    if [ ! -f  "$AIOVERSION" ]; then
        local msg="cannot locate file: $AIOVERSION" \
            "\n  Command must launch from an AIO-1.7.3+ console!"
        
        if [ -n "$force" ]; then
            log "$msg\n  ...but FORCED upgrade."
        else
            yell "$msg\n  (use --force if you must)"
        fi
    fi
}


clean_inflated () {
    rm -rvf "$INFLATE_DIR"
}

inflate_pack () {
    log "inflating pack-files in: $INFLATE_DIR"
    clean_inflated
    mkdir "$INFLATE_DIR"
    trap 'clean_inflated' EXIT
    base64 -d << Base64EOF | tar -xjv -C "$INFLATE_DIR"
__BASE64_ARCHIVE_HERE__
Base64EOF
}

do_upgrade () {

    cd "$my_dir"
    $pip install --no-index --no-dependencies "$INFLATE_DIR"/wheels/*.whl
    $rm -f "$AIOVERSION"
    $cp -rv "$INFLATE_DIR/AIO/"* "$AIODIR/."
}

##################
# Cmdline parsing & validation.
##################
#

## Prefer `cat` instead of `read` command below (from https://serverfault.com/a/72511/215750)
#  because its exit-status is 1 when EOF.
# read -r -d '' help <<'EOF'
help=$(cat <<EOF
Inflate (in \$TMP/CO2MPAS_AIO/...) and install upgrade files for CO2MPAS AIO.
SYNTAX: 
    $prog [options]
OPTIONS:
    -f|--force:         upgrade even if not "$AIOVERSION"
    -h|--help           display this message
    -k|--keep-going:    continue working on errors
    -n|--dry-run:       pretend commands executed
    -v|--verbose:       print commands as executed
    -y|--yes:           answer all questions with yes (no interactive)
EOF
)

declare -i verbose
bad_opts='' bad_args='' dry_run='' force='' all_yes='' verbose=0
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
        (-y|--yes) 
            all_yes=true
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
    yell "command received invalid options or arguments:" \
        "\n  bad options: $bad_opts" 
        "\n  unexpected args: $bad_args\nAborting!\n\n$help" 
fi

if [ -n "$dry_run" ]; then
    log "PRETEND actions..."
    pip="echo $pip"
    cp="echo $cp"
    rm="echo $rm"
fi
if [ $verbose -gt 0 ]; then
    set -x 
    pip="$pip -v"
    if [ $verbose -gt 1 ]; then
        set -v
        pip="$pip -v"
    fi
fi

check_environ
inflate_pack
prompt_for_abort
do_upgrade
