module DoseCalculators

export dose_calculator_app

using Gtk

const _apps = GtkWindow[]
const _apps_should_persist = [true]

"""
    dose_calculator_app(func::Function, title = "Dose Calculator", rlabel = "Results")

Create a `Gtk` widget with entries for `weight`, `height`, `age`, and dose interval.
Arguments:
`func` is a function which takes named arguments age = years, weight =  kg, height = cm and returns total 24-hour dosage in mg.
`title` is the title for the app
`rlabel` is the label to be given the results
"""
function dose_calculator_app(func::Function, title = "Dose Calculator", rlabel = "Results")
    wentry, aentry, hentry, qentry = GtkEntry(), GtkEntry(), GtkEntry(), GtkEntry()
    weightunits = [GtkRadioButton("kg")]
    push!(weightunits, GtkRadioButton(weightunits[1], "lb"))
    ageunits = [GtkRadioButton("years")]
    push!(ageunits, GtkRadioButton(ageunits[1], "months"))
    heightunits = [GtkRadioButton("cm")]
    push!(heightunits, GtkRadioButton(heightunits[1], "in"))
    resultbutton = GtkButton("Calculate")
    resultlabel = GtkLabel("0")
    win = GtkWindow(title, 500, 100) |> (GtkFrame() |> (vbox = GtkBox(:v)))
    push!(_apps, win)
    wbox = GtkButtonBox(:h)
    push!(wbox, GtkLabel("Patient Weight"), wentry, weightunits...)
    abox = GtkButtonBox(:h)
    push!(abox, GtkLabel("Age"), aentry, ageunits...)
    hbox = GtkButtonBox(:h)
    push!(hbox, GtkLabel("Height"), hentry, heightunits...)
    resultbox = GtkButtonBox(:h)
    qbox = GtkButtonBox(:h)
    push!(qbox, GtkLabel("Give medication every: "), qentry, GtkLabel(" hours."))
    set_gtk_property!(qentry, :text, "12")
    push!(resultbox, GtkLabel(rlabel), resultlabel, resultbutton)
    push!(vbox, wbox, abox, hbox, qbox, resultbox)

    function calculate(w)
        wt = parse(Float64, get_gtk_property(wentry, :text, String)) /
            (get_gtk_property(weightunits[1], :active, Bool) ? 1 : 0.393701)
        ht = parse(Float64, get_gtk_property(hentry, :text, String)) *
            (get_gtk_property(heightunits[1], :active, Bool) ? 1 : 2.20462)
        ag = parse(Float64, get_gtk_property(aentry, :text, String)) /
            (get_gtk_property(ageunits[1], :active, Bool) ? 1 : 12)
        result = func(weight = wt, height = ht, age = ag)
        dosagefraction = parse(Float64, get_gtk_property(qentry, :text, String)) / 24
        GAccessor.text(resultlabel, "                      ")
        GAccessor.text(resultlabel, string(result * dosagefraction))
    end

    signal_connect(calculate, resultbutton, :clicked)

    if _apps_should_persist[1]
        cond = Condition()
        endit(w) = notify(cond)
        signal_connect(endit, win, :destroy)
        showall(win)
        wait(cond)
    else
        sleep(20)
    end
end

end # module
