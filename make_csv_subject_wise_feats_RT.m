
clearvars;
close all;

feats_type = {'mfcc', 'mfcc_d1','mfcc_d2','engy','envp','lsf','loudness','mel','psharp','pspread', ...
         'sflat','sflux','sroll','sshape','sslope','tshape','zcr','f0'};
     
feats_path = './data/fEATS/libriSpeech/test-listener-wise-data/M_5_spkrs_8_pairs_v0/added_part/';

flist = dir([feats_path feats_type{1} '/' '*.h5']);
nfiles = length(flist);

ptcpnt_id = {'CMU-1','cmu2','CMU_3','CMU-4','cmu_5','CMU_6','CMV-7','CMU_8','cmu_9','CMU_10','cmu_11','cmu12',...
    'CMU_13','CMU-14','cmu_15','CMU_16','CMU_17','iisc_01','iisc_02','iisc_03','iisc_04','iisc_05','iisc_06',...
    'iisc_07','iisc_08','iisc_09','iisc_10','iisc_11','iisc_12'};

sel_subjs =  [13:17 18:25 26:29];

data_path = './data/rt_feats/';
% data_std = readtable([data_path 'subject_wise_mean_rt.csv'],'Delimiter',',');
data_std = readtable([data_path 'subject_wise_noise_mean_rt.csv'],'Delimiter',',');

indx_subj = cell(length(ptcpnt_id),1);
for i = 1:length(ptcpnt_id)
    indx_subj{i} = [];
    for j = 1:nfiles
        if length(strfind(flist(j).name,ptcpnt_id{i}))
            indx_subj{i} =[indx_subj{i} j]; 
        end
    end
end

rt = cell(length(ptcpnt_id),1);
feats_dist = cell(length(ptcpnt_id),4);
flag_same_spk = cell(length(ptcpnt_id),1);
flag_resp = cell(length(ptcpnt_id),1);
label = cell(length(ptcpnt_id),1);
fname_id = cell(length(ptcpnt_id),1);

feats_type_merge = {'F0','lsf','mel','mfcc','mfcc_{d1}','mfcc_{d2}',...
    'temp','percp','spect'};
feats = cell(length(feats_type_merge),1);

cnt = 1;

