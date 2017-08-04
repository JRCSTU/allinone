########################
CO2MPAS ALLINONE archive
########################

Ingredients for a pre-populated archive with WinPython+Consoles+Graphviz to run *CO2MPAS* on *Windows*.

Building & Packaging
====================
The creation of a new AIO is based on 2 identical folder hierarchies:

- the ``./Archive/`` containing "template files" that should be copied in
- the ``./co2mpas_AIO/`` folder, that is the actual "AIO" to be 7zipped.

The bash-script ``./prepare.sh`` copies those files in their appropriate place and
performs various clean-up tasks. Running this script should be the last thing to do
before compressing the final archive (see step 4, below).

To build the 2nd AIO folder follow these steps:

1. The AIO folder is usually created by extracting a previous AIO version, to arrive
   in this hierarchy of folders and files::

     ./co2mpas_AIO/
       +--Apps/...
       +--CO2MPAS/...
       +--CO2MPAS.vbs
       +--CONSOLE.vbs
       +--INSTALL.vbs
       +--co2mpas-env.bat
       +--README

   Otherwise, follow the specific instructions for downloading and extracting each
   application under a separate folder in ``./co2mpas_AIO/Apps/``, as explained in the
   sections below.

2. Install latest `co2mpas` package with `pip` command (either from *PyPi* or locally,
   if i's a *dev* release) and run and test the basic commands and procedures to
   check everything works as planned.

3. The AIO has its own version in ``VERSION.txt`` file, distinct from *co2mpas*
   package, which is imprinted in various places, so you you have to modify it
   before running ``./prepare.sh``.

   The name of the containing folder must also contain the AIO version; since
   the AIO folder is always named ``co2mpas_AIO``, do run this command once
   in ``cmd.exe`` to arrive to a ``co2mpas_AIO-X.Y.Z`` name (and rename the
   junction in subsequent releases)::

         mklink  /J  C:\co2mpas_AIO-X.Y.Z  C:\Apps\allinone.git\co2mpas_AIO

   .. Tip:
      Remeber to respect PEP 440 version format (e.g. ``1.1.1b0`` but
      ``1.1.1.post0``).

4. Commit the 2 modified files above.

5. Execute the ``./prepare.sh`` script from a Bash launched **outside of the AIO folder!**

6. Finally, compress the ``C:\co2mpas_AIO-X.Y.Z`` folder created above using either
   the 7zip utility or the `Total-Commander+7zip plugin <https://www.ghisler.com/plugins.htm>`_.
   Use maximum compression.   Check the contents of the result 7zip archive are
   structured like the previous releases.

7. Deploy release:  Make sure release appropriately tagged and signed in git
   with your private key.

   - If "BETA": draft a new pre-release in private co2mpas repo
   - If "FINAL": draft a new release in private co2mpas repo with the
     "announcement email-text" in it.  If archive is deemed ok, copy text to
     public repo and repeat this step; modify `issue #8
     <https://github.com/JRCSTU/co2mpas-ta/issues/8>`_ to announce new release
     to subscribers of this issue.

  Study also `old release guidelines:
  <https://github.com/JRCSTU/co2mpas/wiki/Developer-Guidelines#release-checklist>`_


Apps
====
- Add ``prog-x.y.z.ver`` on each app-folder.


WinPython
---------
*WinPython* is a **portable** distribution, so certain procedure is needed
to maintain it.

.. Note:
   Specifically, when upgrading pip, always use this *WinPython* script:
   ``$aio/Apps/WinPython/scripts/upgrade_pip.bat``

   Otherwise, whatever pip install <package> you do, will not run if AIO folder moved.
   In any case, running ``$aio/Apps/WinPython/scripts/make_winpython_movable.bat``
   script wll fix both problems.


1. Copy ``libeay32.dll`` to DLL PATH for *opentimestamp*/*openssl* to work::

       WinPython-64bit-XXX/python-XXX/Lib/site-packages/PyQt5/Qt/bin/ --> WinPython-64bit-XXX/python-XXX/DLLs/

   See: https://github.com/coderanger/pychef/issues/56

2. Ensure *pip* upgraded::

    ## Upgrade PIP
    python -m pip install -U pip
    wget https://bootstrap.pypa.io/get-pip.py -O $AIODIR/Apps/WinPython/scripts/get-pip.py
    $AIODIR/Apps/WinPython/scripts/make_winpython_movable/fix.bat

2. Create a folder with co2mpas dependencies::

    mkdir -p ~/packages
    cd ~/packages
    pip download -r ../co2mpas.git/requirements/dev.pip  (--pre)
    ## Delete native & redundant packages (numpy/matplot/pip) (TOO MANY!!)
    ## KEEP:
        dill, graphviz, easygui, asteval, doit, openpyxl, future,
        pandalone, regex, schema, tqdm, boltons, pykalman, xlwings,
        wltp, cachetools, setuptools-git, ddt

    pip install  -r ../co2mpas.git/requirements/dev.pip
    pip install co2mpas[sampling]                        (--pre)
    pip download virtualenv                              (--pre)
    cp co2mpas-xxx.whl  ~/packages
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
       mv get-pip.py $AIODIR/Apps/WinPython/scripts/
       #python get-pip.py

6. HOTFIXES:
~~~~~~~~~~~~

- GitPython: cygpath fix:
  Copy ``git/utils.py`` from:

- `imaplib noop Debug <https://bugs.python.org/issue26543>`_ error in
  https://github.com/python/cpython/blob/master/Lib/imaplib.py#L1217 ::

      - l = map(lambda x:'%s: "%s"' % (x[0], x[1][0] and '" "'.join(x[1]) or ''), l)
      + l = map(lambda x:'%s: "%s"' % (x[0], x[1][0] and '" "'.join(str(k) for k in x[1]) or ''), l)

  Or even better appply patch.

- Add ``__init__.py`` files::

      $AIODIR/Apps/WinPython/python-3.5.2.amd64/Lib/site-packages/mpl_toolkits/__init__.py
      $AIODIR/Apps/WinPython/python-3.6.1.amd64/lib/site-packages/google/__init__.py
      $AIODIR/Apps/WinPython/python-3.6.1.amd64/lib/site-packages/google/__init__.py

  to avoid warnings like that:

      2017-02-10 15:37:16,032:WARNI:py.warnings: AIO\Apps\WinPython\python-3.5.2.amd64\lib\importlib\_bootstrap_external.py:415: ImportWarning: Not importing directory AIO\apps\winpython\python-3.5.2.amd64\lib\site-packages\mpl_toolkits: missing __init__
   _warnings.warn(msg.format(portions[0]), ImportWarning)

- Add these lines in ``getpass.py#167`` standard-lib for polite Git msg (FIX)::


      if os.name =='nt':
          raise ValueError("No user-name has been set!")

- GnuPG: Extract ``key_id`` from ciphers, ``gnupg.py#602-607``;
    see https://bitbucket.org/vinay.sajip/python-gnupg/issues/83/handle-enc_to-to-acquire-key_id-on

- pandas OpenPYXL usage::

    $AIODIR/Apps/WinPython/python-3.5.2.amd64/Lib/site-packages/pandas/io/excel.py

         L784:
         - self.book.remove_sheet(self.book.worksheets[0])
         + self.book.remove(self.book.worksheets[0])

to remove warning::

     15:47:55:WARNI:py.warnings: AIO\Apps\WinPython\python-3.5.2.amd64\lib\site-packages\openpyxl\workbook\workbook.py:182: DeprecationWarning: Call to deprecated function or class remove_sheet (Use wb.remove(worksheet) or del wb[sheetname]).
     def remove_sheet(self, worksheet):

- SOCKS:
  - https://github.com/python/cpython/pull/562 (socks library).

  - Link socks-errors (socks.py#711)::

        - except ValueError as ex:
        -     raise GeneralProxyError("HTTP proxy server sent invalid response")
        + except ValueError:
        +     raise GeneralProxyError("HTTP proxy server sent invalid response") from ex

  - Link socks-errors (socks.py#719)::

        - except ValueError:
        -     raise HTTPError("HTTP proxy server did not return a valid HTTP status")
        + except ValueError as ex:
        +     raise HTTPError(
        +         "HTTP proxy server did not return a valid HTTP status") from ex

  - Link socks-errors (socks.py#806)::

            - raise ProxyConnectionError(msg, error)
            + raise ProxyConnectionError(msg, error) from error

  - Link socks-errors (socks.py#817)::

                - raise GeneralProxyError("Socket error", error)
                + raise GeneralProxyError("Socket error", error) from error

- ``rainbow_logging_handler``: move ``import sys`` at the top of the file
  https://github.com/laysakura/rainbow_logging_handler/blob/master/rainbow_logging_handler/__init__.py#L210
  See https://github.com/laysakura/rainbow_logging_handler/issues/14

- ``exchangelib``:
  Just close pool; see https://github.com/ecederstrand/exchangelib/issues/160

- ``schedula``:
    Fix ``DispatcherAbort`` cstor, see https://github.com/vinci1it2000/schedula/pull/9


POSIX
-----

Cygwin:
~~~~~~~
Upgrade:
- Download recent installer from: https://cygwin.com/install.html
- Write its version as ``cygwin_setup-x86_64-877.ver`` file next to it.
- Run it to get upgrade all installed packages.

Packages to install:
- git, git-completion, colordif, patch
- make, zip, unzip, bzip2, 7z, dos2unix, rsync, inetutils (telnet), nc
- openssh, curl, wget, gnupg
- procps, vim, vim-syntax

DOWNGRADE Git to 2.8.3 from timemachine or else ``pip install git+https://...``
FAILS if Git-2.12+!

    - http://ctm.crouchingtigerhiddenfruitbat.org/pub/cygwin/circa/64bit/2017/04/16/142118/index.html

MSYS2:
~~~~~~
Under *MSYS2* make sure ``wget curl openssh gnupg procps vim telnet``
exist after installing::

- ::

      pacman -S man git make tar zip p7zip unzip  dos2unix rsync \
                procps inetutils patch gnu-netcat colordiff


- Manually Install git-lfs:
  - Download zip for windows from; https://github.com/git-lfs/git-lfs/releases,
  - extract and copy ``git-lfs.exe --. $AIODIR/Apps/Cygwin/usr/bin``.


GnuPG:
------
- Download latest Gpg4Win from https://www.gpg4win.org/download.html,
  install locally, then copy installation folder into ``$AIODIR/Apps/GunPG/``.
  ``prepare.sh`` makes it portable by creating ``gpgconf.ctl`` in same dir
  as ``gpgconf.exe`` (https://www.gnupg.org/documentation/manuals/gnupg/gpgv.html)




ConsoleZ
--------
- Download from: https://github.com/cbucher/console/wiki/Downloads
- Copy-paste folder of the extracted zipped-release.
- Update ALLINONE-version in Window-title pattern in
  ``/Archive/Apps/Console/console.xml`` or copy the other way round.


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


