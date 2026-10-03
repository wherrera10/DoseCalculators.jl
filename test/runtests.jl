using Gtk4
using Test
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

     
app = dose_calculator_app(amoxicillin_po, "Amoxacillin PO Dosing", "Amoxacillin dosage(mg)"; wait_for_close::Bool = false)

@test app isa GtkWindow
