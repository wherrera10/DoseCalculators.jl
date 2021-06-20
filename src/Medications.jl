######################
# Instruction on functions for formulas:
# The formula should accept named arguments weight = kg, height = cm, and age = years
# The function should return total daily (24 hour) dosage in milligrams or else as must be specified in the rlabel argument to the app.
# In general, return values in floating point form.
######################

module Medications

export amoxacillin_po, metformin, metoprolol_extended

"""
    function amoxicillin_po(; age, weight, height)
Source: https://www.mayoclinic.org/drugs-supplements/penicillin-oral-route-injection-route-intravenous-route-intramuscular-route/proper-use/drg-20062334
For amoxicillin:
For bacterial infections:
For oral dosage forms (capsules, oral suspension, tablets, and chewable tablets):
Adults, teenagers, and children weighing more than 40 kilograms (kg) (88 pounds)
  250 to 500 milligrams (mg) every eight hours or 500 to 875 mg every twelve hours, depending on the type and severity of the infection.
Neonates and infants up to 3 months of age
  The usual dose is 15 mg per kg (6.8 mg per pound) of body weight or less every twelve hours.
Infants 3 months of age and older and children weighing up to 40 kg (88 lbs.)
  The usual dose is 6.7 to 13.3 mg per kg (3 to 6 mg per pound) of body weight every eight hours or 
  12.5 to 22.5 mg per kg (5.7 to 10.2 mg per pound) of body weight every twelve hours.
"""
function amoxicillin_po(; age, weight, height)
    if age <= 3/12
        return weight * 30.0
    elseif age <= 16 && weight <= 40
        return weight * 37.0
    else
        return 1500.0
  end
  
"""
    function metformin(; age, weight, height)
Metformin in age < 7 years or nonobese is not generally used. Otherwise monotherapy dose starts at 1000 mg.
"""
function metformin_mg(; age, weight, height)
    if age < 7 || weight < 20
        return 0.0
    else
        return 1000.0
    end
end

"""
    function metoprolol_extended(; age, weight, height)
  
"""
function metoprolol_extended(; age, weight, height)
    if age < 18
        return min(weight, 12.5)
    else
        return 25.0
    end
end

"""
    levetiracetam_starting_po(; age, weight, height)

Source:    https://www.rxlist.com/keppra-drug.htm#indications 
Initial treatment
Adults 16 Years Of Age And Older
Initiate treatment with a daily dose of 1000 mg/day
Pediatric Patients
1 Month To < 6 Months
Initiate treatment with a daily dose of 14 mg/kg in 2 divided doses 
6 Months To < 16 Years
Initiate treatment with a daily dose of 20 mg/kg in 2 divided doses 
"""
function levetiracetam_starting_po(; age, weight, height)
    if age <= 0.5
        return weight * 14.0
    elseif age <= 16
        return min(1000.0, weight * 20.0)
    else
        return 1000.0
    end
end

"""
    lamotrigine_starting_po(; age, weight, height)
    
Refer to tables at https://www.rxlist.com/lamictal-drug.htm#dosage
Note dose may change based on other medications ESPECIALLY VALPROATE
"""
function lamotrigine_starting_po(; age, weight, height)
    if age < 2
        return 0.0
    elseif age <= 12
        weight < 14 && return 1.0
        weight < 27 && return 2.0
        weight < 34 && return 4.0
        weight < 40 && return 5.0
        return min(25.0, weight * 0.3)
    else
        return 25.0
    end
end

end # module
