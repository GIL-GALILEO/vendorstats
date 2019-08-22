#! /usr/bin/bash

echo "ls -la stats_monthly_proquest_*data"
      ls -la stats_monthly_proquest_*data

# -rw-rw-r--   1 oclc     oclc     5135076 Aug 13 15:54 stats_monthly_proquest_citation_data
# -rw-rw-r--   1 oclc     oclc     6920661 Aug 13 15:54 stats_monthly_proquest_fulltext_data
# -rw-rw-r--   1 oclc     oclc     13897650 Aug 13 15:55 stats_monthly_proquest_search_data

echo "ls -la stats_monthly_proquest_*data_new"
      ls -la stats_monthly_proquest_*data_new

# -rw-rw-r--   1 oclc     oclc     5135076 Aug 13 15:53 stats_monthly_proquest_citation_data_new
# -rw-rw-r--   1 oclc     oclc     6920661 Aug 13 15:53 stats_monthly_proquest_fulltext_data_new
# -rw-rw-r--   1 oclc     oclc     13897650 Aug 13 15:53 stats_monthly_proquest_search_data_new

# citation

echo "tail stats_monthly_proquest_citation_data"
      tail stats_monthly_proquest_citation_data

echo "tail stats_monthly_proquest_citation_data_new"
      tail stats_monthly_proquest_citation_data_new

# fulltext

echo "tail stats_monthly_proquest_fulltext_data"
      tail stats_monthly_proquest_fulltext_data

echo "tail stats_monthly_proquest_fulltext_data_new"
      tail stats_monthly_proquest_fulltext_data_new

# search

echo "tail stats_monthly_proquest_search_data"
      tail stats_monthly_proquest_search_data

echo "tail stats_monthly_proquest_search_data_new"
      tail stats_monthly_proquest_search_data_new

while true; do
    read -p "Run? :" yn
    case $yn in
        [Yy]* ) ./vendor_statsload.pl -p; break;;
        [Nn]* ) exit;;
        * ) echo "Please answer yes or no.";;
    esac
done

# citation

echo "diff stats_monthly_proquest_citation_data_new stats_monthly_proquest_citation_data"
      diff stats_monthly_proquest_citation_data_new stats_monthly_proquest_citation_data
echo "cp   stats_monthly_proquest_citation_data_new stats_monthly_proquest_citation_data"
      cp   stats_monthly_proquest_citation_data_new stats_monthly_proquest_citation_data

echo "tail stats_monthly_proquest_citation_data"
      tail stats_monthly_proquest_citation_data

echo "tail stats_monthly_proquest_citation_data_new"
      tail stats_monthly_proquest_citation_data_new

# fulltext

echo "diff stats_monthly_proquest_fulltext_data_new stats_monthly_proquest_fulltext_data"
      diff stats_monthly_proquest_fulltext_data_new stats_monthly_proquest_fulltext_data
echo "cp   stats_monthly_proquest_fulltext_data_new stats_monthly_proquest_fulltext_data"
      cp   stats_monthly_proquest_fulltext_data_new stats_monthly_proquest_fulltext_data

echo "tail stats_monthly_proquest_fulltext_data"
      tail stats_monthly_proquest_fulltext_data

echo "tail stats_monthly_proquest_fulltext_data_new"
      tail stats_monthly_proquest_fulltext_data_new

# search

echo "diff stats_monthly_proquest_search_data_new stats_monthly_proquest_search_data"
      diff stats_monthly_proquest_search_data_new stats_monthly_proquest_search_data
echo "cp   stats_monthly_proquest_search_data_new stats_monthly_proquest_search_data"
      cp   stats_monthly_proquest_search_data_new stats_monthly_proquest_search_data

echo "tail stats_monthly_proquest_search_data"
      tail stats_monthly_proquest_search_data

echo "tail stats_monthly_proquest_search_data_new"
      tail stats_monthly_proquest_search_data_new

echo "ls -la stats_monthly_proquest_*data"
      ls -la stats_monthly_proquest_*data

echo "ls -la stats_monthly_proquest_*data_new"
      ls -la stats_monthly_proquest_*data_new

