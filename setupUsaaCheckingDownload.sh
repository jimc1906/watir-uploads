#!/usr/bin/env ruby

require 'watir-webdriver'

#if ARGV.length < 3
#  raise 'Must have three arguments, Dude!  (Umm...pwd, start and end dates)'
#end

open('usaa_checking_upload.log', 'a') { |f| f.puts "Processing for range #{ARGV[1]} to #{ARGV[2]}" }

# create profile for download
profile = Selenium::WebDriver::Firefox::Profile.new
profile['browser.download.folderList'] = 2 # custom location
profile['browser.download.dir'] = "#{Dir.pwd}"
profile['browser.helperApps.neverAsk.saveToDisk'] = "text/csv"

# remove previous download
FileUtils.rm Dir.glob('bk_download*')
FileUtils.rm Dir.glob('converted.cs?')

b = Watir::Browser.new :firefox, :profile => profile

b.goto 'https://www.usaa.com'

u = b.text_fields(:id=>'usaaNum').detect{|f| f.visible?}
u.set 'jclingenpeel'
u = b.text_fields(:id=>'usaaPass').detect{|f| f.visible?}
u.set ARGV[0]
btn = b.buttons(:class=>'login_button').detect{|f| f.visible?}
btn.click

b.text_field(:id=>'id3').when_present.set '3952'
btn = b.buttons(:name=>'submitButton').detect{|f| f.visible?}
btn.click

answer = b.text_field(:id=>'id3')
submit_answer = b.buttons(:id=>'id12').detect{|f| f.visible?}

if b.text.include? 'First name of your best man?'
  answer_value = 'Jim'
elsif b.text.include? 'City you met your spouse in?'
  answer_value = 'Harrisonburg, VA'
elsif b.text.include? 'of first elementary'
  answer_value = 'Monterrey'
end
answer.when_present.set answer_value

submit_answer.click

#b.link(:text => /.*SECURE CHECKING.*/).when_present.click
af = b.frame(:title => 'My Accounts Summary')
begin
  af.link(:text => 'USAA SECURE CHECKING').click
rescue Timeout::Error
  # we'll ignore this and move on
end
# I want to...
b.buttons(:id=>'yui-gen3-button').detect{|f| f.visible?}.when_present.click
b.link(:text => 'Export').when_present.click

b.radio(:id => "searchcriteria.allorselectedtransactions_3").when_present.click
b.text_field(:id=>'exportFromDate').set ARGV[1]
b.text_field(:id=>'exportToDate').set ARGV[2]
b.button(:id => 'exportTable').when_present.click

puts 'Waiting for file download...'
sleep(5)

`./convertUsaaFile.sh bk_download.csv converted.csv`

`open -a "YNAB 4" converted.csv`

b.close
