require 'ostruct'
require 'readline'

# don't invoke directly, use bin/prepo.sh

filename = ARGV[0]
draft_name = ARGV[1]

prepo_root = ENV["PREPO_ROOT"]
STRINGS_SHORT_FILE = "#{prepo_root}/strings-shrt.bib"

# Usage: prepo.rb <pdffile>

def paper_code(paper_meta)
    year_short = paper_meta.year.split(//).last(2).join
    "#{paper_meta.author_short}#{year_short}-#{paper_meta.venue}"
end

def output_conference(paper_meta)
    if paper_meta.pages != ""
        %{
@inproceedings{#{paper_code(paper_meta)},
  author = {#{paper_meta.author}},
  title = {#{paper_meta.title}},
  booktitle = #{paper_meta.venue},
  year = {#{paper_meta.year}},
  pages = {#{paper_meta.pages}}
} 
        }
    else
        %{
@inproceedings{#{paper_code(paper_meta)},
  author = {#{paper_meta.author}},
  title = {#{paper_meta.title}},
  booktitle = #{paper_meta.venue},
  year = {#{paper_meta.year}}
} 
        }
    end
end

def output_journal(paper_meta)
    if paper_meta.pages != ""
        %{
@article{#{paper_code(paper_meta)},
  author = {#{paper_meta.author}},
  title = {#{paper_meta.title}},
  journal = #{paper_meta.venue},
  year = {#{paper_meta.year}},
  pages = {#{paper_meta.pages}},
  volume = {#{paper_meta.volume}},
  number = {#{paper_meta.number}}
} 
        }
    else
        %{
@article{#{paper_code(paper_meta)},
  author = {#{paper_meta.author}},
  title = {#{paper_meta.title}},
  journal = #{paper_meta.venue},
  year = {#{paper_meta.year}},
  volume = {#{paper_meta.volume}},
  number = {#{paper_meta.number}}
} 
        }
    end
end


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

def format_author_short_string(authors)
    # input author string might look like:
    # Rodger Benham, Luke Gallagher, Joel Mackenzie, Binsheng Liu, Xiaolu Lu, Falk Scholer, Alistair Moffat, and J. Shane Culpepper
    # output author string might look like:
    # bgmllsmc
    
    s = authors.split(/, [and ]*/)
    newstring = ""

    s.each do |author|
        s2 = author.split(" ")
        newstring += s2.last[0].downcase
    end

    newstring
end


def get_meta(filename)
    `pdfinfo #{filename} &> meta`
    meta = OpenStruct.new
    File.readlines("meta").each do |line|
        s = line.split(/[ ]{2,}/)
        key = s[0]
        value = s[1]
        if key == "Title:"
            meta.title = value.strip
        elsif key == "Author:"
            meta.author = format_author(value)
            meta.author_short = format_author_short_string(value)
        end
    end
    meta
end

if filename != "draft"

    strings_short = get_strings_short(STRINGS_SHORT_FILE)

    puts "Which venue code do you want to use for this? (from \"#{STRINGS_SHORT_FILE}\")"

    comp = proc { |s| strings_short.grep(/^#{Regexp.escape(s)}/) }

    Readline.completion_append_character = " "
    Readline.completion_proc = comp

    valid = false
    venue = ""
    while !valid
        venue = Readline.readline('> ', true)
        venue.strip!
        valid = (strings_short.include?(venue))
    end

    puts "Which year was this paper published?"
    valid = false
    year = ""
    while !valid
        year = Readline.readline('> ', true)
        year.strip!
        valid = (year[/[0-9]+/] == year)
    end

    puts "What are the page numbers? (Example format: 993--1002, enter nothing to skip)"
    valid = false
    pages = ""
    while !valid
        pages = Readline.readline('> ', true)
        pages.strip!
        # Skip validation on this, sometimes this is used in place of
        # numpages? Regardless, people should check the warnings on 
        # when making the bibtex
        valid = true
    end

    valid = false
    ptype = ""
    while !valid
        puts "Is this a (c)onference or (j)ournal paper? (j/c)"
        ptype = Readline.readline('> ', true)
        ptype.strip!
        valid = (ptype == "j" || ptype == "c")
    end

    puts "Parsing paper metadata..."
    paper_meta = get_meta(filename)
    paper_meta.venue = venue
    paper_meta.year = year
    paper_meta.pages = pages

    gen_bibtex = ""

    if ptype == "c"
        gen_bibtex = output_conference(paper_meta)    
    else
        valid = false
        volume = ""
        while !valid
            puts "What is the volume?"
            volume = Readline.readline('> ', true)
            volume.strip!
            valid = true
        end

        valid = false
        number = ""
        while !valid
            puts "What is the article number?"
            number = Readline.readline('> ', true)
            number.strip!
            valid = true
        end

        paper_meta.volume = volume
        paper_meta.number = number

        gen_bibtex = output_journal(paper_meta)
    end

    # copy the contents of paper-template into new folder
    `mkdir -p #{prepo_root}/papers`

    if File.directory?("#{prepo_root}/papers/#{paper_code(paper_meta)}")
        raise "Directory already exists for #{paper_code(paper_meta)}, exiting" 
    end

    `cp -R #{prepo_root}/paper-template #{prepo_root}/papers/#{paper_code(paper_meta)}`

    # overwrite the bib with the generated bib
    File.open("#{prepo_root}/papers/#{paper_code(paper_meta)}/p.bib", 'w') { |file| file.write(gen_bibtex) }

    # second one so that concise bibs can be generated when needed
    File.open("#{prepo_root}/papers/#{paper_code(paper_meta)}/this.bib", 'w') { |file| file.write(gen_bibtex) }

    `sed -i 's/foo-bar-article-title/#{paper_meta.title}/g' #{prepo_root}/papers/#{paper_code(paper_meta)}/p.tex`
    `sed -i 's/foo-bar-pcode/#{paper_code(paper_meta)}/g' #{prepo_root}/papers/#{paper_code(paper_meta)}/p.tex`

    `cp #{filename} #{prepo_root}/papers/#{paper_code(paper_meta)}/original.pdf`
    `mv meta #{prepo_root}/papers/#{paper_code(paper_meta)}/meta`

    puts "Generated #{prepo_root}/papers/#{paper_code(paper_meta)} successfully"

else
    # copy the contents of paper-template into new folder
    `mkdir -p #{prepo_root}/papers`

    if File.directory?("#{prepo_root}/papers/#{draft_name}-draft")
        raise "Directory already exists for #{draft_name}-draft, exiting" 
    end

    `cp -R #{prepo_root}/paper-template #{prepo_root}/papers/#{draft_name}-draft`

    puts "Generated #{prepo_root}/papers/#{draft_name}-draft successfully"
end
