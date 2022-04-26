const TAG_REGEX = r"(?<=\#)(?<txt>[A-Za-z_][A-Za-z0-9_/]*)"
const EXTRACT_FILE_LINK_REGEX = r"(?<=\[\[)(?<txt>(?<file>[^\|\#\n]*?)(?:\#(?<ider>[^\|\n]*?))?(?:\|(?<alias>[^\n]*?))?)(?=\]\])"
const HEADER_EXTRACTOR_REGEX = r"\n*(?<lvl>\#+)\s+(?<txt>.*)\n"

function _extract_link_files(mdfile::AbstractString)
    links = String[]
    mdtxt = read(mdfile, String)
    for m in eachmatch(EXTRACT_FILE_LINK_REGEX, mdtxt)
        fn = _get_match(m, :file)
        isnothing(fn) && continue
        push!(links, fn)
    end
    return links
end