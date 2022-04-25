function extract_vault_cli(argv::Vector)

    argset = ArgParseSettings()
    @add_arg_table! argset begin
        "--source_name", "-s"
            help = "The name of the destination vault"
            arg_type = String
            default = basename(pwd())
        "--target_name", "-t"
            help = "The name of the destination vault"
            arg_type = String
        "--deep", "-d"
            help = "The deep level of the ramification"
            arg_type = Int
            default = 1
        "--mute", "-m"
            help = "Avoid printing information"
            action = :store_true
    end

    parsed_args = parse_args(argv, argset)
    dest_name = basename(parsed_args["target_name"])
    src_name = basename(parsed_args["source_name"])
    verbose = !parsed_args["mute"]
    deep = parsed_args["deep"]
    
    storage = checked_vaults_storage()
    
    src_vault = joinpath(storage, src_name)
    dest_vault = joinpath(storage, dest_name)

    for vault in [src_vault, dest_vault]
        !isdir(vault) && error("vault not found: '", vault, "'")
    end

    if verbose
        println("Params")
        @show src_vault dest_vault deep
        println()
    end

    _move_subgraph(src_vault, dest_vault; deep, verbose)

end