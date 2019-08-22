#! /usr/bin/bash


echo "ls -la stats_monthly_mango_*data"
      ls -la stats_monthly_mango_*data

# -rw-rw-r--   1 oclc     oclc       48827 Aug 13 15:52 stats_monthly_mango_sessions_data

echo "ls -la stats_monthly_mango_*data_new"
      ls -la stats_monthly_mango_*data_new

# -rw-rw-r--   1 oclc     oclc       48827 Aug 13 15:51 stats_monthly_mango_sessions_data_new

# sessions

echo "tail stats_monthly_mango_sessions_data"
      tail stats_monthly_mango_sessions_data
echo "tail stats_monthly_mango_sessions_data_new"
      tail stats_monthly_mango_sessions_data_new

while true; do
    read -p "Run? :" yn
    case $yn in
        [Yy]* ) ./vendor_statsload.pl -o; break;;
        [Nn]* ) exit;;
        * ) echo "Please answer yes or no.";;
    esac
done

# sessions

echo "diff stats_monthly_mango_sessions_data_new stats_monthly_mango_sessions_data"
      diff stats_monthly_mango_sessions_data_new stats_monthly_mango_sessions_data
echo "cp   stats_monthly_mango_sessions_data_new stats_monthly_mango_sessions_data"
      cp   stats_monthly_mango_sessions_data_new stats_monthly_mango_sessions_data

echo "tail stats_monthly_mango_sessions_data"
      tail stats_monthly_mango_sessions_data
echo "tail stats_monthly_mango_sessions_data_new"
      tail stats_monthly_mango_sessions_data_new

echo "ls -la stats_monthly_mango_*data"
      ls -la stats_monthly_mango_*data

echo "ls -la stats_monthly_mango_*data_new"
      ls -la stats_monthly_mango_*data_new

