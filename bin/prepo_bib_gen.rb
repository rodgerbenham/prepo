#!/usr/bin/ruby

require 'set'

# execute inside a prepo paper folder to generate all of the bib entries
# the meta doc needs to build from each folders this.bib

codes = Set.new
prepo_repo = ENV["PREPO_ROOT"]

File.readlines("p.tex").each do |line|
    s = line.split
    s.each do |term|
        if term.start_with?("\\citet") || term.start_with?("\\cite")
            parse = term.split("{")[1]
            parse = parse.chomp('}')
            items = parse.split(",")
            items.each { |i| codes << i.gsub(/\s+/, "") }
        end
    end
end

newbib = ""

codes.each do |c|
    newbib += `cat #{prepo_repo}/papers/#{c}/this.bib`
end

puts newbib
