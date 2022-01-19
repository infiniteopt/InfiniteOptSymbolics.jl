## Define efficient function to check if all elements in array are equal
# method found at https://stackoverflow.com/questions/47564825/check-if-all-the-elements-of-a-julia-array-are-equal/47578613
@inline function _allequal(x::AbstractArray)::Bool
    length(x) < 2 && return true
    e1 = first(x)
    for value in x
        isequal(value, e1) || return false
    end
    return true
end