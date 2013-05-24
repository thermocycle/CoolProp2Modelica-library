within CoolProp2Modelica.Media;
package SES36_CP "Solkatherm properties using CoolProp"
  extends CoolProp2Modelica.Interfaces.ExternalTwoPhaseMedium(
  mediumName="SES36",
  libraryName="CoolProp",
  substanceName="SES36",
  ThermoStates=Modelica.Media.Interfaces.PartialMedium.Choices.IndependentVariables.ph);

  annotation ();
end SES36_CP;
