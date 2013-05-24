within CoolProp2Modelica.Media;
package R290_FPST "Propane properties using the StanMix library of FluidProp"
  extends CoolProp2Modelica.Interfaces.ExternalTwoPhaseMedium(
  mediumName="TestMedium",
  libraryName="FluidProp.StanMix",
  substanceName="propane",
  ThermoStates=Modelica.Media.Interfaces.PartialMedium.Choices.IndependentVariables.ph);

  annotation ();
end R290_FPST;
