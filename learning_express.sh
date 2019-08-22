#! /usr/bin/bash

echo "ls -la stats_monthly_learning_express_*data"
      ls -la stats_monthly_learning_express_*data

# -rw-rw-r--   1 oclc     oclc       62272 Aug 13 16:20 stats_monthly_learning_express_fulltext_data
# -rw-rw-r--   1 oclc     oclc       60286 Aug 13 16:21 stats_monthly_learning_express_sessions_data

echo "ls -la stats_monthly_learning_express_*data_new"
      ls -la stats_monthly_learning_express_*data_new

# -rw-rw-r--   1 bmb      oclc       62272 Aug 13 16:19 stats_monthly_learning_express_fulltext_data_new
# -rw-rw-r--   1 bmb      oclc       60286 Aug 13 16:19 stats_monthly_learning_express_sessions_data_new

# fulltext

echo "tail stats_monthly_learning_express_fulltext_data"
      tail stats_monthly_learning_express_fulltext_data

echo "tail stats_monthly_learning_express_fulltext_data_new"
      tail stats_monthly_learning_express_fulltext_data_new

# sessions

echo "tail stats_monthly_learning_express_sessions_data"
      tail stats_monthly_learning_express_sessions_data

echo "tail stats_monthly_learning_express_sessions_data_new"
      tail stats_monthly_learning_express_sessions_data_new

while true; do
    read -p "Run? :" yn
    case $yn in
        [Yy]* ) ./vendor_statsload.pl -x; break;;
        [Nn]* ) exit;;
        * ) echo "Please answer yes or no.";;
    esac
done

# fulltext

echo "diff stats_monthly_learning_express_fulltext_data_new stats_monthly_learning_express_fulltext_data"
      diff stats_monthly_learning_express_fulltext_data_new stats_monthly_learning_express_fulltext_data
echo "cp   stats_monthly_learning_express_fulltext_data_new stats_monthly_learning_express_fulltext_data"
      cp   stats_monthly_learning_express_fulltext_data_new stats_monthly_learning_express_fulltext_data

echo "tail stats_monthly_learning_express_fulltext_data"
      tail stats_monthly_learning_express_fulltext_data

echo "tail stats_monthly_learning_express_fulltext_data_new"
      tail stats_monthly_learning_express_fulltext_data_new

# sessions

echo "diff stats_monthly_learning_express_sessions_data_new stats_monthly_learning_express_sessions_data"
      diff stats_monthly_learning_express_sessions_data_new stats_monthly_learning_express_sessions_data
echo "cp   stats_monthly_learning_express_sessions_data_new stats_monthly_learning_express_sessions_data"
      cp   stats_monthly_learning_express_sessions_data_new stats_monthly_learning_express_sessions_data

echo "tail stats_monthly_learning_express_sessions_data"
      tail stats_monthly_learning_express_sessions_data

echo "tail stats_monthly_learning_express_sessions_data_new"
      tail stats_monthly_learning_express_sessions_data_new

echo "ls -la stats_monthly_learning_express_*data"
      ls -la stats_monthly_learning_express_*data

echo "ls -la stats_monthly_learning_express_*data_new"
      ls -la stats_monthly_learning_express_*data_new

