########################
CO2MPAS ALLINONE archive
########################

The tools and ingredients for a pre-populated archive with WinPython+Consoles+Graphviz to run *CO2MPAS* on *Windows*.

WinPython:
==========
Login to the cmd-console and issue::

    md %HOME%\packages
    pip install co2mpas --download %HOME%\packages (--pre)
    pip install co2mpas -f %HOME%\packages         (--pre)
    co2mpas --version -v


Install also::

    pip install virtualenv snakemake pyreadline

Cygwin
======

- git, git-completion
- make, zip, unzip, bzip2, 7z, dos2unix, rsync
- openssh, curl, wget, gnupg
- procps
