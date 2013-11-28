within CoolProp2Modelica.Media;
package R134a_CP "R134a properties from CoolProp"
  extends CoolProp2Modelica.Interfaces.CoolPropMedium(
  mediumName="R134a",
  substanceNames={"R134a"},
  ThermoStates=Modelica.Media.Interfaces.PartialMedium.Choices.IndependentVariables.ph);
end R134a_CP;
