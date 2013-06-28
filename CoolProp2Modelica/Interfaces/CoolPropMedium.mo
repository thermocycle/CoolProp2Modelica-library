within CoolProp2Modelica.Interfaces;
partial package CoolPropMedium
  extends ExternalTwoPhaseMedium(
  mediumName = "CoolPropMedium",
  final libraryName = "CoolProp");

  redeclare replaceable model extends BaseProperties(
    p(stateSelect = if preferredMediumStates and
                       (basePropertiesInputChoiceCP == InputChoiceCoolProp.ph or
                        basePropertiesInputChoiceCP == InputChoiceCoolProp.pT or
                        basePropertiesInputChoiceCP == InputChoiceCoolProp.ps) then
                            StateSelect.prefer else StateSelect.default),
    T(stateSelect = if preferredMediumStates and
                       (basePropertiesInputChoiceCP == InputChoiceCoolProp.pT or
                        basePropertiesInputChoiceCP == InputChoiceCoolProp.dT) then
                         StateSelect.prefer else StateSelect.default),
    h(stateSelect = if preferredMediumStates and
                       (basePropertiesInputChoiceCP == InputChoiceCoolProp.ph or
                        basePropertiesInputChoiceCP == InputChoiceCoolProp.hs) then
                         StateSelect.prefer else StateSelect.default),
    d(stateSelect = if preferredMediumStates and
                       basePropertiesInputChoiceCP == InputChoiceCoolProp.dT then
                         StateSelect.prefer else StateSelect.default))
  import CoolProp2Modelica.Common.InputChoiceCoolProp;
  constant InputChoiceCoolProp inputChoiceCP=InputChoiceCoolProp.ph;
  redeclare parameter InputChoiceCoolProp basePropertiesInputChoiceCP = inputChoiceCP
      "Choice of input variables for property computations";
    FixedPhase phaseInput
      "Phase input for property computation functions, 2 for two-phase, 1 for one-phase, 0 if not known";
    Integer phaseOutput
      "Phase output for medium, 2 for two-phase, 1 for one-phase";
    SpecificEntropy s(
      stateSelect = if (basePropertiesInputChoiceCP == InputChoiceCoolProp.ps or
                        basePropertiesInputChoiceCP == InputChoiceCoolProp.hs) then
                       StateSelect.prefer else StateSelect.default)
      "Specific entropy";
    SaturationProperties sat "saturation property record";
  equation
    MM = externalFluidConstants.molarMass;
    R = Modelica.Constants.R/MM;
    if (onePhase or (basePropertiesInputChoiceCP == InputChoiceCoolProp.pT)) then
      phaseInput = 1 "Force one-phase property computation";
    else
      phaseInput = 0 "Unknown phase";
    end if;
    if (basePropertiesInputChoiceCP == InputChoiceCoolProp.ph) then
      // Compute the state record (including the unique ID)
      state = setState_ph(p, h, phaseInput);
      // Modification of the ExternalMedia code to reduce the number of calls:
      // SQ, January 2013:
      d = density(state);
      T = temperature(state);
      s = specificEntropy(state);
    elseif (basePropertiesInputChoiceCP == InputChoiceCoolProp.dT) then
      state = setState_dT(d, T, phaseInput);
      h = specificEnthalpy(state);
      p = pressure(state);
      s = specificEntropy(state);
    elseif (basePropertiesInputChoiceCP == InputChoiceCoolProp.pT) then
      state = setState_pT(p, T, phaseInput);
      d = density(state);
      h = specificEnthalpy(state);
      s = specificEntropy(state);
    elseif (basePropertiesInputChoiceCP == InputChoiceCoolProp.ps) then
      state = setState_ps(p, s, phaseInput);
      d = density(state);
      h = specificEnthalpy(state);
      T = temperature(state);
    elseif (basePropertiesInputChoiceCP == InputChoiceCoolProp.hs) then
      state = setState_hs(h, s, phaseInput);
      d = density(state);
      p = pressure(state);
      T = temperature(state);
    end if;
    // Compute the internal energy
    u = h - p/d;
    // Compute the saturation properties record
    sat = setSat_p_state(state);
    // Event generation for phase boundary crossing
     if smoothModel then
      // No event generation
      phaseOutput = state.phase;
     else
       // Event generation at phase boundary crossing
       if basePropertiesInputChoiceCP == InputChoiceCoolProp.ph then
         phaseOutput = if ((h > bubbleEnthalpy(sat) and h < dewEnthalpy(sat)) and
                            p < fluidConstants[1].criticalPressure) then 2 else 1;
       elseif basePropertiesInputChoiceCP == InputChoiceCoolProp.dT then
         phaseOutput = if ((d < bubbleDensity(sat) and d > dewDensity(sat)) and
                             T < fluidConstants[1].criticalTemperature) then 2 else 1;
       elseif basePropertiesInputChoiceCP == InputChoiceCoolProp.ps then
         phaseOutput = if ((s > bubbleEntropy(sat) and s < dewEntropy(sat)) and
                            p < fluidConstants[1].criticalPressure) then 2 else 1;
       elseif basePropertiesInputChoiceCP == InputChoiceCoolProp.hs then
         phaseOutput = if ((s > bubbleEntropy(sat) and s < dewEntropy(sat)) and
                           p < fluidConstants[1].criticalPressure) then 2 else 1;
       else
         // basePropertiesInputChoiceCP == pT
         phaseOutput = 1;
       end if;
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

end CoolPropMedium;
