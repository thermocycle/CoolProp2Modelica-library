within CoolProp2Modelica.Common;
function XtoSubstanceName
  "A function to convert concentration to substance name"
  extends Modelica.Icons.Function;
  input Real[:] composition = {0.0};
  input String substanceName = "";
  input String delimiter = "|";
  output String result;

protected
  Integer nextIndex;
  Integer inLength;
  String name;
  String rest;

algorithm
  if noEvent(size(composition,1) <= 0) then
    assert(false, "You are passing an empty composition vector, returning solution name only.", level=  AssertionLevel.warning);
    result :=substanceName;
  elseif noEvent(size(composition,1) > 1) then
    assert(false, "Your mixture has more than two components, ignoring all but the first element.", level=  AssertionLevel.warning);
    inLength  := Modelica.Utilities.Strings.length(substanceName);
    nextIndex := Modelica.Utilities.Strings.find(substanceName, delimiter);
    name      := Modelica.Utilities.Strings.substring(substanceName, 1, nextIndex-1);
    rest      := Modelica.Utilities.Strings.substring(substanceName, nextIndex, inLength);
    result    := name + "-" + String(composition[1]) + rest;
  end if;
end XtoSubstanceName;
