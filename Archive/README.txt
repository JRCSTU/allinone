##########################
CO2MPAS All-In-One archive
##########################
A pre-populated folder with WinPython + CO2MPAS + Consoles for *Windows*.

.. contents:: Table of Contents
  :backlinks: top
  :depth: 4

.. Note::
    For recent WinPython, Windows 7/8 users may have to install `Microsoft Visual
    C++ Redistributable for Visual Studio 2015 (KB2977003)
    <https://www.visualstudio.com/downloads/download-visual-studio-vs#d-visual-c>`_,
    also contained as ``Apps\vc_redist.x64.exe`` inside the archive.


1st steps
=========
0. Execute the ``INSTALL.vbs`` script the first time after extracting the archive.


1. Ensure the latest "MS CRT Runtime DLL" is installed (admin rights required if not), 
   or else, you would see this message when launching CO2MPAS:

        The program can't start because ap-ms-win-crt-runtime-L1-1-0.dll is missing from your computer...   
   
   Visit this issue for more informations: https://github.com/JRCSTU/CO2MPAS-TA/issues/5

   
3. Launch CO2MPAS:

    - Execute the ``CO2MPAS.vbs`` file, or simply press the [WinKey] once and start typing "run CO2MPAS",
      and select it lo launch the GUI.
    

4. For various operations, the *console* is needed:

    - Execute the ``CONSOLE.vbs`` file to open a console with the **command-prompt**
      (`cmd.exe`) shell.
      Command-examples starting with the ``>`` character are for this shell.

    - Then press [Ctrl+F2] to open a **bash-shell** if you prefer a UNIX-like environment.
      Command-examples starting with the ``$`` character are for this shell.

    - WHEN COPY-PASTING COMMANDS from the examples in the documents,
      DO NOT INCLUDE THE ``>`` OR ``$`` CHARACTERS.


3. Your *HOME* folder is ``CO2MPAS``.  You may run all example code inside
   this folder.

        - To move to your HOME folder when in *command-prompt*, type:

          .. code-block:: console

            > cd %HOME%

        - To move to your HOME folder when in *bash*, type:

          .. code-block:: console

            $ cd ~          ## The '~' char expands to home-folder.


4. View the files contained in your HOME folder, and read their description,
   provided in the next section:

        - In *command-prompt*, type:

          .. code-block:: console

            > dir
            Volume in drive D is Data
            Volume Serial Number is 688C-C286

             Directory of D:\Apps\co2mpas_AIO-v1.5.0.b0\CO2MPAS

              07/02/2017  09:26    <DIR>          .
              07/02/2017  09:26    <DIR>          ..
              15/07/2016  17:38             6,120 .bashrc
              07/02/2017  08:02               277 .bash_history
              08/02/2016  13:54             1,494 .bash_profile
              07/02/2017  06:26    <DIR>          .co2dice
              08/02/2016  13:54               632 .gitconfig
              08/02/2016  13:54               113 .inputrc
              18/07/2016  14:17                42 .lesshst
              07/02/2017  06:58    <DIR>          .matplotlib
              08/02/2016  13:54             1,236 .profile
              14/11/2016  02:04    <DIR>          .vim
              18/07/2016  14:40             8,900 .viminfo
              01/07/2016  11:27             2,536 .vimrc
              07/02/2017  09:43            13,340 co2mpas.log
              14/11/2016  02:04    <DIR>          pip
              08/02/2016  13:54                 0 THIS_IS_YOUR_HOME
              
              11 File(s)         34,690 bytes
               6 Dir(s)   2,640,445,440 bytes free

        - In *bash*, type:

          .. code-block:: console

            $ ls -l
            -rwxrwx---+ 1 username Domain Users   0 Feb  8  2016 THIS_IS_YOUR_HOME*
            -rwxrwx---+ 1 username Domain Users 14K Feb  7 09:43 co2mpas.log*
            drwxrwx---+ 1 username Domain Users   0 Nov 14 02:04 pip/


