#! /usr/bin/bash

echo "ls -la stats_monthly_ebsco_*data_new_format"
      ls -la stats_monthly_ebsco_*data_new_format

# -rw-rw-r--   1 oclc     oclc     13139435 Aug 13 15:46 stats_monthly_ebsco_citation_data_new_format
# -rw-rw-r--   1 oclc     oclc     11088828 Aug 13 15:47 stats_monthly_ebsco_fulltext_data_new_format
# -rw-rw-r--   1 oclc     oclc     13573402 Aug 13 15:48 stats_monthly_ebsco_search_data_new_format
# -rw-rw-r--   1 oclc     oclc     13741526 Aug 13 15:49 stats_monthly_ebsco_sessions_data_new_format

echo "ls -la stats_monthly_ebsco_*data_new_format_temp"
      ls -la stats_monthly_ebsco_*data_new_format_temp

# -rw-rw-r--   1 oclc     oclc     13139435 Aug 13 15:41 stats_monthly_ebsco_citation_data_new_format_temp
# -rw-rw-r--   1 oclc     oclc     11088828 Aug 13 15:41 stats_monthly_ebsco_fulltext_data_new_format_temp
# -rw-rw-r--   1 oclc     oclc     13573402 Aug 13 15:41 stats_monthly_ebsco_search_data_new_format_temp
# -rw-rw-r--   1 oclc     oclc     13741526 Aug 13 15:41 stats_monthly_ebsco_sessions_data_new_format_temp

# citation

echo "tail stats_monthly_ebsco_citation_data_new_format"
      tail stats_monthly_ebsco_citation_data_new_format

echo "tail stats_monthly_ebsco_citation_data_new_format_temp"
      tail stats_monthly_ebsco_citation_data_new_format_temp

# fulltext

echo "tail stats_monthly_ebsco_fulltext_data_new_format"
      tail stats_monthly_ebsco_fulltext_data_new_format

echo "tail stats_monthly_ebsco_fulltext_data_new_format_temp"
      tail stats_monthly_ebsco_fulltext_data_new_format_temp

# search

echo "tail stats_monthly_ebsco_search_data_new_format"
      tail stats_monthly_ebsco_search_data_new_format

echo "tail stats_monthly_ebsco_search_data_new_format_temp"
      tail stats_monthly_ebsco_search_data_new_format_temp

# sessions

echo "tail stats_monthly_ebsco_sessions_data_new_format"
      tail stats_monthly_ebsco_sessions_data_new_format

echo "tail stats_monthly_ebsco_sessions_data_new_format_temp"
      tail stats_monthly_ebsco_sessions_data_new_format_temp

while true; do
    read -p "Run?" yn
    case $yn in
        [Yy]* ) ./vendor_statsload.pl -e; break;;
        [Nn]* ) exit;;
        * ) echo "Please answer yes or no.";;
    esac
done

# citation

echo "diff stats_monthly_ebsco_citation_data_new_format_temp stats_monthly_ebsco_citation_data_new_format"
      diff stats_monthly_ebsco_citation_data_new_format_temp stats_monthly_ebsco_citation_data_new_format
echo "cp   stats_monthly_ebsco_citation_data_new_format_temp stats_monthly_ebsco_citation_data_new_format"
      cp   stats_monthly_ebsco_citation_data_new_format_temp stats_monthly_ebsco_citation_data_new_format

echo "tail stats_monthly_ebsco_citation_data_new_format"
      tail stats_monthly_ebsco_citation_data_new_format

echo "tail stats_monthly_ebsco_citation_data_new_format_temp"
      tail stats_monthly_ebsco_citation_data_new_format_temp

# fulltext

echo "diff stats_monthly_ebsco_fulltext_data_new_format_temp stats_monthly_ebsco_fulltext_data_new_format"
      diff stats_monthly_ebsco_fulltext_data_new_format_temp stats_monthly_ebsco_fulltext_data_new_format
echo "cp   stats_monthly_ebsco_fulltext_data_new_format_temp stats_monthly_ebsco_fulltext_data_new_format"
      cp   stats_monthly_ebsco_fulltext_data_new_format_temp stats_monthly_ebsco_fulltext_data_new_format

echo "tail stats_monthly_ebsco_fulltext_data_new_format"
      tail stats_monthly_ebsco_fulltext_data_new_format

echo "tail stats_monthly_ebsco_fulltext_data_new_format_temp"
      tail stats_monthly_ebsco_fulltext_data_new_format_temp

# search

echo "diff stats_monthly_ebsco_search_data_new_format_temp stats_monthly_ebsco_search_data_new_format"
      diff stats_monthly_ebsco_search_data_new_format_temp stats_monthly_ebsco_search_data_new_format
echo "cp   stats_monthly_ebsco_search_data_new_format_temp stats_monthly_ebsco_search_data_new_format"
      cp   stats_monthly_ebsco_search_data_new_format_temp stats_monthly_ebsco_search_data_new_format

echo "tail stats_monthly_ebsco_search_data_new_format"
      tail stats_monthly_ebsco_search_data_new_format

echo "tail stats_monthly_ebsco_search_data_new_format_temp"
      tail stats_monthly_ebsco_search_data_new_format_temp

# sessions

echo "diff stats_monthly_ebsco_sessions_data_new_format_temp stats_monthly_ebsco_sessions_data_new_format"
      diff stats_monthly_ebsco_sessions_data_new_format_temp stats_monthly_ebsco_sessions_data_new_format
echo "cp   stats_monthly_ebsco_sessions_data_new_format_temp stats_monthly_ebsco_sessions_data_new_format"
      cp   stats_monthly_ebsco_sessions_data_new_format_temp stats_monthly_ebsco_sessions_data_new_format

echo "tail stats_monthly_ebsco_sessions_data_new_format"
      tail stats_monthly_ebsco_sessions_data_new_format

echo "tail stats_monthly_ebsco_sessions_data_new_format_temp"
      tail stats_monthly_ebsco_sessions_data_new_format_temp

echo "ls -la stats_monthly_ebsco_*data_new_format"
      ls -la stats_monthly_ebsco_*data_new_format

echo "ls -la stats_monthly_ebsco_*data_new_format_temp"
      ls -la stats_monthly_ebsco_*data_new_format_temp

