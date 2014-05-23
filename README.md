CoolProp2Modelica-library
=========================
The CoolProp2Modelica library provides a connection between the external open-source property database CoolProp and the Modelica.Media package.

Current release
=========================
The latest version of CoolProp has been integrated into the [ExternalMedia library](https://github.com/modelica/ExternalMedia).

In order to get ExternalMedia working on your computer, You need to check out the sources for ExternalMedia using SVN from https://svn.modelica.org/projects/ExternalMediaLibrary/trunk

### Dymola under windows:
Once the ExternalMediaLibrary is on your computer you need to build the ExternalMediaLib.lib. In ExternalMediaLibrary\Projects\ double-click on BuildLib-Dymola-VS20XX depending on your current version of VisualStudio. This will build the ExternalMediaLib.lib file in ExternalMediaLibrary\Modelica\ExternalMedia 3.2.1\Resources\Library\win32

Check that no old version of ExternalMedia.lib file are stored in your Dymola/bin/lib directory.


You can now load the library by opening Modelica/ExteralMedia 3.2.1/package.mo file

### OpenModelica under windows - Linux users:

See the intallation.txt file in [ExternalMedia library](https://github.com/modelica/ExternalMedia). for installation instructions

