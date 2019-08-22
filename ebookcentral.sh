#! /usr/bin/bash

echo "ls -la stats_monthly_ebookcentral_*data"
      ls -la stats_monthly_ebookcentral_*data

# -rw-rw-r--   1 oclc     oclc       78066 Aug 13 16:02 stats_monthly_ebookcentral_fulltext_data

echo "ls -la stats_monthly_ebookcentral_*data_new"
      ls -la stats_monthly_ebookcentral_*data_new

# -rw-rw-r--   1 oclc     oclc       78066 Aug 13 16:02 stats_monthly_ebookcentral_fulltext_data_new

# fulltext

echo "tail stats_monthly_ebookcentral_fulltext_data"
      tail stats_monthly_ebookcentral_fulltext_data

echo "tail stats_monthly_ebookcentral_fulltext_data_new"
      tail stats_monthly_ebookcentral_fulltext_data_new

while true; do
    read -p "Run? :" yn
    case $yn in
        [Yy]* ) ./vendor_statsload.pl -y; break;;
        [Nn]* ) exit;;
        * ) echo "Please answer yes or no.";;
    esac
done

# fulltext

echo "diff stats_monthly_ebookcentral_fulltext_data_new stats_monthly_ebookcentral_fulltext_data"
      diff stats_monthly_ebookcentral_fulltext_data_new stats_monthly_ebookcentral_fulltext_data

echo "cp   stats_monthly_ebookcentral_fulltext_data_new stats_monthly_ebookcentral_fulltext_data"
      cp   stats_monthly_ebookcentral_fulltext_data_new stats_monthly_ebookcentral_fulltext_data

echo "tail stats_monthly_ebookcentral_fulltext_data"
      tail stats_monthly_ebookcentral_fulltext_data

echo "tail stats_monthly_ebookcentral_fulltext_data_new"
      tail stats_monthly_ebookcentral_fulltext_data_new

echo "ls -la stats_monthly_ebookcentral_*data"
      ls -la stats_monthly_ebookcentral_*data

echo "ls -la stats_monthly_ebookcentral_*data_new"
      ls -la stats_monthly_ebookcentral_*data_new
