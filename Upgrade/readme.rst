File Contents
==============
::
    upgrade-script          : 
    Packfiles/              : upgrade-pack's root
    Packfiles/AIO/          : overlay ontop of AIO-to-upgrade
    Packfiles/wheelhouse/   : (untracked) upgrade-pack's wheels
    wheelhouse/             : (untracked) repository of wheels
    wheels.list             : wheels to copy wheelhouse/ --> Packfiles/wheelhouse/
    
Populate *wheelhouse* with::

    pip wheel --no-deps -r co2mpas.git/requirements/exe.pip -w ./wheelhouse/ --find-links file:./wheelhouse/


