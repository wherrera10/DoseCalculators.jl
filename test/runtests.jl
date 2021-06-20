using Gtk, DoseCalculators

function amoxicillin_po(; age, weight, height)
        if age <= 3/12
            return weight * 30.0
        elseif age <= 16 && weight <= 40
            return weight * 37.0
        else
            return 1500.0
      end
     
dose_calculator_app(amoxacillin_po, "Amoxacillin PO Dosing", "Amoxacillin dosage(mg)")

win = DoseCalculators.apps[end]

@test win isa GtkWindow

Gtk.destroy(win)

