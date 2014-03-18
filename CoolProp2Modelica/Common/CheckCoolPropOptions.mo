within CoolProp2Modelica.Common;
function CheckCoolPropOptions
  "A function to extract and check the options passed to CoolProp"
  extends Modelica.Icons.Function;
  input String substanceName = "";
  input Boolean debug = false;
  output String result;

protected
  Integer nextIndex;
  Integer intVal;
  Integer length;
  String name;
  String rest;
  // used to process the option
  String option;
  String value;
  // gather all valid options
  String options;
  // accept these inputs
  String[:] allowedOptions = {
    "enable_TTSE",
    "enable_BICUBIC",
    "enable_EXTTP",
    "twophase_derivsmoothing_xend",
    "rho_smoothing_xend",
    "debug"};
  // predefined delimiters
  String delimiter1 = "|";
  String delimiter2 = "=";

algorithm
  if noEvent(debug) then
    assert(false, "input  = " + substanceName, level=  AssertionLevel.warning);
  end if;
  nextIndex := Modelica.Utilities.Strings.find(substanceName, delimiter1);     // 0 if not found
  if nextIndex > 0 then
    // separate fluid name and options
    name    := Modelica.Utilities.Strings.substring(substanceName, 1, nextIndex-1);
    length  := Modelica.Utilities.Strings.length(substanceName);
    rest    := Modelica.Utilities.Strings.substring(substanceName, nextIndex+1, length);
    options := "";

    while (nextIndex > 0) loop
      nextIndex := Modelica.Utilities.Strings.find(rest, delimiter1);     // 0 if not found
      if nextIndex > 0 then
        option  := Modelica.Utilities.Strings.substring(rest, 1, nextIndex-1);
        length  := Modelica.Utilities.Strings.length(rest);
        rest    := Modelica.Utilities.Strings.substring(rest, nextIndex+1, length);
      else
        option  := rest;
      end if;
      // now option contains enable_TTSE=1 or enable_TTSE
      intVal    := Modelica.Utilities.Strings.find(option, delimiter2);     // 0 if not found
      if intVal > 0 then // found "="
        length  := Modelica.Utilities.Strings.length(option);
        value   := Modelica.Utilities.Strings.substring(option, intVal+1, length);
        option  := Modelica.Utilities.Strings.substring(option, 1, intVal-1);
      else  // enable option by default
        value   := "1";
      end if;
      // now option contains only enable_TTSE
      intVal :=1;
      for i in 1:size(allowedOptions,1) loop
        if Modelica.Utilities.Strings.compare(option,allowedOptions[i])==Modelica.Utilities.Types.Compare.Equal then
          intVal := intVal - 1;
        end if;
      end for;
      if intVal <> 0 then
        assert(false, "Your option (" + option + ") is unknown.");
      else
        options := options+delimiter1+option+delimiter2+value;
      end if;
    end while;
  else
    // Assuming there are no special options
    name   := substanceName;
    options:= "";
  end if;

  result := name+options;
  if noEvent(debug) then
    assert(false, "output = " + result, level=  AssertionLevel.warning);
  end if;
end CheckCoolPropOptions;
