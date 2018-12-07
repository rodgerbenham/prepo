require 'ostruct'
require 'readline'

STRINGS_SHORT_FILE = "strings-shrt.bib"

# Usage: prepo.rb <pdffile>

def get_strings_short(filename)
    short_strings = []
    File.readlines(filename).each do |line|
        s = line.split(/\s/)
        name = ""
        s.each do |term|
            if term[/[a-zA-Z0-9]+/] == term
                name = term
                break
            end
        end
        short_strings << name if name != ""
    end
    short_strings
end

def format_author(authors)
    # input author string might look like:
    # Rodger Benham, Luke Gallagher, Joel Mackenzie, Binsheng Liu, Xiaolu Lu, Falk Scholer, Alistair Moffat, and J. Shane Culpepper
    # output author string might look like:
    # R. Benham and L. Gallagher and J. Mackenzie and B. Liu and X. Lu and F. Scholer and A. Moffat and J. S. Culpepper
    
    s = authors.split(/, [and ]*/)
    newstring = ""

    s.each do |author|
        s2 = author.split(" ")
        newauthor = ""
        s2.each do |part|
            if part.include?(".")
                # this is an initial so include in the string as is
                newauthor += part + " "
            elsif part == s2.last
                # this is the last name, leave as is
                newauthor += part
                newauthor.strip!
                break
            elsif part.include?("-")
                # this word has a hyphen so break it up
                s3 = part.split("-")
                newauthor += "#{s3[0][0]}.-#{s3[1][0]}. "
            else
                newauthor += "#{part[0]}. "
            end
        end

        if author != s.last
            newstring += "#{newauthor} and "
        else
            newstring += newauthor
        end
    end

    newstring
end

def get_meta(filename)
    `pdfinfo #{filename} > meta`
    meta = OpenStruct.new
    File.readlines("meta").each do |line|
        s = line.split(/[ ]{2,}/)
        key = s[0]
        value = s[1]
        if key == "Title:"
            meta.title = value
        elsif key == "Author:"
            meta.author = format_author(value)
        end
    end
    meta
end

filename = ARGV[0]

strings_short = get_strings_short(STRINGS_SHORT_FILE)

puts "Which venue code do you want to use for this? (from \"#{STRINGS_SHORT_FILE}\")"

comp = proc { |s| strings_short.grep(/^#{Regexp.escape(s)}/) }

Readline.completion_append_character = " "
Readline.completion_proc = comp

valid = false
while !valid
    venue = Readline.readline('> ', true)
    venue.strip!
    valid = (strings_short.include?(venue))
end

valid = false
ptype = ""
while !valid
    puts "Is this a (c)onference or (j)ournal paper? (j/c)"
    ptype = Readline.readline('> ', true)
    ptype.strip!
    valid = (ptype == "j" || ptype == "c")
end

get_meta(filename)


