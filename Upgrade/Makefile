# Build a self-extract AIO-UpgradePack.
#
# ask ankostis

DIST_PACK=UpgradePack.sh
TMPZIP=_archive.tar.bz2
TMPB64=_archive.tar.bz2.b64

rm=rm -v
base64=base64
cat=cat
cp=cp -v
zip=tar -cv -C Packfiles -f
awk=gawk

PACK_FILES=$(wildcard PackFiles/*)

all: $(DIST_PACK)

.DELETE_ON_ERROR:
.INTERMEDIATE: $(TMPZIP) $(TMPB64)

$(TMPZIP): $(PACK_FILES)
	$(rm) -f $(TMPZIP)
	$(zip) $(TMPZIP) $(PACK_FILES:PackFiles/%=%)

$(TMPB64): $(TMPZIP)
	$(base64) > $(TMPB64) < $(TMPZIP)

$(DIST_PACK): $(TMPB64) upgrade-script.sh
	## From https://unix.stackexchange.com/a/212419/156357
	$(cat) upgrade-script.sh | \
		$(awk)  -f replace_b64.awk  -v b64file=$(TMPB64)  > $@
	chmod a+x $@

clean: 
	$(rm) $(TMPZIP) $(TMPB64) $(DIST_PACK)

