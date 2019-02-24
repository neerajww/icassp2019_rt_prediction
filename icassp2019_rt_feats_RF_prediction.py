# Last edit by Neeraj Sharma on 24 Feb 2019, EST
# Code for RT modeling using random forests.
# Results presented in conference paper: 
# ANALYZING HUMAN REACTION TIME FOR TALKER CHANGE DETECTION, at ICASSP 2019

# load packages
from fastai.imports import *
from fastai.structured import *
from pandas_summary import DataFrameSummary
from sklearn.ensemble import RandomForestRegressor, RandomForestClassifier
from IPython.display import display
from sklearn import metrics

# define functions
def display_all(df):
    with pd.option_context("display.max_rows",1000,"display.max_columns",1000):
        display(df)
def split_vals(a,n): return a[:n].copy(), a[n:].copy()
def rmse(x,y): return math.sqrt(((x-y)**2).mean())
def print_score(m):
    res = [rmse(m.predict(X_train),y_train), rmse(m.predict(X_valid),y_valid),
           m.score(X_train,y_train), m.score(X_valid,y_valid)]
    if hasattr(m,'oob_score_'): res.append(m.oob_score)
    print(res)
def mean_confidence_interval(data, confidence=0.95):
    a = 1.0 * np.array(data)
    n = len(a)
    m, se = np.mean(a), scipy.stats.sem(a)
    h = se * scipy.stats.t.ppf((1 + confidence) / 2., n-1)
    return m, se

# init path
data_PATH = "./icassp2019_data/rt_feats/"
store_PATH = "./icassp2019_data/rt_feats/"
file_name = 'subject_wise_rt_featsDist_dur_' # initials of RT + FEATs distance data files [25 50 75 100]

