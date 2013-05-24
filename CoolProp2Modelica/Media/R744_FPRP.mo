within CoolProp2Modelica.Media;
package R744_FPRP "Carbon-Dioxide from Refprop via FluidProp"
  extends CoolProp2Modelica.Interfaces.FluidPropMedium(
  mediumName="Carbon Dioxide",
  libraryName="FluidProp.RefProp",
  substanceNames={"CO2"},
  ThermoStates=Modelica.Media.Interfaces.PartialMedium.Choices.IndependentVariables.ph);
end R744_FPRP;