5. To check everything is ok, run the following 2 commands and see if their
   output is quasi-similar:

        - In *command-prompt*, type:

          .. code-block:: console

            REM The python-interpreter that comes 1st is what we care about.
            > where python
            D:\Apps\co2mpas_AIO-v1.5.0.b0\Apps\WinPython\python-3.5.3\python.exe
            D:\Apps\co2mpas_AIO-v1.5.0.b0\Apps\Cygwin\bin\python

            > co2mpas --version
            co2mpas-1.5.0 at D:\Apps\co2mpas_AIO-v1.5.0.b0\Apps\WinPython\python-3.5.2.amd64\lib\site-packages\co2mpas

        - In *bash*, type:

          .. code-block:: console

            > which python
            /cygdrive/d/Apps/co2mpas_AIO-v1.5.0.b0/Apps/WinPython/python-3.5.3/python

            > co2mpas --version
            co2mpas-1.5.0 at D:\Apps\co2mpas_AIO-v1.5.0.b0\Apps\WinPython\python-3.5.2.amd64\lib\site-packages\co2mpas

   In case of problems, copy-paste the output from the above commands and send
   it to JRC.


6. Follow the *Usage* instructions from the CO2MPAS-site:
   http://docs.co2mpas.io/  

   Demo files have been pre-generated for you, so certain commands might report
   that they cannot overwrite existing files.  Ignore the messages or use
   the `--force` option to overwrite them.

7. When a new CO2MPAS version is out, you may *upgrade* to it, and avoid
   re-downloading the *all-in-one* archive.  Read the respective sub-section
   of the *Installation* section from the documents.


Generic Tips
============

- You may freely move & copy this folder around.
  But prefer NOT TO HAVE SPACES IN THE PATH LEADING TO IT.

- To view & edit textual files, such as ``.txt``, ``.bat`` or config-files
  starting with dot(``.``), you may use the "ancient" Window *notepad* editor,
  but it will save you from  a lot of trouble if you download and install
  **notepad++** from: http://portableapps.com/apps/development/notepadpp_portable
  (no admin-rights needed).

  Even better if you combine it with the "gem" file-manager of the '90s,
  **TotalCommander**, from http://www.ghisler.com/ (no admin-rights needed).
  From inside this file-manager, ``F3`` key-shortcut views files.

- The **Cygwin** POSIX-environment and its accompanying **bash-shell** are
  a much better choice to give console-commands compare to `cmd.exe` prompt,
  supporting *auto-completion* for various commands (with ``[TAB]``key) and
  enhanced history search (with ``[UP]/[DOWN]`` cursor-keys).

  There are MANY tutorials and crash-courses for bash:

  - a concise one:
    http://www.ks.uiuc.edu/Training/Tutorials/Reference/unixprimer.html
  - a more detailed guide (just ignore the Linux-specific part):
    http://linuxcommand.org/lc3_lts0020.php
  - a useful poster with all fundamental bash-commands (eg. `ls`, `pwd`, `cd`):
    http://www.improgrammer.net/linux-commands-cheat-sheet/

- The console automatically copies into clipboard anything that is selected
  with the mouse.  In case of errors, copy and paste the commands and
  their error-messages and send them via email to JRC.

- When a new CO2MPAS version comes out it is not necessary to download the full
  ALLINONE archive, but you can choose instead to just *upgrade* the co2mpas package.

  Please follow the upgrade procedure in the main documentation.



File Contents
=============
::

    CO2MPAS.vbs                ## Launch CO2MPAS GUI.
    CONSOLE.vbs                ## Open a python+cygwin enabled `cmd.exe` console.

    INSTALL.vbs                ## Install ALLINONE on your Windows start-menu; needed to execute it only once.
    co2mpas-env.bat            ## Sets env-vars for python+cygwin and launches arguments as new command
                               ## !!!!! DO NOT MODIFY !!!!! used by Windows StartMenu shortcuts.


    CO2MPAS/                   ## User's HOME directory containing release-files and tutorial-folders.
    CO2MPAS/.*                 ## Configuration-files auto-generated by various programs, starting with dot(.).

    Apps/Cygwin/               ## Unix-folders for *Cygwin* environment (i.e. bash).
    Apps/WinPython/            ## Python environment (co2mpas is pre-installed inside it).
    Apps/Console/              ## A versatile console-window supporting decent copy-paste.
    Apps/graphviz/             ## Graph-plotting library (needed to plot the workflow of the model).
    Apps/GnuPG                 ## GPG cryptographic suite for Windows.
    Apps/vc_redist.x64.exe     ## Microsoft Visual C++ Redistributable for Visual Studio 2015
                               #  (KB2977003 Windows update, prerequisite for running Python-3.5.x).
    Apps/CO2MPAS_logo.ico      ## The logos used by the INSTALL.bat script.

    README                     ## This file, with instructions on this pre-populated folder.

