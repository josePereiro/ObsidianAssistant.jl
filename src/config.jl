const OBSIDIAN_ASSISTANT_VAULTS_STORAGE_ENV_KEY = "OBSIDIAN_ASSISTANT_VAULTS_STORAGE"

function vaults_storage()
    if haskey(ENV, "OBSIDIAN_ASSISTANT_VAULTS_STORAGE")
        return string(ENV["OBSIDIAN_ASSISTANT_VAULTS_STORAGE"])
    end
    return joinpath(homedir(), "Documents", "Obsidian")
end

function checked_vaults_storage()
    storage = vaults_storage()
    !isdir(storage) && error("storage dir not found: '", storage, "'")
    return storage
end