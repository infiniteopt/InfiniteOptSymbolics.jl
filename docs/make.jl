using InfiniteOptSymbolics
using Documenter

DocMeta.setdocmeta!(InfiniteOptSymbolics, :DocTestSetup, :(using InfiniteOptSymbolics); recursive=true)

makedocs(;
    modules=[InfiniteOptSymbolics],
    authors="Joshua Pulsipher",
    repo="https://github.com/pulsipher/InfiniteOptSymbolics.jl/blob/{commit}{path}#{line}",
    sitename="InfiniteOptSymbolics.jl",
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
        canonical="https://pulsipher.github.io/InfiniteOptSymbolics.jl",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
    ],
)

deploydocs(;
    repo="github.com/pulsipher/InfiniteOptSymbolics.jl",
    devbranch="main",
)
