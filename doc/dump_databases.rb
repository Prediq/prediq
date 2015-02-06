# dbname = 'api_socialcentiv_development'
# dumpfilename = "/Volumes/tm_portable_bk/Bill/db_backups/#{dbname}_dump.sql"
# `pg_dump -Fc -U deploy -d #{dbname} -f #{dumpfilename}`

dbnames = %w(magellan_app_development tweet_intent_development standard_supply_development)

dbnames.each do |dbname|
  puts "*** dbname = #{dbname}"
  dumpfilename = "/Volumes/tm_portable_bk/Bill/db_backups/#{dbname}_dump.sql"
  puts "*** dumping #{dbname} to: #{dumpfilename}"
  `pg_dump -Fc -U deploy -d #{dbname} -f #{dumpfilename}`
  puts "*** DONE dumping #{dbname} to: #{dumpfilename}";puts;puts

end