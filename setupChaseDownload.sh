#!/usr/bin/env ruby

require 'watir-webdriver'

if ARGV.length < 3
  raise 'Must have three arguments, Dude!  (Umm...pwd, start and end dates)'
end

open('chase_upload.log', 'a') { |f| f.puts "Processing for range #{ARGV[1]} to #{ARGV[2]}" }

# create profile for download
profile = Selenium::WebDriver::Firefox::Profile.new
profile['browser.download.folderList'] = 2 # custom location
profile['browser.download.dir'] = "#{Dir.pwd}"
profile['browser.helperApps.neverAsk.saveToDisk'] = "application/vnd.intu.qfx"

# setup
FileUtils.rm Dir.glob('Activity*')

b = Watir::Browser.new :firefox, :profile => profile

b.goto 'https://chase.com'

u = b.text_fields(:id=>'usr_name').detect{|f| f.visible?}
u.set 'andreaclingenpeel'
u = b.text_fields(:id=>'usr_password').detect{|f| f.visible?}
u.set ARGV[0]
b.button(:src => /home-login-button/).click

b.link(:href => /Activity\/270315367/).when_present.click
b.link(:href => /#AdvancedSearchView/).when_present.click
b.radio(:id => 'RangePeriod').when_present.set
b.text_field(:id=>'DateLo').set ARGV[1]
b.text_field(:id=>'DateHi').set ARGV[2]
b.link(:id => 'AdvancedSearch').click

b.link(:text => 'Download').click
b.link(:text => /QFX/).when_present.click

puts 'Waiting for file download...'
sleep(5)

act_files = Dir.glob('Activity*')
`open #{act_files[0]}`

b.close
