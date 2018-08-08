Python-wheels for older AIOs that are hard to find these days...
For example, to downgrade co2mpas, ``cd`` to its source-folder and issue::

    pip install  -r ./requirements/exe.pip  --find-links file:$AIODIR/Apps/wheelhouse/
