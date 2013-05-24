within CoolProp2Modelica.Examples;
model CompressibleValveSystem "A valve between a source and a sink"
  extends Modelica.Icons.Example;
  Modelica.Fluid.Valves.ValveCompressible valveCompressible(
    m_flow_nominal=0.2,
    redeclare package Medium = WorkingFluid,
    dp_nominal=200000,
    p_nominal=1000000)
    annotation (Placement(transformation(extent={{-10,-10},{10,10}})));
  Modelica.Fluid.Sources.FixedBoundary source(
  nPorts=1,
  p=2*system.p_ambient,
  T=system.T_ambient,
  redeclare package Medium = WorkingFluid)
    annotation (Placement(transformation(extent={{-80,-10},{-60,10}})));
replaceable package WorkingFluid = CoolProp2Modelica.Media.R601_CP
  constrainedby Modelica.Media.Interfaces.PartialMedium
                                              annotation (choicesAllMatching=true);
replaceable package HeatingFluid =
      Modelica.Media.Incompressible.Examples.Essotherm650 constrainedby
    Modelica.Media.Interfaces.PartialMedium   annotation (choicesAllMatching=true);
replaceable package CoolingFluid = CoolProp2Modelica.Media.R718_CP
  constrainedby Modelica.Media.Interfaces.PartialMedium
                                              annotation (choicesAllMatching=true);
  Modelica.Fluid.Sources.FixedBoundary sink(
  nPorts=1,
  redeclare package Medium = WorkingFluid,
  p=system.p_ambient,
  T=system.T_ambient)
    annotation (Placement(transformation(extent={{80,-10},{60,10}})));
  Modelica.Blocks.Sources.Sine sine(freqHz=2, offset=1)
    annotation (Placement(transformation(extent={{-30,60},{-10,80}})));
  inner Modelica.Fluid.System system
    annotation (Placement(transformation(extent={{-80,40},{-60,60}})));
equation
connect(source.ports[1], valveCompressible.port_a)     annotation (Line(
      points={{-60,6.66134e-16},{-36,6.66134e-16},{-36,6.10623e-16},{-10,
        6.10623e-16}},
      color={0,127,255},
      smooth=Smooth.None));
connect(valveCompressible.port_b, sink.ports[1])        annotation (Line(
      points={{10,6.10623e-16},{36,6.10623e-16},{36,6.66134e-16},{60,
        6.66134e-16}},
      color={0,127,255},
      smooth=Smooth.None));
  connect(sine.y, valveCompressible.opening) annotation (Line(
      points={{-9,70},{6.66134e-16,70},{6.66134e-16,8}},
      color={0,0,127},
      smooth=Smooth.None));
  annotation (Diagram(graphics), Documentation(info="<html>
<p><h4><font color=\"#008000\">Compressible Valve System</font></h4></p>
<p>This file illustrates how CoolProp2Modelica can be used with standard components from the Modelica.Fluid library. You can redeclare the WorkingFluid package with any other fluid that matches the PartialMedium interface. Changes will automatically propagate to all components.</p>
</html>"));
end CompressibleValveSystem;
