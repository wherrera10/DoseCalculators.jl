module DoseCalculators

export dose_calculator_app

using Gtk4

const _apps = GtkWindow[]

"""
    dose_calculator_app(func::Function, title = "Dose Calculator", rlabel = "Results (mg)";
                        wait_for_close::Bool = true)

Create a Gtk4 window with entries for `weight`, `height`, `age`, and dose interval.

Arguments:
- `func`: function taking named arguments `age` (years), `weight` (kg), `height` (cm)
  and returning total 24-hour dosage in mg
- `title`: the main window's title bar title
- `rlabel`: label for the results row
- `wait_for_close`: if `true`, block until the window is closed; otherwise return the window

The displayed result is the amount per dose, derived from the formula's 
total 24-hour amount. 
"""
function dose_calculator_app(
    func::Function,
    title = "Dose Calculator",
    rlabel = "Results (mg)";
    wait_for_close::Bool = true,
)

    win = GtkWindow(title, 500, 180)

    function install_result_css!(win)
        css = """
    .dose-result {
        font-size: 28px;
        font-weight: bold;
        font-family: Sans;
    }
    """
        push!(Gtk4.display(win), GtkCssProvider(css))
    end
    install_result_css!(win)

    wentry, aentry, hentry, qentry = GtkEntry(), GtkEntry(), GtkEntry(), GtkEntry()
    qentry.text = "12"

    weight_kg = GtkCheckButton("kg")
    weight_lb = GtkCheckButton("lb")
    weight_lb.group = weight_kg
    weight_kg.active = true

    age_years = GtkCheckButton("years")
    age_months = GtkCheckButton("months")
    age_months.group = age_years
    age_years.active = true

    height_cm = GtkCheckButton("cm")
    height_in = GtkCheckButton("in")
    height_in.group = height_cm
    height_cm.active = true

    resultbutton = GtkButton("Calculate")
    resultlabel = GtkLabel("—")
    add_css_class(resultlabel, "dose-result")

    statuslabel = GtkLabel("")

    vbox = GtkBox(:v)
    win[] = vbox
    push!(_apps, win)

    wbox = GtkBox(:h)
    push!(wbox, GtkLabel("Patient Weight"), wentry, weight_kg, weight_lb)

    abox = GtkBox(:h)
    push!(abox, GtkLabel("Age"), aentry, age_years, age_months)

    hbox = GtkBox(:h)
    push!(hbox, GtkLabel("Height"), hentry, height_cm, height_in)

    qbox = GtkBox(:h)
    push!(qbox, GtkLabel("Give medication every: "), qentry, GtkLabel(" hours."))

    resultbox = GtkBox(:h)
    push!(resultbox, GtkLabel("$rlabel per dose:"), resultlabel, resultbutton)
    push!(vbox, wbox, abox, hbox, qbox, resultbox)
    push!(
        vbox,
        GtkLabel(
            "The formula must return a total 24-hour amount; the displayed value is per dose.",
        ),
    )
    push!(
        vbox,
        GtkLabel(
            "WARNING: Educational estimate only. Verify the dose with current prescribing information and a qualified clinician.",
        ),
    )
    push!(vbox, statuslabel)

    window_open = Ref(true)
    closed = wait_for_close ? Condition() : nothing
    signal_connect(win, "destroy") do _
        filter!(app -> app !== win, _apps)
        window_open[] = false
        wait_for_close && notify(closed)
    end

    function calculate(w)
        resultlabel.label = "—"
        statuslabel.label = ""
        try
            wt = _parse_entry(wentry.text, "Weight")
            ht = _parse_entry(hentry.text, "Height")
            ag = _parse_entry(aentry.text, "Age"; allow_zero = true)
            interval = _parse_entry(qentry.text, "Dose interval")
            per_dose = _dose_per_interval(
                func;
                weight = wt,
                height = ht,
                age = ag,
                interval = interval,
                weight_unit = weight_kg.active ? :kg : :lb,
                height_unit = height_cm.active ? :cm : :in,
                age_unit = age_years.active ? :years : :months,
            )
            resultlabel.label = string(per_dose)
        catch err
            if err isa ArgumentError
                statuslabel.label = sprint(showerror, err)
            else
                rethrow()
            end
        end
        nothing
    end

    signal_connect(calculate, resultbutton, "clicked")
    !isinteractive() && Gtk4.start_main_loop()
    if wait_for_close
        wait(closed)
    else
        sleep(5)
    end
    win
end # app function

function _parse_entry(text, name; allow_zero = false)
    value = tryparse(Float64, strip(text))
    isnothing(value) && throw(ArgumentError("$name must be a number."))
    _validate_number(value, name; allow_zero)
end

function _validate_number(value::Real, name; allow_zero = false)
    number = Float64(value)
    isfinite(number) || throw(ArgumentError("$name must be a finite number."))
    (allow_zero ? number >= 0 : number > 0) || throw(
        ArgumentError(
            "$name must be $(allow_zero ? "zero or greater" : "greater than zero").",
        ),
    )
    number
end

function _dose_per_interval(
    func::Function;
    weight,
    height,
    age,
    interval,
    weight_unit = :kg,
    height_unit = :cm,
    age_unit = :years,
)
    wt = _validate_number(weight, "Weight")
    ht = _validate_number(height, "Height")
    ag = _validate_number(age, "Age"; allow_zero = true)
    dose_interval = _validate_number(interval, "Dose interval")

    weight_unit === :kg ||
        weight_unit === :lb ||
        throw(ArgumentError("Weight unit must be :kg or :lb."))
    height_unit === :cm ||
        height_unit === :in ||
        throw(ArgumentError("Height unit must be :cm or :in."))
    age_unit === :years ||
        age_unit === :months ||
        throw(ArgumentError("Age unit must be :years or :months."))

    wt = weight_unit === :kg ? wt : wt / 2.20462
    ht = height_unit === :cm ? ht : ht * 2.54
    ag = age_unit === :years ? ag : ag / 12

    daily_dose = func(weight = wt, height = ht, age = ag)
    daily_dose isa Real ||
        throw(ArgumentError("The dose formula must return a real number."))
    isfinite(daily_dose) && daily_dose >= 0 ||
        throw(ArgumentError("The dose formula must return a finite, nonnegative amount."))
    per_dose = Float64(daily_dose) * (dose_interval / 24)
    isfinite(per_dose) ||
        throw(ArgumentError("The calculated per-dose amount is not finite."))
    per_dose
end # app


end # module
