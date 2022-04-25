# -------------------------------------------------------------------
# Tags
let
    reg = ObA.TAG_REGEX

    tag = "#KJbhkjh"
    m = match(reg, tag)
    @test !isnothing(m)
    @test m[:txt] == "KJbhkjh"

    tag = "#KJbhkjh/asdscds"
    m = match(reg, tag)
    @test !isnothing(m)
    @test m[:txt] == "KJbhkjh/asdscds"

    tag = "#_KJbhkjh/asd_scds"
    m = match(reg, tag)
    @test !isnothing(m)
    @test m[:txt] == "_KJbhkjh/asd_scds"

    tag = "#_KJbhkjh /asd_scds"
    m = match(reg, tag)
    @test !isnothing(m)
    @test m[:txt] == "_KJbhkjh"

    # not a tag
    tag = "# _KJbhkjh/asd_scds" 
    m = match(reg, tag)
    @test isnothing(m)

    tag = "#1_KJbhkjh/asd_scds" 
    m = match(reg, tag)
    @test isnothing(m)
end

# -------------------------------------------------------------------
# File links
let
    reg = ObA.EXTRACT_FILE_LINK_REGEX

    link = "[[file]]"
    m = match(reg, link)
    @test !isnothing(m)
    @test m[:txt] == "file"
    @test m[:file] == "file"

    link = "[[file|alias]]"
    m = match(reg, link)
    @test !isnothing(m)
    @test m[:txt] == "file|alias"
    @test m[:file] == "file"
    @test m[:alias] == "alias"

    link = "[[file#ider]]"
    m = match(reg, link)
    @test !isnothing(m)
    @test m[:txt] == "file#ider"
    @test m[:file] == "file"
    @test m[:ider] == "ider"

    link = "[[file#ider|alias]]"
    m = match(reg, link)
    @test !isnothing(m)
    @test m[:txt] == "file#ider|alias"
    @test m[:file] == "file"
    @test m[:ider] == "ider"
    @test m[:alias] == "alias"

    # no links
    for link in [
            "asdfas",
            "asdfas]]",
            "[[asdfas",
            "[[asdfas\n]]",
        ]
        m = match(reg, link)
        @test isnothing(m)
    end

end

## -------------------------------------------------------------------
# Headers
let
    reg = ObA.HEADER_EXTRACTOR_REGEX

    header = "# txt\n"
    m = match(reg, header)
    @test !isnothing(m)
    @test m[:txt] == "txt"

    header = "## txt sadasdf dsa\n"
    m = match(reg, header)
    @test !isnothing(m)
    @test m[:txt] == "txt sadasdf dsa"

    # no header
    for header in [
        "asdfas",
        "#asdfas",
        "# asdfas",
    ]
    m = match(reg, header)
    @test isnothing(m)
end
end