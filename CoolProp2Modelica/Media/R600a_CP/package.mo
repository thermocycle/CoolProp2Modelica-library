within CoolProp2Modelica.Media;
package R600a_CP "R600a, Isobutane properties using CoolProp"
  extends CoolProp2Modelica.Interfaces.CoolPropMedium(
  mediumName="Isobutane",
  substanceNames={"IsoButane"},
  ThermoStates=Modelica.Media.Interfaces.PartialMedium.Choices.IndependentVariables.ph);

  annotation ();
end R600a_CP;
