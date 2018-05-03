# Build a self-extract AIO-UpgradePack.
#

FINALZIP=UpgradePack.exe
TMPZIP=_archive.7z

## FAIL: cannot find sfx
#zip="/usr/lib/7z"
#zip="/usr/bin/7z"
#SFX=/usr/lib/p7zip/7zCon.sfx

## No Launch
#SFX=/d/Apps/7-ZipPortable/App/7-Zip/7zCon.sfx
#SFX=/d/Apps/7-ZipPortable/App/7-Zip/7z.sfx
#zip=/d/Apps/7-ZipPortable/App/7-Zip/7z

## OK
#zip=/d/Downloads/7z
#SFX=/d/Downloads/7zCon.sfx

## ./UpgradePack.exe: Permission denied
#  BUT with ``cmd /c zip.exe`` it asks admin rights!
#zip=/d/Apps/tmpexe/7zr
#SFX=/d/Apps/tmpexe/7zSD.sfx
#SFX=/d/Apps/tmpexe/7zS2con.sfx
#SFX=/d/Apps/tmpexe/7zS2.sfx

## ./UpgradePack.exe: Permission denied
#zip=/d/Apps/tmpexe/7zr
#SFX=/d/Apps/tmpexe/7zS.sfx

#zip=/d/Apps/tmpexe/7zLast/x64/7zr
# PERMISSION DENIED
#SFX=/d/Apps/tmpexe/7zLast/7zS2con.sfx

# Reads config(!) but...: 7-zip: unsupported method
# From: https://github.com/chrislake/7zsfxmm
#SFX=/d/Apps/tmpexe/7zsfx/7zsd.sfx
#SFX=/d/Apps/tmpexe/7zsfx/7zsd_LZMA_x64.sfx
#SFX=/d/Apps/tmpexe/7zsfx/7zsd_PPMd_x64.sfx 
define NEWLINE

endef

rm=rm -v


all: $(FINALZIP)

$(TMPZIP): $(wildcard PackFiles/*)
	$(rm) -f $(TMPZIP)
	$(zip) a -mx=7 $(TMPZIP) ./Packfiles/*

$(FINALZIP): sfx_config.txt $(TMPZIP) Makefile
	cat $(SFX) sfx_config.txt $(TMPZIP) > $@
	chmod a+x $@

clean: 
	$(rm) $(TMPZIP) $(FINALZIP)

