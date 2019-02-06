module FeatureTemplates

export @fx

using MacroTools

"""
    @fx function...

Modifies a function definition to collect a return a vector of features,
marked with `f(...)`.

```
@fx function feats(x)
    f("*bias*")
    f(x.a)
    f(x.b)
    f(x.a, x.b)
    f(x.c)
end

julia> x = (a=1, b=2, c=3)
(a = 1, b = 2, c = 3)

julia> feats(x)
5-element Array{String,1}:
 "*bias*"
 "x.a=1"
 "x.b=2"
 "x.a=1,x.b=2"
 "x.c=3"
```
"""
macro fx(func)
    @assert func.head == :function "Can only call @fx on function definitions!"
    featureset = Set()
    extractor = MacroTools.prewalk(func) do e
        if isa(e, Expr) && e.head == :call && first(e.args) == :f
            feat = Expr(:call, :string)
            for (i, exp) in enumerate(e.args[2:end])
                i > 1 && push!(feat.args, ",")
                push!(feat.args, feature_template(exp))
            end
            in(feat, featureset) && (return nothing)
            push!(featureset, feat)
            Expr(:call, :push!, :_fs, feat)
        else
            e
        end
    end
    extractor.args[2].args = [:(_fs = String[]); extractor.args[2].args; :(return _fs)]
    return esc(extractor)
end

function feature_template(expr)
    if isa(expr, String)
        expr
    else
        name = string(expr)
        val = :(isempty($expr) ? "_" : $expr)
        :(string($name, "=", $val))
    end
end


end # module
