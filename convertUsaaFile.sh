#!/usr/bin/env ruby

def out_and_in(dollar_amount)
  dollar_amount = dollar_amount.gsub(/\"/, '').to_f
  dollar_amount > 0 ? ['', dollar_amount.abs] : [dollar_amount.abs, '']
end

input = File.open(ARGV[0])

out = File.open(ARGV[1], 'w') do |output_file|
  output_file.write("Date,Payee,Category,Memo,Outflow,Inflow\n")

  input.each_line do |line| 
    line.chomp!
    vals = line.split(',')

    next if vals.empty?
    outflow, inflow = out_and_in(vals[6])
    output_file.write "#{vals[2]},#{vals[4]},,#{vals[5]},#{outflow},#{inflow}\n"
  end
end
