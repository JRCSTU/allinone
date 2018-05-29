## Stage-2 of Upgrade-pack
####################################

do_patch_console_config () {
    local orig_file="$AIODIR/Apps/Console/console.xml"
    local backup_file="$AIODIR/Apps/Console/console.OLD-$OLD_AIO_VERSION.xml"
    
    logstep "${DRY_RUN}patching console configuration: $orig_file, backup: $backup_file..."
    $cp "$orig_file" "$backup_file"
    $sed -i "s/title=\"AIO-[^\"+]\"/title=\"AIO-$NEW_VERSION/" "$orig_file" 
    ## TODO: fix MSYS2 unset vars...
}
do_disable_2nd_stage_script() {
    local orig_file="$0"
    local dest_file="${0#.sh}-$OLD_AIO_VERSION-$($date +%Y%m%d_%H%M%S).sh"

    logstep "${DRY_RUN}disabling 2nd-stage upgrade-script: $orig_file --> $dest_file..."
    $mv "$orig_file" "$dest_file"
}

####################################
## Main body
####################################
build_help
notice "STAGE-2 of $HELP_OPENING"

parse_cmdline_args "$@"

check_existing_AIO "STAGE-2 of "
run_upgrade_steps \
    do_patch_console_config \
    do_disable_2nd_stage_script \
    do_delete_old_version_file


notice "finished $DRY_RUN$SCRIPT_ACTION successfully." \
    "\n  Press any key to continue."
read -sn1