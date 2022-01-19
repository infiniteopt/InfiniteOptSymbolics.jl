"""

"""
struct InfiniteOptMappingData
    ref_to_num::Dict{InfiniteOpt.GeneralVariableRef, _Symbolics.Num}
    refs_to_arr::Dict{Vector{InfiniteOpt.GeneralVariableRef}, _Symbolics.Arr{Num, 1}}
    param_to_diff::Dict{InfiniteOpt.GeneralVariableRef, _Symbolics.Differential}

    # default constructor
    function InfiniteOptMappingData()
        return new(
            Dict{InfiniteOpt.GeneralVariableRef, _Symbolics.Num}(),
            Dict{Vector{InfiniteOpt.GeneralVariableRef}, _Symbolics.Arr{Num, 1}}(),
            Dict{InfiniteOpt.GeneralVariableRef, _Symbolics.Differential}()
        )
    end
end

# Extract the root name of a variable (removes the bracketed container indices)
function _remove_name_index(name::String)
    first_bracket = findfirst(isequal('['), name)
    if isnothing(first_bracket)
        return name
    else
        return name[1:prevind(name, first_bracket, 1)] # can handle unicode 
    end
end

# convert the brackets into a compatible format
function _format_name(name::String)
    first_bracket = findfirst(isequal('['), name)
    if first_bracket == 1
        error("Cannot create a `Symbolics.jl` representation using ", 
              "anonymous parameters/variables.")
    elseif isnothing(first_bracket)
        return name
    else
        last_root_idx = prevind(name, first_bracket, 1)
        root = name[1:last_root_idx]
        inds_name = replace(name[first_bracket+1:end-1], "," => "_")
        return string(root, "_", inds_name)
    end
end

"""

"""
function create_symbolic_params(
    model::InfiniteOpt.InfiniteModel, 
    data::InfiniteOptMappingData
    )
    # handle the scalar parameters
    for p in InfiniteOpt.all_parameters(model, ScalarParameter)
        name = _formate_name(_JuMP.name(p))
        data.ref_to_num[p] = first(ModelingToolkit.@parameters($(Symbol(name))))
    end
    # handle the multi-variate infinite parameters
    for (idx, data) in model.dependent_parameters
        name = _remove_name_index(first(data.names))
        if isempty(name) || !_all_equal(_remove_name_index.(data.names))
            error("Cannot create a `Symbolics.jl` representation using ", 
                  "anonymous infinite parameters or ones with heterogeneous ",
                  "naming.")
        end
        num_ps = length(data.names)
        ps = [InfiniteOpt.GeneralVariableRef(model, idx.value, InfiniteOpt.DependentParameterIndex, i) 
              for i in 1:num_ps]
        data.refs_to_arr[ps] = first(ModelingToolkit.@parameters($(Symbol(name))[1:num_ps]))
        for (i, p) in enumerate(ps)
            data.ref_to_num[p] = data.refs_to_arr[ps][i]
        end
    end
    return
end

"""

"""
function create_derivative_operators(
    model::InfiniteOpt.InfiniteModel, 
    data::InfiniteOptMappingData
    )
    deriv_params = unique!([p[2] for p in keys(model.deriv_lookup)])
    for p in deriv_params
        data.param_to_diff[p] = _Symbolics.Differential(data.ref_to_num[p])
    end
    return
end

## Helper functions to retrieve infinite parameter mappings
# Single parameter 
function _map_param_group(
    p::InfiniteOpt.GeneralVariableRef, 
    data::InfiniteOptMappingData
    )
    return data.ref_to_num[p]
end

# Multi-variate parameter
function _map_param_group(
    ps::Vector{InfiniteOpt.GeneralVariableRef}, 
    data::InfiniteOptMappingData
    )
    return data.refs_to_arr[ps]
end

"""

"""
function create_symbolic_vars(
    model::InfiniteModel, 
    data::InfiniteOptMappingData
    )
    # finite variables
    for v in _JuMP.all_variables(model, FiniteVariable)
        name = _format_name(_JuMP.name(v))
        data.ref_to_num[v] = first(_Symbolics.@variables($(Symbol(name))))
    end
    # infinite variables
    for v in _JuMP.all_variables(model, InfiniteVariable)
        name = _format_name(_JuMP.name(v))
        param_tuple = Tuple(InfiniteOpt.raw_parameter_refs(v), use_indices = false)
        num_tuple = _map_param_group.(param_tuple)
        data.ref_to_num[v] = first(_Symbolics.@variables($(Symbol(name))($(num_tuple...))))
    end
    # derivatives
    for d in InfiniteOpt.all_derivatives(model)
        name = _format_name(_JuMP.name(d))
        
    end
    # point variables

    # semi-infinite variables

end
