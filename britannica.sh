#! /usr/bin/bash

echo "ls -la stats_monthly_britannica_*data"
      ls -la stats_monthly_britannica_*data
echo "ls -la stats_monthly_britannica_*data_new"
      ls -la stats_monthly_britannica_*data_new

# fulltext

echo "tail stats_monthly_britannica_fulltext_data"
      tail stats_monthly_britannica_fulltext_data
echo "tail stats_monthly_britannica_fulltext_data_new"
      tail stats_monthly_britannica_fulltext_data_new

# search

echo "tail stats_monthly_britannica_search_data"
      tail stats_monthly_britannica_search_data
echo "tail stats_monthly_britannica_search_data_new"
      tail stats_monthly_britannica_search_data_new

while true; do
    read -p "Run?" yn
    case $yn in
        [Yy]* ) ./vendor_statsload.pl -b; break;;
        [Nn]* ) exit;;
        * ) echo "Please answer yes or no.";;
    esac
done

# fulltext

echo "diff stats_monthly_britannica_fulltext_data_new stats_monthly_britannica_fulltext_data"
      diff stats_monthly_britannica_fulltext_data_new stats_monthly_britannica_fulltext_data
echo "cp   stats_monthly_britannica_fulltext_data_new stats_monthly_britannica_fulltext_data"
      cp   stats_monthly_britannica_fulltext_data_new stats_monthly_britannica_fulltext_data

# search

echo "diff stats_monthly_britannica_search_data_new stats_monthly_britannica_search_data"
      diff stats_monthly_britannica_search_data_new stats_monthly_britannica_search_data
echo "cp   stats_monthly_britannica_search_data_new stats_monthly_britannica_search_data"
      cp   stats_monthly_britannica_search_data_new stats_monthly_britannica_search_data

# fulltext

echo "tail stats_monthly_britannica_fulltext_data"
      tail stats_monthly_britannica_fulltext_data
echo "tail stats_monthly_britannica_fulltext_data_new"
      tail stats_monthly_britannica_fulltext_data_new

# search

echo "tail stats_monthly_britannica_search_data"
      tail stats_monthly_britannica_search_data
echo "tail stats_monthly_britannica_search_data_new"
      tail stats_monthly_britannica_search_data_new

echo "ls -la stats_monthly_britannica_*data"
      ls -la stats_monthly_britannica_*data
echo "ls -la stats_monthly_britannica_*data_new"
      ls -la stats_monthly_britannica_*data_new

