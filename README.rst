########################
CO2MPAS ALLINONE archive
########################

Ingredients for a pre-populated archive with WinPython+Consoles+Graphviz to run *CO2MPAS* on *Windows*.

Apps
====
- Add ``prog-x.y.z.ver`` on each app-folder.


WinPython
---------
1. PATCH env.bat:8 not to FAIL due to ``find.exe`` clash with cygwin's one!!
   Login to the cmd-console and issue::

    echo ;%PATH%; | %SystemRoot%\System32\find /C /I ";%WINPYDIR%\;" >nul


2. Ensure *pip* upgraded::

    ## Upgrade PIP
    python -m pip install -U pip
    wget https://bootstrap.pypa.io/get-pip.py -O ..\Apps\WinPython\scripts\get-pip.py
    Apps\WinPython\scripts\make_winpython_movable\fix.bat

2. Install co2mpas dependencies::

    md %HOME%\packages
    pip download -r \\co2mpas.git\requirements\dev.pip --f %HOME%\packages (--pre)
    ## Delete native & redundant packages (numpy/matplot/pip) (TOO MANY!!)
    ## KEEP:
        dill, graphviz, easygui, asteval, doit, openpyxl, future,
        pandalone, regex, schema, tqdm, boltons, pykalman, xlwings,
        wltp, cachetools, setuptools-git, ddt

    pip install  -r \\co2mpas.git\requirements\dev.pip
    pip install co2mpas[sampling] -f %HOME%\packages         (--pre)
    pip download virtualenv -d %HOME%\packages               (--pre)
    cp co2mpas-xxx.whl  %HOME%\packages
    co2mpas --version -v


4. Install also these packages::

    pip install virtualenv snakemake pyreadline
    pip install  PyYAML HiYaPyCo python-gnupg keyring pbkdf2

    pip install jupyter_declarativewidgets jupyter_dashboards

    jupyter declarativewidgets quick-setup --sys-prefix
    jupyter nbextension enable declarativewidgets --py --sys-prefix

    jupyter dashboards quick-setup --sys-prefix
    jupyter nbextension enable jupyter_dashboards --py --sys-prefix

    ##pip install jupyter_cms ## NO, uninstalls ipython-5.x.x!!
    #jupyter cms quick-setup --sys-prefix


    ## Fetch wheels from Unofficial.
    pip install levehnstein-....whl
    pip install OpneCV-...+contrib_opencl....whl


    ## UNINSTALL big packages:
    pip uninstall boto3 botocore theano nltk lasagne


Cygwin
------
Packages to install:
- git, git-completion, colordif
- make, zip, unzip, bzip2, 7z, dos2unix, rsync
- openssh, curl, wget, gnupg
- procps, vim, vim-syntax

Upgrade:
- Download recent installer from: https://cygwin.com/install.html
- Write its version as ``cygwin_setup-x86_64-877.ver`` file next to it.
- Run it to get upgrade all installed packages.


ConsoleZ
--------
- Download from: https://github.com/cbucher/console/wiki/Downloads
- Copy-paste folder of the extracted zipped-release.
- Update ALLINONE-version in Window-title pattern in
  ``./Archive/Apps/Console/console.xml``.

clink:
-------
- Download *zip* from: https://mridgers.github.io/clink/
- Update ``profile`` folder and *merge* bat to print *console help*.


Graphviz
--------
- Download from: http://www.graphviz.org/Download_windows.php
- Copy-paste folder of the extracted zipped-release.


node.js
-------

For declarative-widgets:

- Download and unzip the *7z* from: https://nodejs.org/dist/latest/
- OR install node.js according to this: https://gist.github.com/massahud/321a52f153e5d8f571be#file-portable-node-js-andnpm-on-windows-md
- ``npm install bower``


Gpg4win
-------
Fetch the latest version from: https://www.gpg4win.org/


Docs
====

- Copy ``Archive/README.txt`` as ``./README.txt`` and FIX CO2MPAS & WinPython versions!

