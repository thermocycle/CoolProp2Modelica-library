within CoolProp2Modelica.Media;
package R600a_CP "R600a, Isobutane properties using CoolProp"
  extends CoolProp2Modelica.Interfaces.ExternalTwoPhaseMedium(
  mediumName="Isobutane",
  libraryName="CoolProp",
  substanceNames={"IsoButane"},
  ThermoStates=Modelica.Media.Interfaces.PartialMedium.Choices.IndependentVariables.ph);


  annotation ();
end R600a_CP;
