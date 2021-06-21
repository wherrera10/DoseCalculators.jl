# DoseCalculators.jl

<img src="https://github.com/wherrera10/DoseCalculators.jl/blob/main/docs/src/gtk.png">

Gtk medication dosage calculators for Julia

## Usage:

First you should define a function which takes named  arguments weight = kg, height = cm, and age = years.

See the file examples/medication_formulas.jl for examples of formulas. 

This type of app does not consider concomitant medications. If there are such issues, consider mention in the text of `rlabel`.
<br /><br />

#### <em>Always</em> sanity check medical apps for errors! Unchecked unit or decimal place errors <em>can kill!</em>

<br /><br />

## Functions:
  
    dose_calculator_app(func::Function, title = "Dose Calculator", rlabel = "Results")

Create a `Gtk` widget with entries for `weight`, `height`, `age`, and dose interval.
Arguments:
`func` is a function which takes named arguments age = years, weight =  kg, height = cm and returns total 24-hour dosage in mg.
`title` is the title for the app, and 
`rlabel` is the label to be given the results
<br /><br />

## Example:
     
    using DoseCalculators
     
    function amoxicillin_po(; age, weight, height)
        if age <= 3/12
            return weight * 30.0
        elseif age <= 16 && weight <= 40
            return weight * 37.0
        else
            return 1500.0
        end
    end
     
    dose_calculator_app(amoxicillin_po, "Amoxicillin PO Dosing", "Amoxicillin dosage(mg)")
                                       
See the `examples` directory for other examples of formulas.
<br /><br />
  
  
## Installation:
                                   
You may install the package from Github in the usual way:
<br />

    # press ] to go to Pkg mode
  
    pkg> add DoseCalculators
      
 <br />
  
 Or, to install the current master copy:
    
    using Pkg
    Pkg.add("http://github.com/wherrera10/DoseCalculators.jl")                          
  
 <br /> 
 
