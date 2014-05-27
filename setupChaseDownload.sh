#!/usr/bin/env ruby

require 'watir-webdriver'
require 'date'

URL = 'https://chase.com'
USERNAME = 'andreaclingenpeel'

def format_date(dt)
  dt.strftime('%m/%d/%Y')
end

# Pull that last logged value to determine the next date range
log_vals = `tail -1 ./chase_upload.log`
log_vals = log_vals.split(' ')
mdy_to   = log_vals[5].split('/')

# new date range -- last "to" minus 2 days to current date + 1 (as long as that is greater than the "from" date)
from_date = Date.new(mdy_to[2].to_i, mdy_to[0].to_i, mdy_to[1].to_i)
from_date -= 2
to_date = Date.today

open('chase_upload.log', 'a') { |f| f.puts "Processing for range #{format_date(from_date)} to #{format_date(to_date)}" }

# create profile for download
profile = Selenium::WebDriver::Firefox::Profile.new
profile['browser.download.folderList'] = 2 # custom location
profile['browser.download.dir'] = "#{Dir.pwd}"
profile['browser.helperApps.neverAsk.saveToDisk'] = "application/vnd.intu.qfx"

# setup
FileUtils.rm Dir.glob('Activity*')

b = Watir::Browser.new :firefox, :profile => profile

b.goto URL

u = b.text_fields(:id=>'usr_name_home').detect{|f| f.visible?}
u.set USERNAME
u = b.text_fields(:id=>'usr_password_home').detect{|f| f.visible?}
u.set ARGV[0]
l = b.links(:class=>'chase-button').detect{|f| f.visible?}
l.click

b.link(:href => /Activity\/441623608/).when_present.click
b.link(:href => /#AdvancedSearchView/).when_present.click
b.radio(:id => 'RangePeriod').when_present.set
b.text_field(:id=>'DateLo').set(ARGV.length > 1 ? ARGV[1] : format_date(from_date))
b.text_field(:id=>'DateHi').set(ARGV.length > 1 ? ARGV[2] : format_date(to_date))
b.link(:id => 'AdvancedSearch').click

b.link(:text => 'Download').click
b.link(:text => /QFX/).when_present.click

puts 'Waiting for file download...'
sleep(5)

act_files = Dir.glob('Activity*')
`open #{act_files[0]}`

b.close