# load data
# file_name index [1 2 3 4] <=> duration [25 50 75 100]
durSet = iter([1,2,3,4])
for durID in durSet:
    df_raw = pd.read_csv(f'{data_PATH}{file_name}{durID}.csv',low_memory=False)
    df_raw.RT = np.log10(df_raw.RT)

    # view a snapshot of the data
    # display(df_raw.head()) # head/tail by default picks up 5 rows

    ## Section 1: subjectwise train-val
    # get subject IDs
    IDs = df_raw.ID.unique()

    # init variables
    nvals = 10 # 10-fold cross validation
    r_score_train = np.zeros((len(IDs),nvals),dtype=float)
    r_score_val = np.zeros((len(IDs),nvals),dtype=float)

    r_score_mu_train = np.zeros((len(IDs),1),dtype=float)
    r_score_mu_val = np.zeros((len(IDs),1),dtype=float)
    r_score_ci_train = np.zeros((len(IDs),1),dtype=float)
    r_score_ci_val = np.zeros((len(IDs),1),dtype=float)

    # init cross validation module
    reset_rf_samples()
    from sklearn.model_selection import RepeatedKFold 
    rkf = RepeatedKFold(n_splits=nvals, n_repeats=1, random_state=1)

    # loop random forest training and validation for each subject
    for i in range(len(IDs)):
        # get subject data
        df_raw_sub = df_raw.loc[df_raw['ID'] == IDs[i]]
        df_raw_sub = df_raw_sub.reset_index()
        df_raw_sub = df_raw_sub.drop(['ID','SUB_ID','FILE_ID'],axis=1)
        df_trn, y_trn, nas = proc_df(df_raw_sub,'RT')
        j = 0
        for train_index, valid_index in rkf.split(np.zeros(len(y_trn))):
    #         print("Train:", len(train_index), "Validation:",len(val_index))
            X_train, X_valid = df_trn.loc[train_index].copy(), df_trn.loc[valid_index].copy() 
            y_train, y_valid = y_trn[train_index], y_trn[valid_index]

            m = RandomForestRegressor(n_estimators=40,min_samples_leaf=5,n_jobs=-1)
            m.fit(X_train,y_train)

            if j == 0:
                df_imp = pd.DataFrame(m.feature_importances_,index = X_train.columns,columns
                                           = ['importance']).sort_values('importance',ascending=False)
                df_imp = df_imp.T
                df_imp = df_imp[['F0','LSF','MEL','MFCC','MFCC_D1','MFCC_D2','TEMP','PERCP','SPECT']]
            else:
                df_imp_1 = pd.DataFrame(m.feature_importances_,index = X_train.columns,columns
                                           = ['importance']).sort_values('importance',ascending=False)
                df_imp_1 = df_imp_1.T
                df_imp_1 = df_imp_1[['F0','LSF','MEL','MFCC','MFCC_D1','MFCC_D2','TEMP','PERCP','SPECT']]

                frames = [df_imp, df_imp_1]
                df_imp = pd.concat(frames)

            r_score_train[i,j] = m.score(X_train,y_train)
            r_score_val[i,j] = m.score(X_valid,y_valid)
            j = j+1
        # summarize feat importance
        if i == 0:
            df_feat_imp = pd.DataFrame(df_imp.mean(axis=0)).T
        else:
            df_feat_imp_1 = pd.DataFrame(df_imp.mean(axis=0)).T
            frames = [df_feat_imp, df_feat_imp_1]
            df_feat_imp = pd.concat(frames)
        # store subjectwise train and val mean scores
        r_score_mu_train[i], r_score_ci_train[i] = mean_confidence_interval(r_score_train[i,:], confidence=0.95)
        r_score_mu_val[i], r_score_ci_val[i] = mean_confidence_interval(r_score_val[i,:], confidence=0.95)

    #print(r_score_val)
    # plotting
    if 0:
        fig, axs = plt.subplots(nrows=1, ncols=2, sharex=True)
        ax = axs[0]
        ax.errorbar(np.arange(1,18), r_score_mu_train, yerr=r_score_ci_train, fmt='-o')
        ax.set_title('Training r-square')

        ax = axs[1]
        ax.errorbar(np.arange(1,18), r_score_mu_val, yerr=r_score_ci_val, fmt='-o')
        ax.set_title('Validation r-square')

    # store result score as csv
    if 0:
        np.savetxt(store_PATH+"randforest_mu_train_subwise_"+str(durID)+".csv", r_score_mu_train, delimiter=",")
        np.savetxt(store_PATH+"randforest_mu_val_subwise_"+str(durID)+".csv", r_score_mu_val, delimiter=",")
        np.savetxt(store_PATH+"randforest_std_train_subwise_"+str(durID)+".csv", r_score_ci_train, delimiter=",")
        np.savetxt(store_PATH+"randforest_std_val_subwise_"+str(durID)+".csv", r_score_ci_val, delimiter=",")
        df_feat_imp.to_csv(store_PATH+"randforest_featImportance_subwise_"+str(durID)+".csv", sep='\t', encoding='utf-8')

    ## Section 2: train-val by pooling all subject data
    nfeats = 9
    nvals = 5
    r_score_all_train = np.zeros((1,nvals),dtype=float)
    r_score_all_val = np.zeros((1,nvals),dtype=float)
    temp = np.zeros((nfeats,nvals),dtype=float)

    feats_importance = np.zeros((nfeats,nvals),dtype=float)

    r_score_all_mu_train = np.zeros((1,1),dtype=float)
    r_score_all_mu_val = np.zeros((1,1),dtype=float)
    r_score_all_ci_train = np.zeros((1,1),dtype=float)
    r_score_all_ci_val = np.zeros((1,1),dtype=float)

    rkf = RepeatedKFold(n_splits=nvals, n_repeats=1, random_state=1)


    df_raw_sub = df_raw.drop(['ID','SUB_ID','FILE_ID'],axis=1)
    # df_raw_sub = df_raw_sub[['MFCC_D1','MFCC_D2','RT']]
    df_trn, y_trn, nas = proc_df(df_raw_sub,'RT')
    j = 0
    i = 0
    for train_index, valid_index in rkf.split(np.zeros(len(y_trn))):
    #         print("Train:", len(train_index), "Validation:",len(val_index))
        X_train, X_valid = df_trn.loc[train_index].copy(), df_trn.loc[valid_index].copy() 
        y_train, y_valid = y_trn[train_index], y_trn[valid_index]
        set_rf_samples(int(len(y_train)*0.5))
        m = RandomForestRegressor(n_estimators=40,min_samples_leaf=5, n_jobs=-1)
        m.fit(X_train,y_train)

        if j == 0:
            df_imp = pd.DataFrame(m.feature_importances_,index = X_train.columns,columns
                                       = ['importance']).sort_values('importance',ascending=False)
            df_imp = df_imp.T
            df_imp = df_imp[['F0','LSF','MEL','MFCC','MFCC_D1','MFCC_D2','TEMP','PERCP','SPECT']]
        else:
            df_imp_1 = pd.DataFrame(m.feature_importances_,index = X_train.columns,columns
                                       = ['importance']).sort_values('importance',ascending=False)
            df_imp_1 = df_imp_1.T
            df_imp_1 = df_imp_1[['F0','LSF','MEL','MFCC','MFCC_D1','MFCC_D2','TEMP','PERCP','SPECT']]

            frames = [df_imp, df_imp_1]
            df_imp = pd.concat(frames)
        r_score_all_train[i,j] = m.score(X_train,y_train)
        r_score_all_val[i,j] = m.score(X_valid,y_valid)
        j = j+1
    df_feat_imp = pd.DataFrame(df_imp.mean(axis=0)).T
    r_score_all_mu_train[i], r_score_all_ci_train[i] = mean_confidence_interval(r_score_all_train[i,:], confidence=0.95)
    r_score_all_mu_val[i], r_score_all_ci_val[i] = mean_confidence_interval(r_score_all_val[i,:], confidence=0.95)

    print('[Train][Val] score for DurID '+str(durID))
    print(r_score_all_mu_train, r_score_all_mu_val)
    print(r_score_all_ci_train, r_score_all_ci_val)
    # display(df_feat_imp)

    # store result score as csv
    if 0:
        np.savetxt(store_PATH+"randforest_mu_train_subpool_"+str(durID)+".csv", r_score_all_mu_train, delimiter=",")
        np.savetxt(store_PATH+"randforest_mu_val_subpool_"+str(durID)+".csv", r_score_all_mu_val, delimiter=",")
        np.savetxt(store_PATH+"randforest_std_train_subpool_"+str(durID)+".csv", r_score_all_ci_train, delimiter=",")
        np.savetxt(store_PATH+"randforest_std_val_subpool_"+str(durID)+".csv", r_score_all_ci_val, delimiter=",")
        df_feat_imp.to_csv(store_PATH+"randforest_featImportance_subpool_"+str(durID)+".csv", sep='\t', encoding='utf-8')    

    # Obtain predicted RT data (Fig. 6 in paper)
    predict_train = np.zeros((len(y_train),2),float)
    predict_train[:,0] = np.power(10,m.predict(X_train))
    predict_train[:,1] = np.power(10,y_train)

    predict_val = np.zeros((len(y_valid),2),float)
    predict_val[:,0] = np.power(10,m.predict(X_valid))
    predict_val[:,1] = np.power(10,y_valid)

    # store data
    if 0:
        np.savetxt(store_PATH+"randforest_pred_train_subpool.csv", predict_train, delimiter=",")
        np.savetxt(store_PATH+"randforest_pred_val_subpool.csv", predict_val, delimiter=",")



