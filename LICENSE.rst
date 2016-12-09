##########################
CO2MPAS ALLINONE Licensing
##########################

The *CO2MPAS simulator*, both executable and its sources, is distributed under the EUPL license.
EUPL is "eventually" compatible[1]_ with all major open-source licenses,
whether copy-lefted or not, but in reality CO2MPAS does not contain any prior code
to derive from - all the code is a property of JRC's and covered by the said license.


The *ALLINONE archive* contains many python libraries installed in its standard python -folder,
(``co2mpas_ALLINONE-XXX\Apps\WinPython\python-YYY.amd64\Lib\``)
so CO2MPAS only "links dynamically"[2]_ to them. 
A non-exhaustive list of python-libraries contained is listed in WinPython site[3]_
plus those manually installed by JRC when installing CO2MPAS in ALLINONE.
We are certain that all of them are open-source and can be freely re-distributed.

The ALLINONE contains also *"external programs"*, all of them open-source,
except from the MS redistributable (``Apps/vc_redist.x64.exe`` file)
which is explicitly exempted from the usual restrictive MS Licenses[4]_.


All the *logo and graphic work* is our own, but without having registered for trademark;
we are discouraged by the EU guidelines on the subject; subsequently we discourage
their use without our consent, beyond their intended usage, which is to run CO2MPAS.

.. [1] https://joinup.ec.europa.eu/community/eupl/og_page/eupl-compatible-open-source-licences
.. [2] https://joinup.ec.europa.eu/community/eupl/og_page/eupl-compatible-open-source-licences#section-3
.. [3] https://github.com/winpython/winpython/blob/master/changelogs/WinPython-3.5.2.1.md
.. [4] https://msdn.microsoft.com/en-us/library/ms235299.aspx