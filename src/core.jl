using PyCall
import Conda

julia_exepath() =
    joinpath(VERSION < v"0.7.0-DEV.3073" ? JULIA_HOME : Base.Sys.BINDIR,
             Base.julia_exename())

function eval_str(code::String)
    Base.eval(Main, Meta.parse(strip(code)))
end

set_var(name::String, value) = set_var(Symbol(name), value)

function set_var(name::Symbol, value)
    Base.eval(Main, :($name = $value))
    nothing
end

@static if VERSION < v"0.7-"
    _getproperty(value, name) = getfield(value, Symbol(name))
else
    _getproperty(value, name) = getproperty(value, Symbol(name))
end

struct _jlwrap_type end  # a type that would be wrapped as jlwrap by PyCall

function _start_ipython(name; kwargs...)
    pyimport("replhelper")[name](;
        eval_str = eval_str,
        set_var = set_var,
        jlwrap_prototype = _jlwrap_type(),
        getproperty = _getproperty,
        kwargs...)
end

function start_ipython(; kwargs...)
    _start_ipython(:customized_ipython; kwargs...)
end

function __init__()
    pushfirst!(PyVector(pyimport("sys")["path"]), @__DIR__)
    init_repl_if_not()
end