for loop = sel_subjs
    rt{loop} = zeros(1,length(indx_subj{loop}));
    flag_same_spk{loop} = zeros(1,length(indx_subj{loop}));
    flag_resp{loop} = zeros(1,length(indx_subj{loop}));
    label{loop} = zeros(1,length(indx_subj{loop}));
    feats_dist{loop} = zeros(length(indx_subj{loop}),length(feats_path));
    fname_id{loop} = cell(length(indx_subj{loop}),1);
    for i = 1:length(indx_subj{loop})
        [fpath,fname,fext] = fileparts([feats_path feats_type{1} '/' flist(indx_subj{loop}(i)).name]);
        fname_id{loop}{i} = fname;
        indx = strfind(fname,'_');
        str_1 = 'tChange_';
        str_2 = '_ms_rstamp';

        indx_1 = strfind(fname,str_1)+length(str_1);
        indx_2 = strfind(fname,str_2)-1;
        tChange = str2double(fname(indx_1:indx_2));
        
        str_1 = 'rstamp_';
        str_2 = '_ms_flag';

        indx_1 = strfind(fname,str_1)+length(str_1);
        indx_2 = strfind(fname,str_2)-1;
        rChange = str2double(fname(indx_1:indx_2));
        temp = rChange - tChange;
        
        str_1 = '_lid';
        indx_1 = strfind(fname,str_1)-1;
        flag_resp{loop}(i) = str2double(fname(indx_1));
        
        rt{loop}(i) = temp;
        
        spk_1 = str2double(fname(indx(1)+1:indx(2)-1));
        spk_2 = str2double(fname(indx(6)+1:indx(7)-1));
        if spk_1 == spk_2
            flag_same_spk{loop}(i) = 1;
        else
            flag_same_spk{loop}(i) = 0;
        end

        if (temp>225 && temp < 2000 && flag_resp{loop}(i) && ~flag_same_spk{loop}(i))
            label{loop}(i) = 3; % hit
        elseif (temp>2000 && ~flag_resp{loop}(i) && ~flag_same_spk{loop}(i))
            label{loop}(i) = 2; % miss
        elseif ((~flag_resp{loop}(i) && flag_same_spk{loop}(i)) || ...
                (temp<225 && ~flag_resp{loop}(i) && ~flag_same_spk{loop}(i)))
            label{loop}(i) = 1; % false alarm
        else
            label{loop}(i) = 0; % junk
        end
        
        feats_set = {{'f0'},{'lsf'},{'mel'},{'mfcc'},{'mfcc_d1'},{'mfcc_d2'},...
            {'engy'},{'loudness','psharp','pspread'},...
            {'sflat','sflux','sroll','sshape','sslope'}};
        
        % ----- read feats
        for j = 1:length(feats_set)
            feats{j} = [];
            for k = 1:length(feats_set{j})
                if j == 7 % take rate of change in energy as a feature
                    temp = hdf5read([feats_path feats_set{j}{k} '/' fname],[feats_set{j}{k} '_framewise']);
                    feats{j} = [feats{j};[diff(temp) 0]];
                else
                    temp = hdf5read([feats_path feats_set{j}{k} '/' fname],[feats_set{j}{k} '_framewise']);
                    feats{j} = [feats{j};temp];
                end
            end
            if k>1 % mean variance normalization for merged feature sets 
                feats{j} = (feats{j}-mean(feats{j},2))./sqrt(var(feats{j},0,2));
            end
            if j == 1 % pitch feature needs to be a column vector
                feats{j} = feats{j}.';
            end
        end
        % ----- compute distance fraction wise
        frac = [25 50 75 100];
        for j = 1:length(feats)
            % get voiced indices
            indx_unvoiced = [];%find(feats{1}<10);
            flag_all_frames = 1;
            if label{loop}(i) == 3
                for l = 1:4
                    clen = fix(tChange/10)-10;
                    slen = fix((l/4)*clen);
                    rlen = fix(rChange/10);

                    % zero out the unvoiced regions
                    feats{j}(:,indx_unvoiced) = 0;

                    mu = feats{j}(:,clen-slen+1:clen);
                    if ~flag_all_frames
                        tmp = diag(mu'*mu);
                        thr = .001*mean(tmp);
                        tmp_indx = find(diag(mu'*mu)>thr);
                        if length(tmp_indx)==0
                            centroid = zeros(size(mu,1),1);
                        else
                            centroid = mean(mu(:,tmp_indx),2);
                        end
                    else
                        centroid = mean(mu,2);
                    end
                    y = feats{j}(:,clen+1:rlen);
                    if ~flag_all_frames
                        tmp = diag(y'*y);
                        thr = .001*mean(tmp);
                        tmp_indx = find(diag(y'*y)>thr);
                        if length(tmp_indx)==0
                            mu = zeros(size(y,1),1);
                        else
                            mu = mean(y(:,tmp_indx),2);
                        end
                    else
                        mu = mean(y,2);
                    end

                    feats_dist{loop,l}(i,j) = norm(centroid-mu);
                    if isnan(feats_dist{loop,l}(i,j))
                        disp('Check for NaN');
                        return;
                    end
               end
            else
               feats_dist{loop,l}(i,j) = 0;
            end
        end
    end
    for j = 1:length(feats)
        for k = 1:4
            feats_std = std(feats_dist{loop,k}((feats_dist{loop,k}(:,j)>0),j));
            feats_dist{loop,k}(:,j) = feats_dist{loop,k}(:,j)/feats_std;
        end
        
    end
end


% pool subjectwise data into a CSV file
store_path = './data/rt_feats/';
fileID = cell(4,1);
for i = 1:4
fileID{i} = fopen([store_path 'subject_wise_rt_featsDist_dur_' num2str(i) '.csv'],'w');
fprintf(fileID{i},'ID,SUB_ID,FILE_ID,RT,F0,LSF,MEL,MFCC,MFCC_D1,MFCC_D2,TEMP,PERCP,SPECT\n');
end


for i = 1:length(sel_subjs)
    indx_subj = sel_subjs(i);
    indx_hit = find(label{indx_subj}==3);

    for j = 1:length(indx_hit) % indx hits
        for l = 1:4 %indx duration
            fprintf(fileID{l},'%d,%s,%s,%.4f,%.4f,%.4f,%.4f,%.4f,%.4f,%.4f,%.4f,%.4f,%.4f\n',...
                i,ptcpnt_id{indx_subj},fname_id{indx_subj}{indx_hit(j)},rt{indx_subj}(indx_hit(j)),...
                feats_dist{indx_subj,l}(indx_hit(j),1),feats_dist{indx_subj,l}(indx_hit(j),2),...
                feats_dist{indx_subj,l}(indx_hit(j),3),feats_dist{indx_subj,l}(indx_hit(j),4),...
                feats_dist{indx_subj,l}(indx_hit(j),5),feats_dist{indx_subj,l}(indx_hit(j),6),...
                feats_dist{indx_subj,l}(indx_hit(j),7),feats_dist{indx_subj,l}(indx_hit(j),8),...
                feats_dist{indx_subj,l}(indx_hit(j),9));
        end
    end
end
for i = 1:4
fclose(fileID{i});
end

return;

        
 
