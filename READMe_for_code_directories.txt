READMe file for data in this repository which contains data for the paper:
=================
Title: ANALYZING HUMAN REACTION TIME FOR TALKER CHANGE DETECTION
Authors: Neeraj Sharma, Shobhana Ganesh, Sriram Ganapathy, Lori L. Holt
Conference: ICASSP 2019, May 12-19, Brighton, UK.
=================

Repository Guide:
=================
1. CSV file with subject ID, RT, FEATURES DISTANCE
    a. files are: subject_wise_rt_featsDist_dur_X.csv
    b. where X = {1->25%,2->50%,3->75%,4->100%} segment duration before change instant.
    
2. Random forest training and prediction
    a. Reads the files in 1. Does train and val computation for subjectwise log-RT prediction and save CSVs:
          i. randforest_mu_train_subwise_X.csv (X same as in 1.b above)
         ii. randforest_std_train_subwise_X.csv
        iii. same for validation
         iv. randforest_featImportance_subwise_X.csv
    c. Does train and val computation by pooling all subject data and saves CSVs:
          i. randforest_mu_train_subpool_X.csv (X same as in 1.b above)
         ii. randforest_std_train_subpool_X.csv
        iii. same for validation
         iv. randforest_featImportance_subpool_X.csv
          v. randforest_pred_train_subpool.csv (train set RT: (predict, actual)
         vi. randforest_pred_val_subpool.csv (val set RT: (predict, actual)

3. Plotting
    a. plot_randomForest_predictions.m
    b. uses csv files from 1 and 2 to make the plots in the paper.
     
4. The machine performance scores are present in:
    a. offlinePLDA_mean_hit_miss_fa.csv, offlinePLDA_talkerwise_fa.csv
    b. human_mean_hit_miss_fa.csv, human_talkerwise_fa.csv, human_subjectwise_hit_miss_fa.csv
===========
