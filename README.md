CoolProp2Modelica-library
=========================
The CoolProp2Modelica library provides a connection between the external open-source property database CoolProp and the Modelica.Media package.

Current release
=========================
The latest version of CoolProp has been integrated into the [ExternalMedia library](https://github.com/modelica/ExternalMedia).

In order to get ExternalMedia working on your computer, You need to check out the sources for ExternalMedia using SVN from https://svn.modelica.org/projects/ExternalMediaLibrary/trunk

## Dymola under windows:
Once the ExternalMediaLibrary is on your computer you need to build the ExternalMediaLib.lib. In ExternalMediaLibrary\Projects\ double-click on BuildLib-Dymola-VS20XX depending on your current version of VisualStudio. This will build the ExternalMediaLib.lib file in ExternalMediaLibrary\Modelica\ExternalMedia 3.2.1\Resources\Library\win32

Check that no old version of ExternalMedia.lib file are stored in your Dymola/bin/lib directory.

Alternatively, you can download the precompiled binary files from  [github](https://github.com/modelica/ExternalMedia/archive/master.zip).  On windows, in the Modelica/ExternalMedia 3.2.1/Resources/Library/win32 folder, copy the ExternalMedia ExternalMediaLib.Dymola-VS2008.lib to ExternalMedia ExternalMediaLib.lib if you are using visual studio 2008 for instance.  Same idea if you use Visual Studio 2010/2012, etc.

You can now load the library by opening Modelica/ExteralMedia 3.2.1/package.mo file

## OpenModelica under windows - Linux users:

See the intallation.txt file in [ExternalMedia library](https://github.com/modelica/ExternalMedia). for installation instructions

## EXAMPLES:DEFINE A COOLPROP FLUID PACKAGE USING THE EXTERNALMEDIA LIBRARY

CoolPropMedium:

```
package R407c_CP_ExtMed "R134c - Coolprop - TC"
  extends ExternalMedia.Media.CoolPropMedium (
    mediumName = "R407c",
    substanceNames = {"R407c"},
    ThermoStates=Modelica.Media.Interfaces.PartialMedium.Choices.IndependentVariables.ph);
end R407c_CP_ExtMed;
```
IncompressibleCoolPropMedium:
```
package DowQ_CP "DowthermQ properties from CoolProp"
  extends ExternalMedia.Media.IncompressibleCoolPropMedium(
  mediumName="DowQ",
  substanceNames={"DowQ|calc_transport=1"},
  ThermoStates=Modelica.Media.Interfaces.PartialMedium.Choices.IndependentVariables.pT);
end DowQ_CP;
```
For other examples the user is redirected to the Test package of the ExternalMedia library
