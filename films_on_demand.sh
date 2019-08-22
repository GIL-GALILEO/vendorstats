#! /usr/bin/bash

echo "ls -la stats_monthly_films_on_demand_*data"
      ls -la stats_monthly_films_on_demand_*data
echo "ls -la stats_monthly_films_on_demand_*data_new"
      ls -la stats_monthly_films_on_demand_*data_new

# -rw-rw-r--   1 oclc     oclc       54733 Aug 13 15:37 stats_monthly_films_on_demand_fulltext_data
# -rw-rw-r--   1 oclc     oclc       51230 Aug 14 11:24 stats_monthly_films_on_demand_searches_data
# -rw-rw-r--   1 oclc     oclc       55209 Aug 14 11:24 stats_monthly_films_on_demand_sessions_data
# -rw-rw-r--   1 oclc     oclc       54733 Aug 13 15:36 stats_monthly_films_on_demand_fulltext_data_new
# -rw-rw-r--   1 oclc     oclc       51230 Aug 13 15:36 stats_monthly_films_on_demand_searches_data_new
# -rw-rw-r--   1 oclc     oclc       55209 Aug 13 15:36 stats_monthly_films_on_demand_sessions_data_new

# fulltext

echo "tail stats_monthly_films_on_demand_fulltext_data"
      tail stats_monthly_films_on_demand_fulltext_data

echo "tail stats_monthly_films_on_demand_fulltext_data_new"
      tail stats_monthly_films_on_demand_fulltext_data_new

# searches

echo "tail stats_monthly_films_on_demand_searches_data"
      tail stats_monthly_films_on_demand_searches_data

echo "tail stats_monthly_films_on_demand_searches_data_new"
      tail stats_monthly_films_on_demand_searches_data_new

# sessions

echo "tail stats_monthly_films_on_demand_sessions_data"
      tail stats_monthly_films_on_demand_sessions_data

echo "tail stats_monthly_films_on_demand_sessions_data_new"
      tail stats_monthly_films_on_demand_sessions_data_new

while true; do
    read -p "Run?" yn
    case $yn in
        [Yy]* ) ./vendor_statsload.pl -c; break;;
        [Nn]* ) exit;;
        * ) echo "Please answer yes or no.";;
    esac
done

# fulltext

echo "diff stats_monthly_films_on_demand_fulltext_data_new stats_monthly_films_on_demand_fulltext_data"
      diff stats_monthly_films_on_demand_fulltext_data_new stats_monthly_films_on_demand_fulltext_data
echo "cp   stats_monthly_films_on_demand_fulltext_data_new stats_monthly_films_on_demand_fulltext_data"
      cp   stats_monthly_films_on_demand_fulltext_data_new stats_monthly_films_on_demand_fulltext_data

echo "tail stats_monthly_films_on_demand_fulltext_data"
      tail stats_monthly_films_on_demand_fulltext_data

echo "tail stats_monthly_films_on_demand_fulltext_data_new"
      tail stats_monthly_films_on_demand_fulltext_data_new

# searches

echo "diff stats_monthly_films_on_demand_searches_data_new stats_monthly_films_on_demand_searches_data"
      diff stats_monthly_films_on_demand_searches_data_new stats_monthly_films_on_demand_searches_data
echo "cp   stats_monthly_films_on_demand_searches_data_new stats_monthly_films_on_demand_searches_data"
      cp   stats_monthly_films_on_demand_searches_data_new stats_monthly_films_on_demand_searches_data

echo "tail stats_monthly_films_on_demand_searches_data"
      tail stats_monthly_films_on_demand_searches_data

echo "tail stats_monthly_films_on_demand_searches_data_new"
      tail stats_monthly_films_on_demand_searches_data_new

# sessions

echo "diff stats_monthly_films_on_demand_sessions_data_new stats_monthly_films_on_demand_sessions_data"
      diff stats_monthly_films_on_demand_sessions_data_new stats_monthly_films_on_demand_sessions_data
echo "cp   stats_monthly_films_on_demand_sessions_data_new stats_monthly_films_on_demand_sessions_data"
      cp   stats_monthly_films_on_demand_sessions_data_new stats_monthly_films_on_demand_sessions_data

echo "tail stats_monthly_films_on_demand_sessions_data"
      tail stats_monthly_films_on_demand_sessions_data

echo "tail stats_monthly_films_on_demand_sessions_data_new"
      tail stats_monthly_films_on_demand_sessions_data_new

echo "ls -la stats_monthly_films_on_demand_*data"
      ls -la stats_monthly_films_on_demand_*data
echo "ls -la stats_monthly_films_on_demand_*data_new"
      ls -la stats_monthly_films_on_demand_*data_new

