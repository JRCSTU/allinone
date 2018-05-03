# Build a self-extract AIO-UpgradePack.
#
# ask ankostis

UPGRADE_SCRIPT=UpgradePack.sh

input_script=upgrade-script.sh
tmp_b64=_archive.tar.bz2.b64

last_line := $(shell wc -l $(input_script) | sed 's/[^0-9]//g' )
last_line := $(shell echo -n $$(( $(last_line) + 1 )) )  # trial & error

rm=rm -v
base64=base64
cat=cat
cp=cp -v
tar=tar -cv -C Packfiles --to-stdout
zip=bzip2 -7 - --stdout
sed=sed
chmod=chmod

pack_files=$(wildcard PackFiles/*)

all: $(UPGRADE_SCRIPT)

.DELETE_ON_ERROR:
.INTERMEDIATE: $(tmp_b64)

$(tmp_b64): $(pack_files)
	$(rm)       -f $(tmp_b64)
	$(tar)      $(pack_files:PackFiles/%=%)  |  $(zip)  |  $(base64)  >  $(tmp_b64) 

$(UPGRADE_SCRIPT): $(input_script) $(tmp_b64)
	## From https://unix.stackexchange.com/a/212419/156357
	$(sed)      "s/__BASE64_ARCHIVE_LINENO__/$(last_line)/" $< > $@
	$(cat)      $(tmp_b64) >> $@
	$(chmod)    a+x  $@

clean: 
	$(rm) -f $(tmp_b64) $(UPGRADE_SCRIPT)

