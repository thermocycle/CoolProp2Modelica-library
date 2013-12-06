within CoolProp2Modelica.Media;
package LiBr_CP "Lithium bromide solution properties from CoolProp"
  extends CoolProp2Modelica.Interfaces.IncompressibleCoolPropMedium(
  mediumName="LiBr",
  substanceNames={"LiBr|calc_transport=1"},
  ThermoStates=Modelica.Media.Interfaces.PartialMedium.Choices.IndependentVariables.pTX);
end LiBr_CP;
