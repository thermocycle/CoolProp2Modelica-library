within CoolProp2Modelica.Media;
package TestMedium "Simple water medium model for debugging and testing"
  extends CoolProp2Modelica.Interfaces.ExternalTwoPhaseMedium(
  mediumName="TestMedium",
  libraryName="TestMedium",
  ThermoStates=Modelica.Media.Interfaces.PartialMedium.Choices.IndependentVariables.pT);
end TestMedium;
