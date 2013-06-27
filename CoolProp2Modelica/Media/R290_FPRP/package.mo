within CoolProp2Modelica.Media;
package R290_FPRP "Propane properties using Refprop through FluidProp (requires the full version of FluidProp)"
  extends CoolProp2Modelica.Interfaces.ExternalTwoPhaseMedium(
  mediumName="TestMedium",
  libraryName="FluidProp.RefProp",
  substanceName="propane",
  ThermoStates=Modelica.Media.Interfaces.PartialMedium.Choices.IndependentVariables.ph);


  annotation ();
end R290_FPRP;
