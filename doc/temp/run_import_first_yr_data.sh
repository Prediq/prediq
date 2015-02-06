#!/bin/bash

# NOTE: This was commented out because it was preventing rvm from running
# shopt -s -o nounset

declare -rx SCRIPT=${0##*/}

printf "***********************************\n\n"
printf $SCRIPT
printf "\n\n"
printf "***********************************\n"

run_date=`date`
log_date=`date '+%Y%m%d_%H%M_%S'`

func=$1
rails_env=$2
current_path=$3
user_id=$4

printf "Run Date: %s" "$run_date"
printf "\n"
printf "working directory: "
printf `pwd`
printf "\n"
printf "func: "
printf "$func"
printf "\n"
printf "rails_env: "
printf "$rails_env"
printf "\n"
printf "current_path: "
printf "$current_path"
printf "\n"
printf "user_id: "
printf "$user_id"
printf "\n"
printf "Running import_first_yr_data.rb"
printf "\n"
#printf "$HOME: $HOME"

#echo $HOME


#printf "\n"
#printf `rvm info`
#printf `bundle exec gem list`
#printf "\n"

# Now run the ruby script that does the import job

# load the rvm environment:
[[ -s "$HOME/.rvm/scripts/rvm" ]] && . "$HOME/.rvm/scripts/rvm"  # This loads RVM into a shell session so we can load it next.
ruby_version=`cat ${current_path}/.ruby-version`
rvm use ${ruby_version}@prediq
#rvm use ruby-2.1.5@prediq

if   [ ${rails_env} == 'import_development' ]; then
    cd ${current_path} && RAILS_ENV=${rails_env} bundle exec ruby app/classes/import_first_yr_data.rb $func $rails_env $current_path $user_id
else
    if [ ${rails_env} == 'import_staging' ]; then
        cd ${current_path} && RAILS_ENV=${rails_env} bundle exec ruby app/classes/import_first_yr_data.rb $func $rails_env $current_path $user_id > "${current_path}/log/load_pg_data_${rails_env}_${log_date}.log" 2>&1 &
    fi
#    cd ${current_path} && RAILS_ENV=${rails_env} bundle exec ruby app/classes/load_pg_data.rb $func $rails_env $current_path > "${current_path}/log/load_pg_data_${rails_env}_${log_date}.log" 2>&1 &
fi
#else
#    if [ ${rails_env} == 'development' ]; then
#        cd ${current_path} && RAILS_ENV=${rails_env} ruby app/classes/import_first_yr_data.rb $func $rails_env $current_path $user_id > "${current_path}/log/load_pg_data_${rails_env}.log" 2>&1 &
#    else
#     cd ${current_path} && RAILS_ENV=${rails_env} bundle exec ruby app/classes/load_pg_data.rb $func $rails_env $current_path > "${current_path}/log/load_pg_data_${rails_env}_${log_date}.log" 2>&1 &
#    fi
#fi

exit 0


# **********************************************************************************************************************
# SHELL SCRIPT: To run this shell script from the CL from the app root:

# the actual full command with output to the terminal screen
# local:
# func          = ARGV[0]
# rails_env     = ARGV[1]
# current_path  = ARGV[2]
# user_id       = ARGV[3]

# current_path=/Users/billkiskin/prediq/prediq_api;func=get_first_yr_data;rails_env=import_development;user_id=2; cd ${current_path} && RAILS_ENV=import_development app/classes/run_import_first_yr_data.sh ${func} ${rails_env} ${current_path} ${user_id}

# current_path=/Users/billkiskin/hiplogiq/pg_data;func=get_backups;rails_env=development; cd ${current_path} && app/classes/run_load_pg_data.sh ${func} ${rails_env} ${current_path}
# with output to the log file for the run_load_pg_data_data.sh script
# current_path=/Users/billkiskin/hiplogiq/pg_data;func=do_full_backups;rails_env=development; cd ${current_path} && app/classes/run_load_pg_data.sh ${func} ${rails_env} ${current_path} > "${current_path}/log/run_load_pg_data_${rails_env}.log" 2>&1

#staging:
# current_path=/var/www/vhosts/pg_data/current;func=do_full_backup_sc_agency;rails_env=staging; cd ${current_path} && app/classes/run_load_pg_data.sh ${func} ${rails_env} ${current_path}

# NOTE: the output is in the log file ie:
# Williams-MacBook-Pro ~/hiplogiq/pg_data: cat log/load_pg_data_development_20131216_0912_33.log

# Starting Job ImportData: 2013-12-16 09:12:35 -0600 in development mode
# ****************************************************************************************
# ImportData Job Completed at 2013-12-16 09:12:35 -0600
# ****************************************************************************************


# **********************************************************************************************************************
# RUBY CLASS: To run the ruby class script from the CL - output goes to STDOUT (screen):

# development:

# current_path=/Users/billkiskin/hiplogiq/pg_data;func=run;rails_env=development;cd ${current_path} && cd . && RAILS_ENV=${rails_env} ruby app/classes/load_pg_data.rb $func $rails_env

# The params illustrated:
# development:                            func  rails_env
#                                          |       |
# ruby app/classes/load_pg_data.rb get_backups development

# **********************************************************************************************************************
# CRON:

# in the cron called from schedule.rb via capistrano:
# cd ${current_path} && cd . && RAILS_ENV=${rails_env} ruby app/classes/load_pg_data.rb $func $rails_env >> "${current_path}/log/load_pg_data_${rails_env}_${log_date}.log" 2>&1 &




# ruby classes/load_data.rb run development


#   *     *     *   *    *        command to be executed
#   -     -     -   -    -
#   |     |     |   |    |
#   |     |     |   |    +----- day of week (0 - 6) (Sunday=0)
#   |     |     |   +------- month (1 - 12)
#   |     |     +--------- day of        month (1 - 31)
#   |     +----------- hour (0 - 23)
#   +------------- min (0 - 59)


# MAILTO=""
# every random n mins starting at midnight:
# 3,7,10,14,17,21,24,28,31,35,39,42,46,49,53,56,59 * * * * /Volumes/MainHD/Users/billy/Helis/heli_files/parse_sites.sh http://www.helifreak.com/forumdisplay.php?f=51 > /Volumes/MainHD/Users/billy/Helis/heli_files/run_parse_sites_helifreak.log 2>&1

# every random n mins starting at 1 minute past midnight:
# 1,4,8,11,15,19,22,25,29,32,36,40,43,47,50,54,57 * * * * /Volumes/MainHD/Users/billy/Helis/heli_files/parse_sites.sh http://www.rcgroups.com/aircraft-electric-helis-fs-w-44/ > /Volumes/MainHD/Users/billy/Helis/heli_files/run_parse_sites_rcgroups.log 2>&1


# every random n mins starting at midnight:
# 3,7,10,14,17,21,24,28,31,35,39,42,46,49,53,56,59 * * * * cd /Volumes/MainHD/Users/billy/Helis/heli_files && /Volumes/MainHD/Users/billy/Helis/heli_files/parse_sites.sh http://www.helifreak.com/forumdisplay.php?f=51 > /Volumes/MainHD/Users/billy/Helis/heli_files/run_parse_sites_helifreak.log 2>&1

# every random n mins starting at 1 minute past midnight:
# 1,4,8,11,15,19,22,25,29,32,36,40,43,47,50,54,57 * * * * cd /Volumes/MainHD/Users/billy/Helis/heli_files && /Volumes/MainHD/Users/billy/Helis/heli_files/parse_sites.sh http://www.rcgroups.com/aircraft-electric-helis-fs-w-44/ > /Volumes/MainHD/Users/billy/Helis/heli_files/run_parse_sites_rcgroups.log 2>&1


# To see the combined rcgroups and helifreak logs:
# cat run_parse_sites_*.log

