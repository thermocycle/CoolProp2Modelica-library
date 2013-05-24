within CoolProp2Modelica.Media;
package R718_CP "R718, water IAPWS 95 properties using CoolProp"
  extends CoolProp2Modelica.Interfaces.ExternalTwoPhaseMedium(
  mediumName="Water",
  libraryName="CoolProp",
  substanceNames={"Water"},
  ThermoStates=Modelica.Media.Interfaces.PartialMedium.Choices.IndependentVariables.ph);

  annotation ();
end R718_CP;
