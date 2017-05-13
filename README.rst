########################
CO2MPAS ALLINONE archive
########################

Ingredients for a pre-populated archive with WinPython+Consoles+Graphviz to run *CO2MPAS* on *Windows*.

Apps
====
- Add ``prog-x.y.z.ver`` on each app-folder.


WinPython
---------
1. Copy ``libeay32.dll`` to DLL PATH for *opentimestamp*/*openssl* to work::

       WinPython-64bit-XXX\python-XXX\Lib\site-packages\PyQt5\Qt\bin\ --> WinPython-64bit-XXX\python-XXX\DLLs\

   See: https://github.com/coderanger/pychef/issues/56

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

3. Ensure `xlwings` upgraded (usually is `0.2.3` while it exists 0.10.3+)::

      pip uninstall xlwings
      pip install xlwings

4. Install also these packages::

    ## Fetch wheels from Unofficial.
    #
    Twisted
    pywin32  # MANUALLY delete from site-packages to unistall!!
    pip install pygit2
    pip install levehnstein-....whl
    #pip install OpenCV-...+contrib_opencl....whl

    pip install virtualenv magic-wormhole
    pip install git+https://github.com/ankostis/pyreadline@redisplay
    pip install ruamel.yaml doit  git+https://github.com/ankostis/python-glob2@preserve_matches
    pip install git+https://github.com/ankostis/ViTables@pandas


    ## JUPYTERS
    #
    pip install jupyter_declarativewidgets
    jupyter declarativewidgets quick-setup --sys-prefix
    jupyter nbextension enable declarativewidgets --py --sys-prefix

    pip install jupyter_dashboards
    jupyter dashboards quick-setup --sys-prefix
    jupyter nbextension enable jupyter_dashboards --py --sys-prefix

    ##pip install jupyter_cms ## NO, uninstalls ipython-5.x.x!!
    #jupyter cms quick-setup --sys-prefix

    ## NOT MANY EXTS for Jupyter-5.0: https://github.com/ipython-contrib/jupyter_contrib_nbextensions/issues/942
    #
    #pip install git+https://github.com/Jupyter-contrib/
    #jupyter contrib nbextension install --user
    #pip install jupyter_nbextensions_configurator
    #jupyter nbextensions_configurator enable --user


    ## UNINSTALL big packages:
    pip uninstall theano
    pip uninstall boto3 botocore nltk lasagne  # (DANGEROUS)

5. Download get-pypi.dev::

       wget https://bootstrap.pypa.io/get-pip.py
       mv get-pip.py ..\Apps\WinPython\scripts\
       #python get-pip.py

6. HOTFIXES:

- `imaplib noop Debug <https://bugs.python.org/issue26543>`_ error in
  https://github.com/python/cpython/blob/master/Lib/imaplib.py#L1217 ::

      - l = map(lambda x:'%s: "%s"' % (x[0], x[1][0] and '" "'.join(x[1]) or ''), l)
      + l = map(lambda x:'%s: "%s"' % (x[0], x[1][0] and '" "'.join(str(k) for k in x[1]) or ''), l)

  Or even better appply patch.

- Add MPL-toolkits file::

      AIO\Apps\WinPython\python-3.5.2.amd64\Lib\site-packages\mpl_toolkits\__init__.py

  to avoid warnings like that:

      2017-02-10 15:37:16,032:WARNI:py.warnings:D:\Work\ALLINONES2\co2mpas_AIO-v1.5.4\Apps\WinPython\python-3.5.2.amd64\lib\importlib\_bootstrap_external.py:415: ImportWarning: Not importing directory d:\work\allinones2\co2mpas_aio-v1.5.4\apps\winpython\python-3.5.2.amd64\lib\site-packages\mpl_toolkits: missing __init__
   _warnings.warn(msg.format(portions[0]), ImportWarning)

- pandas OpenPYXL usage:
  d:\Work\ALLINONES2\co2mpas_AIO-v1.5.4\Apps\WinPython\python-3.5.2.amd64\Lib\site-packages\pandas\io\excel.py

         L784:
         - self.book.remove_sheet(self.book.worksheets[0])
         + self.book.remove(self.book.worksheets[0])

to remove warning:

     15:47:55:WARNI:py.warnings:D:\Work\ALLINONES2\co2mpas_AIO-v1.5.4\Apps\WinPython\python-3.5.2.amd64\lib\site-packages\openpyxl\workbook\workbook.py:182: DeprecationWarning: Call to deprecated function or class remove_sheet (Use wb.remove(worksheet) or del wb[sheetname]).
     def remove_sheet(self, worksheet):

- https://github.com/python/cpython/pull/562 (socks library).


Cygwin
------
Upgrade:
- Download recent installer from: https://cygwin.com/install.html
- Write its version as ``cygwin_setup-x86_64-877.ver`` file next to it.
- Run it to get upgrade all installed packages.

Packages to install:
- git, git-completion, colordif, patch
- make, zip, unzip, bzip2, 7z, dos2unix, rsync, inetutils (telnet), nc
- openssh, curl, wget, gnupg
- procps, vim, vim-syntax

OR under *MSYS2*::

- ::

      pacman -S git wget curl make zip unzip  dos2unix rsync openssh \
                gnupg procps vim telnet nc patch

- NO 7z!!


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

DEMOS
=====

Copy ``Archive/Demos --> ./CO2MPAS/demos``
