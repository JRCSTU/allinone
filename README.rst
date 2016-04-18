########################
CO2MPAS ALLINONE archive
########################

Ingredients and checklist for a pre-populated archive with WinPython+Consoles+Graphviz to run *CO2MPAS* on *Windows*.

WinPython
---------
Login to the cmd-console and issue::

    python -m pip install -U pip
    mv get-pip.py ..\Apps\WinPython\scripts\.
    Apps\WinPython\scripts\make_winpython_movable\fix.bat
    md %HOME%\packages
    pip download -r \\co2mpas.git\requirements\dev.pip --f %HOME%\packages (--pre)
    ## Delete native & redundant packages (numpy/matplot/pip).
    pip install co2mpas -f %HOME%\packages         (--pre)
    co2mpas --version -v


Install also::

    pip install virtualenv snakemake pyreadline

Cygwin
------

- git, git-completion, colordif
- make, zip, unzip, bzip2, 7z, dos2unix, rsync
- openssh, curl, wget, gnupg
- procps, vim, vim-syntax

Upgrade cygwin.

Apps
====
- Add ``prog-x.y.z.ver`` on each app-folder.

Docs
====

- Copy ``co2mpas.git:doc/allinone .rst`` as ``./README.txt`` and FIX version!
- Update co2mpas-version in ``./Archive/Apps/Console/console.xml``.

