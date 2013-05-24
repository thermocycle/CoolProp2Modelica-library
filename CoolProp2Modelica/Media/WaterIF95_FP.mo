within CoolProp2Modelica.Media;
package WaterIF95_FP
  extends CoolProp2Modelica.Interfaces.FluidPropMedium(
  mediumName="Water",
  libraryName="FluidProp.RefProp",
  substanceNames={"H2O"},
  ThermoStates=Modelica.Media.Interfaces.PartialMedium.Choices.IndependentVariables.ph);
end WaterIF95_FP;
