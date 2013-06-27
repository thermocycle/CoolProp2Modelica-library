within CoolProp2Modelica.Media;
package R290_CP "R290, computation of Propane Properties using CoolProp"
  extends CoolProp2Modelica.Interfaces.ExternalTwoPhaseMedium(
  mediumName="TestMedium",
  libraryName="CoolProp",
  substanceName="propane",
  ThermoStates=Modelica.Media.Interfaces.PartialMedium.Choices.IndependentVariables.ph);


  annotation ();
end R290_CP;
