within CoolProp2Modelica.Interfaces;
partial package CoolPropMedium
  extends ExternalTwoPhaseMedium(
  final mediumName =     "CoolPropMedium",
  final libraryName =    "CoolProp");

  import CoolProp2Modelica.Common.InputChoice;
  redeclare replaceable model extends BaseProperties
  equation
    if (basePropertiesInputChoice == InputChoice.hs) then
      state = setState_hs(h, s, phaseInput);
      d = density(state);
      p = pressure(state);
      T = temperature(state);
    end if;
  end BaseProperties;

replaceable function setState_hs
    "Return thermodynamic state record from h and s"
  extends Modelica.Icons.Function;
  input SpecificEnthalpy h "specific enthalpy";
  input SpecificEntropy s "specific entropy";
  input FixedPhase phase = 0 "2 for two-phase, 1 for one-phase, 0 if not known";
  output ThermodynamicState state;
external "C" TwoPhaseMedium_setState_hs_(h, s, phase, state, mediumName, libraryName, substanceName)
  annotation(Include="#include <CoolPropLib.h>", Library="CoolPropLib");
end setState_hs;

replaceable function setState_hsX
                                  extends Modelica.Icons.Function;
  input SpecificEnthalpy h "specific enthalpy";
  input SpecificEntropy s "specific entropy";
  input FixedPhase phase = 0 "2 for two-phase, 1 for one-phase, 0 if not known";
  output ThermodynamicState state;
algorithm
  // The composition is an empty vector
  state :=setState_hs(h, s, phase);
end setState_hsX;

replaceable function density_hs "Return density from h and s"
  extends Modelica.Icons.Function;
  input SpecificEnthalpy h "Specific enthalpy";
  input SpecificEntropy s "Specific entropy";
  input FixedPhase phase = 0 "2 for two-phase, 1 for one-phase, 0 if not known";
  output Density d "Density";
algorithm
  d := density(setState_hs(h, s, phase));
  // To be implemented:
  //     annotation(derivative(noDerivative = phase) = density_hs_der,
  //                Inline = true);
end density_hs;

replaceable function temperature_hs "Return temperature from h and s"
  extends Modelica.Icons.Function;
  input SpecificEnthalpy h "Specific enthalpy";
  input SpecificEntropy s "Specific entropy";
  input FixedPhase phase = 0 "2 for two-phase, 1 for one-phase, 0 if not known";
  output Temperature T "Temperature";
algorithm
  T := temperature(setState_hs(h, s, phase));
  annotation(Inline = true);
end temperature_hs;

replaceable function pressure_hs "Return pressure from h and s"
  extends Modelica.Icons.Function;
  input SpecificEnthalpy h "Specific enthalpy";
  input SpecificEntropy s "Specific entropy";
  input FixedPhase phase = 0 "2 for two-phase, 1 for one-phase, 0 if not known";
  output AbsolutePressure p "Pressure";
algorithm
  p := pressure(setState_hs(h,s, phase));
  annotation(Inline = true);
end pressure_hs;

redeclare replaceable function extends isentropicExponent
    "Return isentropic exponent"
  extends Modelica.Icons.Function;
  input ThermodynamicState state "thermodynamic state record";
  output IsentropicExponent gamma "Isentropic exponent";
algorithm
  gamma := density(state) / pressure(state) * velocityOfSound(state) * velocityOfSound(state);
end isentropicExponent;

redeclare replaceable function extends specificInternalEnergy
    "Returns specific internal energy"
  extends Modelica.Icons.Function;
  input ThermodynamicState state "thermodynamic state record";
  output SpecificInternalEnergy u "specific internal energy";
algorithm
  u := specificEnthalpy(state) - pressure(state)/density(state);
end specificInternalEnergy;

end CoolPropMedium;
