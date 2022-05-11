# This project aim to create a glue package for automatizing the note-taking process in Obsidian.
# At first, it will be an ill-mixture of specific and general tools, but I am pursuing the goal to support the note taking with a turing-complete programming language.
# Why Obsidian? Well, they have already implemented several major goals.
# I)   Represent the data in both a human and machine friendly format (a flavour of markdown)
# II)  Creates the syntax and semantics of key core features (tag, link, label, etc...)
# III) Implementation of a GUI for reading/editing the data
# IV)  A plugin system for extensions
# IV)  Have a lot of users
# 
# The main feature I believe is missing is the implementation of a full-featured scripting language in the notes.
# Like the template system but with heavy drugs.
# I want to have the whole power of julia (although nothing prevent other languages e.g. python) for modifying and analyzing a vault or set of vaults.

module ObsidianAssistant

using FilesTreeTools
using ArgParse: @add_arg_table!, ArgParseSettings, parse_args
using EasyEvents

import YAML

include("utils.jl")

include("server/AST_cache.jl")
include("server/globals.jl")
include("server/server_iter.jl")

include("parser/AST_methods.jl")
include("parser/extractors.jl")
include("parser/line_parser.jl")
include("parser/regexs.jl")
include("parser/parsers.jl")
include("parser/utils.jl")

end
