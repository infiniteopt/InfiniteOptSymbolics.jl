module InfiniteOptSymbolics

# Import the ncessary packages
import InfiniteOpt, ModelingToolkit

const _Symbolics = ModelingToolkit.Symbolics
const _JuMP = InfiniteOpt.JuMP

# Include the code
include("utilities.jl")
include("conversion.jl")

# Define additional stuff that should not be exported
const _EXCLUDE_SYMBOLS = [Symbol(@__MODULE__), :eval, :include]

# Following JuMP, export everything that doesn't start with a _ 
for sym in names(@__MODULE__, all = true)
    sym_string = string(sym)
    if sym in _EXCLUDE_SYMBOLS || startswith(sym_string, "_") || startswith(sym_string, "@_")
        continue
    end
    if !(Base.isidentifier(sym) || (startswith(sym_string, "@") && Base.isidentifier(sym_string[2:end])))
        continue
    end
    @eval export $sym
end

end # end of module
