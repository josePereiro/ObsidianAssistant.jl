function extract_vault_cli(argv::Vector)

    argset = ArgParseSettings()
    @add_arg_table! argset begin
        "--source_name", "-s"
            help = "The name of the source vault"
            arg_type = String
            default = basename(pwd())
        "--target_name", "-t"
            help = "The name of the destination vault"
            arg_type = String
            required = true
        "--deep", "-d"
            help = "The deep level of the ramification"
            arg_type = Int
            default = 1
        "--mute", "-m"
            help = "Avoid printing information"
            action = :store_true
    end

    parsed_args = parse_args(argv, argset)
    target_name = basename(parsed_args["target_name"])
    src_name = basename(parsed_args["source_name"])
    verbose = !parsed_args["mute"]
    deep = parsed_args["deep"]
    
    storage = checked_vaults_storage()
    
    src_vault = joinpath(storage, src_name)
    target_vault = joinpath(storage, target_name)

    for vault in [src_vault, target_vault]
        !isdir(vault) && error("vault not found: '", vault, "'")
    end

    if verbose
        println("Params")
        @show src_vault target_vault deep
        println()
    end

    _move_subgraph(src_vault, target_vault; deep, verbose)

end