# Build a self-extract AIO-UpgradePack.
#
# ask ankostis

UPGRADE_SCRIPT=UpgradePack.sh

input_script := upgrade-script.sh
tmp_archive     := _archive.tar.bz2
wheels_tstamp   := Packfiles/wheelhouse/.keepme
wheels      := $(file < wheels.list)
src_wheels  := $(addprefix wheelhouse/,$(wheels))
dst_wheels  := $(addprefix Packfiles/wheelhouse/,$(wheels))
last_line   := $(shell wc -l $(input_script) | sed 's/[^0-9]//g' )
last_line   := $(shell echo -n $$(( $(last_line) + 1 )) )  # trial & error

rm := rm -v
base64 := base64
cat := cat
cp := cp -v
tar := tar -cv -C Packfiles --to-stdout
zip := bzip2 -7 - --stdout
sed := sed
chmod := chmod

pack_files = $(wildcard PackFiles/*)

.DELETE_ON_ERROR:
.PHONY: clean
## Comment-out this to inspect intermediate archive.
#.INTERMEDIATE: $(tmp_archive)


all: $(UPGRADE_SCRIPT)

$(wheels_tstamp): wheels.list $(src_wheels)
	$(cp) $(src_wheels) Packfiles/wheelhouse/.
	touch $@

$(tmp_archive): $(pack_files) $(wheels_tstamp)
	$(rm)       -f $(tmp_archive)
	$(tar)      $(pack_files:PackFiles/%=%)  |  $(zip)  >  $(tmp_archive) 

$(UPGRADE_SCRIPT): $(input_script) $(tmp_archive)
	## From https://unix.stackexchange.com/a/212419/156357
	$(cp)       $<  $@
	$(cat)      $(tmp_archive)  |  $(base64)  >>  $@
	$(chmod)    a+x  $@

clean: 
	$(rm) -f $(tmp_archive) $(UPGRADE_SCRIPT)

