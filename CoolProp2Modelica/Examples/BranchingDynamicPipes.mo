within CoolProp2Modelica.Examples;
model BranchingDynamicPipes
  extends Modelica.Fluid.Examples.BranchingDynamicPipes(
    redeclare package Medium = CoolProp2Modelica.Media.R134a_CP, system(
        energyDynamics=Modelica.Fluid.Types.Dynamics.FixedInitial));
end BranchingDynamicPipes;
