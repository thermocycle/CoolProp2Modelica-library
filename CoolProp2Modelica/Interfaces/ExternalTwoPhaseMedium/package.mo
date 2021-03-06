within CoolProp2Modelica.Interfaces;
partial package ExternalTwoPhaseMedium "Generic external two phase medium package"
  extends Modelica.Media.Interfaces.PartialTwoPhaseMedium(
    mediumName = "ExternalMedium",
    singleState = false,
    onePhase = false,
    smoothModel = false,
    fluidConstants = {externalFluidConstants});
import CoolProp2Modelica.Common.InputChoice;
  constant String libraryName = "UnusableExternalMedium"
  "Name of the external fluid property computation library";
  constant String substanceName = substanceNames[1]
  "Only one substance can be specified";


  redeclare record extends FluidConstants "external fluid constants"
    MolarMass molarMass "molecular mass";
    Temperature criticalTemperature "critical temperature";
    AbsolutePressure criticalPressure "critical pressure";
    MolarVolume criticalMolarVolume "critical molar Volume";
  end FluidConstants;
  constant FluidConstants externalFluidConstants = FluidConstants(
    iupacName=            "unknown",
    casRegistryNumber=    "unknown",
    chemicalFormula=      "unknown",
    structureFormula=     "unknown",
    molarMass=            getMolarMass(),
    criticalTemperature=  getCriticalTemperature(),
    criticalPressure=     getCriticalPressure(),
    criticalMolarVolume=  getCriticalMolarVolume(),
    acentricFactor=       0,
    triplePointTemperature=  280.0,
    triplePointPressure=  500.0,
    meltingPoint=         280,
    normalBoilingPoint=   380.0,
    dipoleMoment=         2.0);
  constant InputChoice inputChoice=InputChoice.ph
  "Default choice of input variables for property computations";


  redeclare replaceable record ThermodynamicState
    FixedPhase phase(min=0,max=2,start=0);                                                   //SQmodif: removed "extends" and added FixedPhase with start value
    PrandtlNumber Pr "prandtl number";
    Temperature T "temperature";
    VelocityOfSound a "velocity of sound";
    Modelica.SIunits.CubicExpansionCoefficient beta
    "isobaric expansion coefficient";
    SpecificHeatCapacity cp "specific heat capacity cp";
    SpecificHeatCapacity cv "specific heat capacity cv";
    Density d "density";
    DerDensityByEnthalpy ddhp
    "derivative of density wrt enthalpy at constant pressure";
    DerDensityByPressure ddph
    "derivative of density wrt pressure at constant enthalpy";
    DynamicViscosity eta "dynamic viscosity";
    SpecificEnthalpy h "specific enthalpy";
    Modelica.SIunits.Compressibility kappa "compressibility";
    ThermalConductivity lambda "thermal conductivity";
    AbsolutePressure p "pressure";
    SpecificEntropy s "specific entropy";
  end ThermodynamicState;


  redeclare record extends SaturationProperties
    Temperature Tsat "saturation temperature";
    Real dTp "derivative of Ts wrt pressure";
    DerDensityByPressure ddldp "derivative of dls wrt pressure";
    DerDensityByPressure ddvdp "derivative of dvs wrt pressure";
    DerEnthalpyByPressure dhldp "derivative of hls wrt pressure";
    DerEnthalpyByPressure dhvdp "derivative of hvs wrt pressure";
    Density dl "density at bubble line (for pressure ps)";
    Density dv "density at dew line (for pressure ps)";
    SpecificEnthalpy hl "specific enthalpy at bubble line (for pressure ps)";
    SpecificEnthalpy hv "specific enthalpy at dew line (for pressure ps)";
    AbsolutePressure psat "saturation pressure";
    SurfaceTension sigma "surface tension";
    SpecificEntropy sl "specific entropy at bubble line (for pressure ps)";
    SpecificEntropy sv "specific entropy at dew line (for pressure ps)";
  end SaturationProperties;


  redeclare replaceable model extends BaseProperties(
    p(stateSelect = if preferredMediumStates and
                       (basePropertiesInputChoice == InputChoice.ph or
                        basePropertiesInputChoice == InputChoice.pT or
                        basePropertiesInputChoice == InputChoice.ps) then
                            StateSelect.prefer else StateSelect.default),
    T(stateSelect = if preferredMediumStates and
                       (basePropertiesInputChoice == InputChoice.pT or
                       basePropertiesInputChoice == InputChoice.dT) then
                         StateSelect.prefer else StateSelect.default),
    h(stateSelect = if preferredMediumStates and
                       basePropertiesInputChoice == InputChoice.ph then
                         StateSelect.prefer else StateSelect.default),
    d(stateSelect = if preferredMediumStates and
                       basePropertiesInputChoice == InputChoice.dT then
                         StateSelect.prefer else StateSelect.default))
    import CoolProp2Modelica.Common.InputChoice;
    parameter InputChoice basePropertiesInputChoice=inputChoice
    "Choice of input variables for property computations";
    FixedPhase phaseInput
    "Phase input for property computation functions, 2 for two-phase, 1 for one-phase, 0 if not known";
    Integer phaseOutput
    "Phase output for medium, 2 for two-phase, 1 for one-phase";
    SpecificEntropy s(
      stateSelect = if basePropertiesInputChoice == InputChoice.ps then
                       StateSelect.prefer else StateSelect.default)
    "Specific entropy";
    SaturationProperties sat "saturation property record";
  equation
    MM = externalFluidConstants.molarMass;
    R = Modelica.Constants.R/MM;
    if (onePhase or (basePropertiesInputChoice == InputChoice.pT)) then
      phaseInput = 1 "Force one-phase property computation";
    else
      phaseInput = 0 "Unknown phase";
    end if;
    if (basePropertiesInputChoice == InputChoice.ph) then
      // Compute the state record (including the unique ID)
      state = setState_ph(p, h, phaseInput);
      // Compute the remaining variables.
      // It is not possible to use the standard functions like
      // d = density(state), because differentiation for index
      // reduction and change of state variables would not be supported
      // density_ph(), which has an appropriate derivative annotation,
      // is used instead. The implementation of density_ph() uses
      // setState with the same inputs, so there's no actual overhead
      d = density_ph(p, h, phaseInput);
      s = specificEntropy_ph(p, h, phaseInput);
      T = temperature_ph(p, h, phaseInput);
    elseif (basePropertiesInputChoice == InputChoice.dT) then
      state = setState_dT(d, T, phaseInput);
      h = specificEnthalpy(state);
      p = pressure(state);
      s = specificEntropy(state);
    elseif (basePropertiesInputChoice == InputChoice.pT) then
      state = setState_pT(p, T, phaseInput);
      d = density(state);
      h = specificEnthalpy(state);
      s = specificEntropy(state);
    elseif (basePropertiesInputChoice == InputChoice.ps) then
      state = setState_ps(p, s, phaseInput);
      d = density(state);
      h = specificEnthalpy(state);
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
      if basePropertiesInputChoice == InputChoice.ph then
        phaseOutput = if ((h > bubbleEnthalpy(sat) and h < dewEnthalpy(sat)) and
                           p < fluidConstants[1].criticalPressure) then 2 else 1;
      elseif basePropertiesInputChoice == InputChoice.dT then
        phaseOutput = if ((d < bubbleDensity(sat) and d > dewDensity(sat)) and
                            T < fluidConstants[1].criticalTemperature) then 2 else 1;
      elseif basePropertiesInputChoice == InputChoice.ps then
        phaseOutput = if ((s > bubbleEntropy(sat) and s < dewEntropy(sat)) and
                           p < fluidConstants[1].criticalPressure) then 2 else 1;
      else
        // basePropertiesInputChoice == pT
        phaseOutput = 1;
      end if;
    end if;
  end BaseProperties;


  redeclare function molarMass "Return the molar mass of the medium"
      input ThermodynamicState state;
      output MolarMass MM "Mixture molar mass";
  algorithm
    MM := fluidConstants[1].molarMass;
  end molarMass;


  replaceable partial function getMolarMass
    output MolarMass MM "molar mass";
    external "C" MM=  TwoPhaseMedium_getMolarMass_(mediumName, libraryName, substanceName)
      annotation(Include="#include <CoolPropLib.h>", Library="CoolPropLib");
  end getMolarMass;


  replaceable partial function getCriticalTemperature
    output Temperature Tc "Critical temperature";
    external "C" Tc=  TwoPhaseMedium_getCriticalTemperature_(mediumName, libraryName, substanceName)
      annotation(Include="#include <CoolPropLib.h>", Library="CoolPropLib");
  end getCriticalTemperature;


  replaceable partial function getCriticalPressure
    output AbsolutePressure pc "Critical temperature";
    external "C" pc=  TwoPhaseMedium_getCriticalPressure_(mediumName, libraryName, substanceName)
      annotation(Include="#include <CoolPropLib.h>", Library="CoolPropLib");
  end getCriticalPressure;


  replaceable partial function getCriticalMolarVolume
    output MolarVolume vc "Critical molar volume";
    external "C" vc=  TwoPhaseMedium_getCriticalMolarVolume_(mediumName, libraryName, substanceName)
      annotation(Include="#include <CoolPropLib.h>", Library="CoolPropLib");
  end getCriticalMolarVolume;


  redeclare replaceable function setState_ph
  "Return thermodynamic state record from p and h"
    extends Modelica.Icons.Function;
    input AbsolutePressure p "pressure";
    input SpecificEnthalpy h "specific enthalpy";
    input FixedPhase phase = 0
    "2 for two-phase, 1 for one-phase, 0 if not known";
    output ThermodynamicState state;
  external "C" TwoPhaseMedium_setState_ph_(p, h, phase, state, mediumName, libraryName, substanceName)
    annotation(Include="#include <CoolPropLib.h>", Library="CoolPropLib");
  end setState_ph;


  redeclare replaceable function setState_pT
  "Return thermodynamic state record from p and T"
    extends Modelica.Icons.Function;
    input AbsolutePressure p "pressure";
    input Temperature T "temperature";
    input FixedPhase phase = 0
    "2 for two-phase, 1 for one-phase, 0 if not known";
    output ThermodynamicState state;
  external "C" TwoPhaseMedium_setState_pT_(p, T, state, mediumName, libraryName, substanceName)
    annotation(Include="#include <CoolPropLib.h>", Library="CoolPropLib");
  end setState_pT;


  redeclare replaceable function setState_dT
  "Return thermodynamic state record from d and T"
    extends Modelica.Icons.Function;
    input Density d "density";
    input Temperature T "temperature";
    input FixedPhase phase = 0
    "2 for two-phase, 1 for one-phase, 0 if not known";
    output ThermodynamicState state;
  external "C" TwoPhaseMedium_setState_dT_(d, T, phase, state, mediumName, libraryName, substanceName)
    annotation(Include="#include <CoolPropLib.h>", Library="CoolPropLib");
  end setState_dT;


  redeclare replaceable function setState_ps
  "Return thermodynamic state record from p and s"
    extends Modelica.Icons.Function;
    input AbsolutePressure p "pressure";
    input SpecificEntropy s "specific entropy";
    input FixedPhase phase = 0
    "2 for two-phase, 1 for one-phase, 0 if not known";
    output ThermodynamicState state;
  external "C" TwoPhaseMedium_setState_ps_(p, s, phase, state, mediumName, libraryName, substanceName)
    annotation(Include="#include <CoolPropLib.h>", Library="CoolPropLib");
  end setState_ps;


  replaceable function setSat_p_state
  "Return saturation properties from the state"
    extends Modelica.Icons.Function;
    input ThermodynamicState state;
    output SaturationProperties sat "saturation property record";
    // Standard definition
  algorithm
    sat:=setSat_p(state.p);
    //Redeclare this function for more efficient implementations avoiding the repeated computation of saturation properties
  /*  // If special definition in "C"
  external "C" TwoPhaseMedium_setSat_p_state_(state, sat)
    annotation(Include="#include <CoolPropLib.h>", Library="CoolPropLib");
*/
    annotation(Inline = true);
  end setSat_p_state;


  redeclare function extends setState_phX
  algorithm
    // The composition is an empty vector
    state :=setState_ph(p, h, phase);
  end setState_phX;


  redeclare function extends setState_pTX
  algorithm
    // The composition is an empty vector
    state :=setState_pT(p, T, phase);
  end setState_pTX;


  redeclare function extends setState_dTX
  algorithm
    // The composition is an empty vector
    state :=setState_dT(d, T, phase);
  end setState_dTX;


  redeclare function extends setState_psX
  algorithm
    // The composition is an empty vector
    state :=setState_ps(p, s, phase);
  end setState_psX;


  redeclare function density_ph "returns density for given p and h"
    extends Modelica.Icons.Function;
    input AbsolutePressure p "Pressure";
    input SpecificEnthalpy h "Enthalpy";
    input FixedPhase phase=0 "2 for two-phase, 1 for one-phase, 0 if not known";
  //input ThermodynamicState state;
    output Density d "density";
  algorithm
    d := density_ph_state(p=p, h=h, state=setState_ph(p=p, h=h, phase=phase));
  annotation (
    Inline=true);
  end density_ph;


  replaceable function density_ph_der "Total derivative of density_ph"
    extends Modelica.Icons.Function;
    input AbsolutePressure p "Pressure";
    input SpecificEnthalpy h "Specific enthalpy";
    input ThermodynamicState state;
    input Real p_der "time derivative of pressure";
    input Real h_der "time derivative of specific enthalpy";
    output Real d_der "time derivative of density";
  algorithm
    d_der := p_der*density_derp_h(state=state)
           + h_der*density_derh_p(state=state);
  annotation (Inline=true);
  end density_ph_der;


  redeclare replaceable function extends density_derh_p
  "Return derivative of density wrt enthalpy at constant pressure from state"
    // Standard definition
  algorithm
    ddhp := state.ddhp;
    /*  // If special definition in "C"
  external "C" ddhp=  TwoPhaseMedium_density_derh_p_(state, mediumName, libraryName, substanceName)
    annotation(Include="#include <CoolPropLib.h>", Library="CoolPropLib");
*/
    annotation(Inline = true);
  end density_derh_p;


  redeclare replaceable function extends density_derp_h
  "Return derivative of density wrt pressure at constant enthalpy from state"
    // Standard definition
  algorithm
    ddph := state.ddph;
    /*  // If special definition in "C"
  external "C" ddph=  TwoPhaseMedium_density_derp_h_(state, mediumName, libraryName, substanceName)
    annotation(Include="#include <CoolPropLib.h>", Library="CoolPropLib");
*/
    annotation(Inline = true);
  end density_derp_h;


  redeclare function temperature_ph "returns temperature for given p and h"
    extends Modelica.Icons.Function;
    input AbsolutePressure p "Pressure";
    input SpecificEnthalpy h "Enthalpy";
    input FixedPhase phase=0 "2 for two-phase, 1 for one-phase, 0 if not known";
    output Temperature T "Temperature";
  algorithm
    T := temperature_ph_state(p=p, h=h, state=setState_ph(p=p, h=h, phase=phase));
  annotation (
    Inline=true,
    inverse(h=specificEnthalpy_pT(p=p, T=T, phase=phase)));
  end temperature_ph;


    function specificEntropy_ph "returns specific entropy for a given p and h"
    extends Modelica.Icons.Function;
    input AbsolutePressure p "Pressure";
    input SpecificEnthalpy h "Specific Enthalpy";
    input FixedPhase phase=0 "2 for two-phase, 1 for one-phase, 0 if not known";
    output SpecificEntropy s "Specific Entropy";
    algorithm
    s := specificEntropy_ph_state(p=p, h=h, state=setState_ph(p=p, h=h, phase=phase));
    annotation (
    Inline=true,
    inverse(h=specificEnthalpy_ps(p=p, s=s, phase=phase)));
    end specificEntropy_ph;


  redeclare function density_pT "Return density from p and T"
    extends Modelica.Icons.Function;
    input AbsolutePressure p "Pressure";
    input Temperature T "Temperature";
    input FixedPhase phase=0 "2 for two-phase, 1 for one-phase, 0 if not known";
    output Density d "Density";
  algorithm
    d := density_pT_state(p=p, T=T, state=setState_pT(p=p, T=T, phase=phase));
  annotation (
    Inline=true,
    inverse(p=pressure_dT(d=d, T=T, phase=phase)));
  end density_pT;


  redeclare function specificEnthalpy_pT
  "returns specific enthalpy for given p and T"
    extends Modelica.Icons.Function;
    input AbsolutePressure p "Pressure";
    input Temperature T "Temperature";
    input FixedPhase phase=0 "2 for two-phase, 1 for one-phase, 0 if not known";
    output SpecificEnthalpy h "specific enthalpy";
  algorithm
    h := specificEnthalpy_pT_state(p=p, T=T, state=setState_pT(p=p, T=T, phase=phase));
  annotation (
    Inline=true,
    inverse(T=temperature_ph(p=p, h=h, phase=phase)));
  end specificEnthalpy_pT;


    redeclare function pressure_dT
    extends Modelica.Icons.Function;
    input Density d "Density";
    input Temperature T "Temperature";
    input FixedPhase phase=0 "2 for two-phase, 1 for one-phase, 0 if not known";
    output AbsolutePressure p "pressure";
    algorithm
    p := pressure_dT_state(d=d, T=T, state=setState_dT(d=d, T=T, phase=phase));
    annotation (
    Inline=true,
    inverse(d=density_pT(p=p, T=T, phase=phase)));
    end pressure_dT;


  redeclare function specificEnthalpy_dT
    extends Modelica.Icons.Function;
    input Density d "Density";
    input Temperature T "Temperature";
    input FixedPhase phase=0 "2 for two-phase, 1 for one-phase, 0 if not known";
    output SpecificEnthalpy h "Specific Enthalpy";
  algorithm
    h := specificEnthalpy_dT_state(d=d, T=T, state=setState_dT(d=d, T=T, phase=phase));
  annotation (
    Inline=true);
  end specificEnthalpy_dT;


  redeclare replaceable function density_ps "Return density from p and s"
    extends Modelica.Icons.Function;
    input AbsolutePressure p "Pressure";
    input SpecificEntropy s "Specific entropy";
    input FixedPhase phase = 0
    "2 for two-phase, 1 for one-phase, 0 if not known";
    output Density d "Density";
  algorithm
    d := density_ps_state(p=p, s=s, state=setState_ps(p=p, s=s, phase=phase));
  annotation (
    Inline=true);
  end density_ps;


  redeclare replaceable function specificEnthalpy_ps
  "Return specific enthalpy from p and s"
    extends Modelica.Icons.Function;
    input AbsolutePressure p "Pressure";
    input SpecificEntropy s "Specific entropy";
    input FixedPhase phase = 0
    "2 for two-phase, 1 for one-phase, 0 if not known";
    output SpecificEnthalpy h "specific enthalpy";
  algorithm
    h := specificEnthalpy_ps_state(p=p, s=s, state=setState_ps(p=p, s=s, phase=phase));
    annotation (
    Inline = true,
    inverse(s=specificEntropy_ph(p=p, h=h, phase=phase)));
  end specificEnthalpy_ps;


  redeclare function temperature_ps "returns temperature for given p and s"
    extends Modelica.Icons.Function;
    input AbsolutePressure p "Pressure";
    input SpecificEntropy s "Specific entropy";
    input FixedPhase phase=0 "2 for two-phase, 1 for one-phase, 0 if not known";
    output Temperature T "Temperature";
  algorithm
    T := temperature_ps_state(p=p, s=s, state=setState_ps(p=p, s=s, phase=phase));
  annotation (
    Inline=true,
    inverse(s=specificEntropy_pT(p=p, T=T, phase=phase)));
  end temperature_ps;


  redeclare replaceable function extends density "Return density from state"
    // Standard definition
  algorithm
    d := state.d;
    annotation(Inline = true);
  end density;


  redeclare replaceable function extends pressure "Return pressure from state"
    // Standard definition
  algorithm
    p := state.p;
    /*  // If special definition in "C"
  external "C" p=  TwoPhaseMedium_pressure_(state, mediumName, libraryName, substanceName)
    annotation(Include="#include <CoolPropLib.h>", Library="CoolPropLib");
*/
    annotation(Inline = true);
  end pressure;


  redeclare replaceable function extends specificEnthalpy
  "Return specific enthalpy from state"
    // Standard definition
  algorithm
    h := state.h;
    annotation(Inline = true);
  end specificEnthalpy;


  redeclare replaceable function extends specificEntropy
  "Return specific entropy from state"
    // Standard definition
  algorithm
    s := state.s;
    annotation(Inline = true);
  end specificEntropy;


  redeclare replaceable function extends temperature
  "Return temperature from state"
    // Standard definition
  algorithm
    T := state.T;
    annotation(Inline = true);
  end temperature;


  redeclare function extends prandtlNumber
    /*  // If special definition in "C"
  external "C" T=  TwoPhaseMedium_prandtlNumber_(state, mediumName, libraryName, substanceName)
    annotation(Include="#include <CoolPropLib.h>", Library="CoolPropLib");
*/
    annotation(Inline = true);
  end prandtlNumber;


  redeclare replaceable function extends velocityOfSound
  "Return velocity of sound from state"
    // Standard definition
  algorithm
    a := state.a;
    /*  // If special definition in "C"
  external "C" a=  TwoPhaseMedium_velocityOfSound_(state, mediumName, libraryName, substanceName)
    annotation(Include="#include <CoolPropLib.h>", Library="CoolPropLib");
*/
    annotation(Inline = true);
  end velocityOfSound;


  redeclare replaceable function extends isobaricExpansionCoefficient
  "Return isobaric expansion coefficient from state"
    // Standard definition
  algorithm
    beta := state.beta;
    /*  // If special definition in "C"
  external "C" beta=  TwoPhaseMedium_isobaricExpansionCoefficient_(state, mediumName, libraryName, substanceName)
    annotation(Include="#include <CoolPropLib.h>", Library="CoolPropLib");
*/
    annotation(Inline = true);
  end isobaricExpansionCoefficient;


  redeclare replaceable function extends specificHeatCapacityCp
  "Return specific heat capacity cp from state"
    // Standard definition
  algorithm
    cp := state.cp;
    /*  // If special definition in "C"
  external "C" cp=  TwoPhaseMedium_specificHeatCapacityCp_(state, mediumName, libraryName, substanceName)
    annotation(Include="#include <CoolPropLib.h>", Library="CoolPropLib");
*/
    annotation(Inline = true);
  end specificHeatCapacityCp;


  redeclare replaceable function extends specificHeatCapacityCv
  "Return specific heat capacity cv from state"
    // Standard definition
  algorithm
    cv := state.cv;
    /*  // If special definition in "C"
  external "C" cv=  TwoPhaseMedium_specificHeatCapacityCv_(state, mediumName, libraryName, substanceName)
    annotation(Include="#include <CoolPropLib.h>", Library="CoolPropLib");
*/
    annotation(Inline = true);
  end specificHeatCapacityCv;


  redeclare replaceable function extends dynamicViscosity
  "Return dynamic viscosity from state"
    // Standard definition
  algorithm
    eta := state.eta;
    /*  // If special definition in "C"
  external "C" eta=  TwoPhaseMedium_dynamicViscosity_(state, mediumName, libraryName, substanceName)
    annotation(Include="#include <CoolPropLib.h>", Library="CoolPropLib");
*/
    annotation(Inline = true);
  end dynamicViscosity;


  redeclare replaceable function extends isothermalCompressibility
  "Return isothermal compressibility from state"
    // Standard definition
  algorithm
    kappa := state.kappa;
    /*  // If special definition in "C"
  external "C" kappa=  TwoPhaseMedium_isothermalCompressibility_(state, mediumName, libraryName, substanceName)
    annotation(Include="#include <CoolPropLib.h>", Library="CoolPropLib");
*/
    annotation(Inline = true);
  end isothermalCompressibility;


  redeclare replaceable function extends thermalConductivity
  "Return thermal conductivity from state"
    // Standard definition
  algorithm
    lambda := state.lambda;
    /*  // If special definition in "C"
  external "C" lambda=  TwoPhaseMedium_thermalConductivity_(state, mediumName, libraryName, substanceName)
    annotation(Include="#include <CoolPropLib.h>", Library="CoolPropLib");
*/
    annotation(Inline = true);
  end thermalConductivity;


  redeclare replaceable function extends isentropicEnthalpy
  external "C" h_is=  TwoPhaseMedium_isentropicEnthalpy_(p_downstream, refState,
   mediumName, libraryName, substanceName)
    annotation(Include="#include <CoolPropLib.h>", Library="CoolPropLib");
  end isentropicEnthalpy;


  redeclare replaceable function setSat_p "Return saturation properties from p"
    extends Modelica.Icons.Function;
    input AbsolutePressure p "pressure";
    output SaturationProperties sat "saturation property record";
  external "C" TwoPhaseMedium_setSat_p_(p, sat, mediumName, libraryName, substanceName)
    annotation(Include="#include <CoolPropLib.h>", Library="CoolPropLib");
  end setSat_p;


  redeclare replaceable function setSat_T "Return saturation properties from p"
    extends Modelica.Icons.Function;
    input Temperature T "temperature";
    output SaturationProperties sat "saturation property record";
  external "C" TwoPhaseMedium_setSat_T_(T, sat, mediumName, libraryName, substanceName)
    annotation(Include="#include <CoolPropLib.h>", Library="CoolPropLib");
  end setSat_T;


  redeclare replaceable function extends setBubbleState
  "set the thermodynamic state on the bubble line"
    extends Modelica.Icons.Function;
    input SaturationProperties sat "saturation point";
    input FixedPhase phase =  1 "phase: default is one phase";
    output ThermodynamicState state "complete thermodynamic state info";
    // Standard definition
  algorithm
    state :=setState_ph(sat.psat, sat.hl, phase);
    /*  // If special definition in "C"
  external "C" TwoPhaseMedium_setBubbleState_(sat, phase, state, mediumName, libraryName, substanceName)
    annotation(Include="#include <CoolPropLib.h>", Library="CoolPropLib");
*/
    annotation(Inline = true);
  end setBubbleState;


  redeclare replaceable function extends setDewState
  "set the thermodynamic state on the dew line"
    extends Modelica.Icons.Function;
    input SaturationProperties sat "saturation point";
    input FixedPhase phase =  1 "phase: default is one phase";
    output ThermodynamicState state "complete thermodynamic state info";
    // Standard definition
  algorithm
    state :=setState_ph(sat.psat, sat.hv, phase);
    /*  // If special definition in "C"
  external "C" TwoPhaseMedium_setDewState_(sat, phase, state, mediumName, libraryName, substanceName)
    annotation(Include="#include <CoolPropLib.h>", Library="CoolPropLib");
*/
    annotation(Inline = true);
  end setDewState;


  redeclare replaceable function extends saturationTemperature
    // Standard definition
  algorithm
    T :=saturationTemperature_sat(setSat_p(p));
    /*  // If special definition in "C"
  external "C" T=  TwoPhaseMedium_saturationTemperature_(p, mediumName, libraryName, substanceName)
    annotation(Include="#include <CoolPropLib.h>", Library="CoolPropLib");
*/
    annotation(Inline = true);
  end saturationTemperature;


  redeclare function extends saturationTemperature_sat
    annotation(Inline = true);
  end saturationTemperature_sat;


  redeclare replaceable function extends saturationTemperature_derp "Returns derivative of saturation temperature w.r.t.. pressureBeing this function inefficient, it is strongly recommended to use saturationTemperature_derp_sat
     and never use saturationTemperature_derp directly"
  external "C" dTp=  TwoPhaseMedium_saturationTemperature_derp_(p, mediumName, libraryName, substanceName)
    annotation(Include="#include <CoolPropLib.h>", Library="CoolPropLib");
  end saturationTemperature_derp;


  redeclare replaceable function saturationTemperature_derp_sat
  "Returns derivative of saturation temperature w.r.t.. pressure"
    extends Modelica.Icons.Function;
    input SaturationProperties sat "saturation property record";
    output Real dTp "derivative of saturation temperature w.r.t. pressure";
    // Standard definition
  algorithm
    dTp := sat.dTp;
    /*  // If special definition in "C"
  external "C" dTp=  TwoPhaseMedium_saturationTemperature_derp_sat_(sat.psat, sat.Tsat, sat.uniqueID, mediumName, libraryName, substanceName)
    annotation(Include="#include <CoolPropLib.h>", Library="CoolPropLib");
*/
    annotation(Inline = true);
  end saturationTemperature_derp_sat;


  redeclare replaceable function extends dBubbleDensity_dPressure
  "Returns bubble point density derivative"
    // Standard definition
  algorithm
    ddldp := sat.ddldp;
    /*  // If special definition in "C"
  external "C" ddldp=  TwoPhaseMedium_dBubbleDensity_dPressure_(sat, mediumName, libraryName, substanceName)
    annotation(Include="#include <CoolPropLib.h>", Library="CoolPropLib");
*/
    annotation(Inline = true);
  end dBubbleDensity_dPressure;


  redeclare replaceable function extends dDewDensity_dPressure
  "Returns dew point density derivative"
    // Standard definition
  algorithm
    ddvdp := sat.ddvdp;
    /*  // If special definition in "C"
  external "C" ddvdp=  TwoPhaseMedium_dDewDensity_dPressure_(sat, mediumName, libraryName, substanceName)
    annotation(Include="#include <CoolPropLib.h>", Library="CoolPropLib");
*/
    annotation(Inline = true);
  end dDewDensity_dPressure;


  redeclare replaceable function extends dBubbleEnthalpy_dPressure
  "Returns bubble point specific enthalpy derivative"
    // Standard definition
  algorithm
    dhldp := sat.dhldp;
    /*  // If special definition in "C"
  external "C" dhldp=  TwoPhaseMedium_dBubbleEnthalpy_dPressure_(sat, mediumName, libraryName, substanceName)
    annotation(Include="#include <CoolPropLib.h>", Library="CoolPropLib");
*/
    annotation(Inline = true);
  end dBubbleEnthalpy_dPressure;


  redeclare replaceable function extends dDewEnthalpy_dPressure
  "Returns dew point specific enthalpy derivative"
    // Standard definition
  algorithm
    dhvdp := sat.dhvdp;
    /*  // If special definition in "C"
  external "C" dhvdp=  TwoPhaseMedium_dDewEnthalpy_dPressure_(sat, mediumName, libraryName, substanceName)
    annotation(Include="#include <CoolPropLib.h>", Library="CoolPropLib");
*/
    annotation(Inline = true);
  end dDewEnthalpy_dPressure;


  redeclare replaceable function extends bubbleDensity
  "Returns bubble point density"
    // Standard definition
  algorithm
    dl := sat.dl;
    /*  // If special definition in "C"
  external "C" dl=  TwoPhaseMedium_bubbleDensity_(sat, mediumName, libraryName, substanceName)
    annotation(Include="#include <CoolPropLib.h>", Library="CoolPropLib");
*/
    annotation(Inline = true);
  end bubbleDensity;


  redeclare replaceable function extends dewDensity "Returns dew point density"
    // Standard definition
  algorithm
    dv := sat.dv;
    /*  // If special definition in "C"
  external "C" dv=  TwoPhaseMedium_dewDensity_(sat, mediumName, libraryName, substanceName)
    annotation(Include="#include <CoolPropLib.h>", Library="CoolPropLib");
*/
    annotation(Inline = true);
  end dewDensity;


  redeclare replaceable function extends bubbleEnthalpy
  "Returns bubble point specific enthalpy"
    // Standard definition
  algorithm
    hl := sat.hl;
    /*  // If special definition in "C"
  external "C" hl=  TwoPhaseMedium_bubbleEnthalpy_(sat, mediumName, libraryName, substanceName)
    annotation(Include="#include <CoolPropLib.h>", Library="CoolPropLib");
*/
    annotation(Inline = true);
  end bubbleEnthalpy;


  redeclare replaceable function extends dewEnthalpy
  "Returns dew point specific enthalpy"
    // Standard definition
  algorithm
    hv := sat.hv;
    /*  // If special definition in "C"
  external "C" hv=  TwoPhaseMedium_dewEnthalpy_(sat, mediumName, libraryName, substanceName)
    annotation(Include="#include <CoolPropLib.h>", Library="CoolPropLib");
*/
    annotation(Inline = true);
  end dewEnthalpy;


  redeclare replaceable function extends saturationPressure
    // Standard definition
  algorithm
    p :=saturationPressure_sat(setSat_T(T));
    /*  // If special definition in "C"
  external "C" p=  TwoPhaseMedium_saturationPressure_(T, mediumName, libraryName, substanceName)
    annotation(Include="#include <CoolPropLib.h>", Library="CoolPropLib");
*/
    annotation(Inline = false,
               LateInline = true,
               derivative = saturationPressure_der);
  end saturationPressure;


  redeclare function extends saturationPressure_sat
    annotation(Inline = true);
  end saturationPressure_sat;


  redeclare replaceable function extends surfaceTension
  "Returns surface tension sigma in the two phase region"
    //Standard definition
  algorithm
    sigma := sat.sigma;
    /*  //If special definition in "C"
  external "C" sigma=  TwoPhaseMedium_surfaceTension_(sat, mediumName, libraryName, substanceName)
    annotation(Include="#include <CoolPropLib.h>", Library="CoolPropLib");
*/
    annotation(Inline = true);
  end surfaceTension;


  redeclare replaceable function extends bubbleEntropy
  "Returns bubble point specific entropy"
    //Standard definition
  algorithm
    sl := specificEntropy(setBubbleState(sat));
    /*  //If special definition in "C"
  external "C" sl=  TwoPhaseMedium_bubbleEntropy_(sat, mediumName, libraryName, substanceName)
    annotation(Include="#include <CoolPropLib.h>", Library="CoolPropLib");
*/
    annotation(Inline = true);
  end bubbleEntropy;


  redeclare replaceable function extends dewEntropy
  "Returns dew point specific entropy"
    //Standard definition
  algorithm
    sv := specificEntropy(setDewState(sat));
    /*  //If special definition in "C"
  external "C" sv=  TwoPhaseMedium_dewEntropy_(sat, mediumName, libraryName, substanceName)
    annotation(Include="#include <CoolPropLib.h>", Library="CoolPropLib");
*/
    annotation(Inline = true);
  end dewEntropy;
end ExternalTwoPhaseMedium;
