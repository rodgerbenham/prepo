#!/usr/bin/ruby

require 'digest'

filename = ARGV[0]

$transaction_name = ARGV[1]
$prepo_root = ENV["PREPO_ROOT"]

bhash = Hash.new

def get_text(paper_code, section)
    start_reading = false
    result = ""
    File.readlines("#{$prepo_root}/papers/#{paper_code}/p.tex").each do |line|
        if line.start_with?("%") && line.include?("PREPO:")
            s = line.split(":")[1].strip
            if s == section.strip
                start_reading = true
                next
            end
        end

        if line.start_with?("%") && line.include?("ENDPREPO")
            start_reading = false
            next
        end

        if start_reading
            result += line
        end
    end
    result
end

def print_transactions_before(paper_code)
    before = `cat #{$prepo_root}/papers/#{paper_code}/transactions.log 2>/dev/null`
    if before != ""
        puts "Transactions for #{paper_code} before this:"
        puts before
    end
end

def record_transaction(paper_code, section, text)
    hash = Digest::MD5.hexdigest(text[paper_code])
    f = File.open("#{$prepo_root}/papers/#{paper_code}/transactions.log", "a")
    f.puts "#{paper_code},#{section},#{$transaction_name},#{Time.now.to_s},#{hash}"
end

File.readlines(filename).each do |line|
    s = line.split(",")
    key = s[0].strip
    value = s[1].strip
    bhash[key] = value
end

puts "Previous transactions for these papers:"
bhash.each {|k, v| print_transactions_before(k) }

puts "\n\nGenerating output and recording transactions: \n"
text = Hash.new
bhash.each do |k, v| 
    puts get_text(k, v)
    text[k] = get_text(k, v)
end
bhash.each {|k, v| record_transaction(k, v, text) }
