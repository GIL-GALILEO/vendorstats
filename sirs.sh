#! /usr/bin/bash

echo "ls -la stats_monthly_sirs_*data"
      ls -la stats_monthly_sirs_*data

# -rw-rw-r--   1 oclc     oclc     1085920 Aug 13 15:57 stats_monthly_sirs_fulltext_data
# -rw-rw-r--   1 oclc     oclc     1246414 Aug 13 15:58 stats_monthly_sirs_keyword_search_data
# -rw-rw-r--   1 oclc     oclc      204207 Aug 13 15:59 stats_monthly_sirs_sessions_data

echo "ls -la stats_monthly_sirs_*data_new"
      ls -la stats_monthly_sirs_*data_new

# -rw-rw-r--   1 oclc     oclc     1085920 Aug 13 15:57 stats_monthly_sirs_fulltext_data_new
# -rw-rw-r--   1 oclc     oclc     1246414 Aug 13 15:57 stats_monthly_sirs_keyword_search_data_new
# -rw-rw-r--   1 oclc     oclc      204207 Aug 13 15:57 stats_monthly_sirs_sessions_data_new

# fulltext

echo "tail stats_monthly_sirs_fulltext_data"
      tail stats_monthly_sirs_fulltext_data

echo "tail stats_monthly_sirs_fulltext_data_new"
      tail stats_monthly_sirs_fulltext_data_new

# search

echo "tail stats_monthly_sirs_keyword_search_data"
      tail stats_monthly_sirs_keyword_search_data

echo "tail stats_monthly_sirs_keyword_search_data_new"
      tail stats_monthly_sirs_keyword_search_data_new

# sessions

echo "tail stats_monthly_sirs_sessions_data"
      tail stats_monthly_sirs_sessions_data

echo "tail stats_monthly_sirs_sessions_data_new"
      tail stats_monthly_sirs_sessions_data_new

while true; do
    read -p "Run?" yn
    case $yn in
        [Yy]* ) ./vendor_statsload.pl -s; break;;
        [Nn]* ) exit;;
        * ) echo "Please answer yes or no.";;
    esac
done

# fulltext

echo "diff stats_monthly_sirs_fulltext_data_new stats_monthly_sirs_fulltext_data"
      diff stats_monthly_sirs_fulltext_data_new stats_monthly_sirs_fulltext_data
echo "cp   stats_monthly_sirs_fulltext_data_new stats_monthly_sirs_fulltext_data"
      cp   stats_monthly_sirs_fulltext_data_new stats_monthly_sirs_fulltext_data

echo "tail stats_monthly_sirs_fulltext_data"
      tail stats_monthly_sirs_fulltext_data

echo "tail stats_monthly_sirs_fulltext_data_new"
      tail stats_monthly_sirs_fulltext_data_new

# search

echo "diff stats_monthly_sirs_keyword_search_data_new stats_monthly_sirs_keyword_search_data"
      diff stats_monthly_sirs_keyword_search_data_new stats_monthly_sirs_keyword_search_data
echo "cp   stats_monthly_sirs_keyword_search_data_new stats_monthly_sirs_keyword_search_data"
      cp   stats_monthly_sirs_keyword_search_data_new stats_monthly_sirs_keyword_search_data

echo "tail stats_monthly_sirs_keyword_search_data"
      tail stats_monthly_sirs_keyword_search_data

echo "tail stats_monthly_sirs_keyword_search_data_new"
      tail stats_monthly_sirs_keyword_search_data_new

# sessions

echo "diff stats_monthly_sirs_sessions_data_new stats_monthly_sirs_sessions_data"
      diff stats_monthly_sirs_sessions_data_new stats_monthly_sirs_sessions_data
echo "cp   stats_monthly_sirs_sessions_data_new stats_monthly_sirs_sessions_data"
      cp   stats_monthly_sirs_sessions_data_new stats_monthly_sirs_sessions_data

echo "tail stats_monthly_sirs_sessions_data"
      tail stats_monthly_sirs_sessions_data

echo "tail stats_monthly_sirs_sessions_data_new"
      tail stats_monthly_sirs_sessions_data_new

echo "ls -la stats_monthly_sirs_*data"
      ls -la stats_monthly_sirs_*data

echo "ls -la stats_monthly_sirs_*data_new"
      ls -la stats_monthly_sirs_*data_new

