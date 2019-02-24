

clearvars; close all;
path_data = './icassp2019_data/rt_feats/';


sub_fname{1} = 'randforest_mu_val_subwise.csv';
sub_fname{2} = 'randforest_mu_train_subwise.csv';
sub_fname{3} = 'randforest_std_val_subwise.csv';
sub_fname{4} = 'randforest_std_train_subwise.csv';
sub_fname{5} = 'randforest_featImportance_subwise.csv';


pool_fname = cell(5,4);
for i = 1:4
pool_fname{1,i} = ['randforest_mu_val_subpool_' num2str(i) '.csv'];
pool_fname{2,i} = ['randforest_mu_train_subpool_' num2str(i) '.csv'];
pool_fname{3,i} = ['randforest_std_val_subpool_' num2str(i) '.csv'];
pool_fname{4,i} = ['randforest_std_train_subpool_' num2str(i) '.csv'];
pool_fname{5,i} = ['randforest_featImportance_subpool_' num2str(i) '.csv'];
end

pred_fname{1} = 'randforest_pred_val_subpool.csv';
pred_fname{2} = 'randforest_pred_train_subpool.csv';

sub_data = cell(5,1);
for i = 1:length(sub_fname)
    sub_data{i} = readtable([path_data sub_fname{i}],'Delimiter',',');
end

pool_data = cell(5,4);
for i = 1:length(pool_fname)
    for j = 1:4
        pool_data{i,j} = readtable([path_data pool_fname{i,j}],'Delimiter',',');
    end
end

pred_data = cell(2,1);
for i = 1:length(pred_fname)
    pred_data{i} = readtable([path_data pred_fname{i}],'Delimiter',',');
end

rt_data = readtable([path_data 'subject_wise_rt_featsDist_dur_4.csv'],'Delimiter',',');


% ----- make plots
close all;
FS = 'fontsize'; MS = 'markersize'; LW = 'linewidth'; JL = 'jumpline';
FSval = 6; 
LWval = 0.5;
MSval = 4;


if 0
% subjectwise
figure;
b(1) = bar((1:length(sub_data{2}.Var1))-0.25,sub_data{2}.Var1*100,'BarWidth',0.2); hold on;
b(1).FaceColor = [0 0.5 0];
errorbar((1:length(sub_data{2}.Var1))-0.25,sub_data{2}.Var1*100,sub_data{4}.Var1*100,'.','color','k')

b(2) = bar((1:length(sub_data{1}.Var1)),sub_data{1}.Var1*100,'BarWidth',0.2); hold on;
b(2).FaceColor = [0 0.5 1];
errorbar((1:length(sub_data{1}.Var1)),sub_data{1}.Var1*100,sub_data{3}.Var1*100,'.','color','k')
grid on;
ylabel('% EXPLAINED VARIANCE');
xlabel('SUBJECT INDEX');
xticks([1:17])
xticklabels({'1','2','3','4','5','6','7','8','9',...
             '10','11','12','13','14','15','16','17'});
% yticks([0 5 10 15])
% yticklabels({'45','60','75','90','100','5','10','15','20'});
xlim([0 18]);
ylim([0 100]);
grid on;
h = text(0.80,90,'TRAIN','Color',[0 0.5 0],'FontSize',FSval,'HorizontalAlignment','center');
set(h,'Rotation',90);
h = text(1,60,'VAL','Color',[0 0.5 1],'FontSize',FSval,'HorizontalAlignment','center');
set(h,'Rotation',90);
set(gca,FS,FSval,'box','on');
set(gca, ...
  'Box'         , 'off'     , ...
  'TickDir'     , 'out'     , ...
  'TickLength'  , [.02 .02] , ...
  'XMinorTick'  , 'off'      , ...
  'YMinorTick'  , 'on'      , ...
  'YGrid'       , 'on'      );
% set(gca,'OuterPosition',[left bottom + 0.1 width height])
if 1
 % move legend and again save offline
    set(gcf, 'PaperUnits', 'centimeters');
    set(gcf, 'PaperPosition', [0 0 10 5]); %x_width=10cm y_width=sel_nharmcm        
    saveas(gcf,['./figures/randforest_subwise_barplot_perfm.fig']);
    print(['./figures/randforest_subwise_barplot_perfm.eps'],'-depsc','-r300');    
end


% pooled 
figure;

for i = 1:4
b(1) = bar((1:length(pool_data{2,i}.Var1))-0.25+(i-1),pool_data{2,i}.Var1*100,'BarWidth',0.2); hold on;
b(1).FaceColor = [0 0.5 0];
errorbar((1:length(pool_data{2,i}.Var1))-0.25+(i-1),pool_data{2,i}.Var1*100,pool_data{4,i}.Var1*100,'.','color','k')

b(2) = bar((1:length(pool_data{1,i}.Var1))+(i-1),pool_data{1,i}.Var1*100,'BarWidth',0.2); hold on;
b(2).FaceColor = [0 0.5 1];
errorbar((1:length(pool_data{1,i}.Var1))+(i-1),pool_data{1,i}.Var1*100,pool_data{3,i}.Var1*100,'.','color','k');
end

grid on;
ylabel('% EXPLAINED VARIANCE');
xlabel('% SEGMENT BEFORE CHANGE INSTANT');
xticks([1:4])
xticklabels({'25','50','75','100'});
xtickangle(0);
xlim([0.5 4.25]);
ylim([30 80]);
grid on;
h = text(0.70,75,'TRAIN','Color',[0 0.5 0],'FontSize',FSval,'HorizontalAlignment','center');
set(h,'Rotation',90);
h = text(1,50,'VAL','Color',[0 0.5 1],'FontSize',FSval,'HorizontalAlignment','center');
set(h,'Rotation',90);
set(gca,FS,FSval,'box','on');
set(gca, ...
  'Box'         , 'off'     , ...
  'TickDir'     , 'out'     , ...
  'TickLength'  , [.02 .02] , ...
  'XMinorTick'  , 'off'      , ...
  'YMinorTick'  , 'on'      , ...
  'YGrid'       , 'on'      );
% set(gca,'OuterPosition',[left bottom + 0.1 width height])
if 1
 % move legend and again save offline
    set(gcf, 'PaperUnits', 'centimeters');
    set(gcf, 'PaperPosition', [0 0 4 5]); %x_width=10cm y_width=sel_nharmcm        
    saveas(gcf,['./figures/randforest_subpool_barplot_perfm.fig']);
    print(['./figures/randforest_subpool_barplot_perfm.eps'],'-depsc','-r300');    
end

% from pool_data{5}.Variables
feats_type_merge = {'F0','lsf','mel','mfcc','mfcc_{d1}','mfcc_{d2}',...
    'temp','percp','spect'};

perfm = [0.04 0.05 0.06 0.04 0.45 0.23 0.05 0.038 0.045];
% feature importance
figure; plot(perfm,'--o','color','k','MarkerSize',MSval,'MarkerFaceColor',[0 0.5 0]);
grid on;
ylabel('IMPORTANCE SCORE');
xlabel('FEATURE TYPE');
xticks([1:9])
xticklabels({'F0','LSF','MEL','MFCC','MFCC-D1','MFCC-D2','TEMP','PERCP','SPECT'});
xtickangle(45);
xlim([0.5 9.5]);
ylim([0 0.6]);
grid on;
set(gca,FS,FSval,'box','on');
set(gca, ...
  'Box'         , 'off'     , ...
  'TickDir'     , 'out'     , ...
  'TickLength'  , [.02 .02] , ...
  'XMinorTick'  , 'off'      , ...
  'YMinorTick'  , 'on'      , ...
  'YGrid'       , 'on'      );
% set(gca,'OuterPosition',[left bottom + 0.1 width height])
if 1
 % move legend and again save offline
    set(gcf, 'PaperUnits', 'centimeters');
    set(gcf, 'PaperPosition', [0 0 5 5]); %x_width=10cm y_width=sel_nharmcm        
    saveas(gcf,['./figures/randforest_feat_perfm_subpool.fig']);
    print(['./figures/randforest_feat_perfm_subpool.eps'],'-depsc','-r300');    
end


% scatter plot of RT and Predicted RT from pooled data
figure;
plot(pred_data{1}.Var2,pred_data{1}.Var2,'-','color',[0.7 0.7 0.7]);hold on;
scatter_kde(pred_data{1}.Var2,pred_data{1}.Var1,'Marker','.','MarkerSize',15);%,'DisplayStyle','tile','ShowEmptyBins','on','NumBins',[100 100]);
grid on;
h = text(300,1000,['r=' num2str(0.76)],'Color',[0 0 0],'FontSize',FSval,'HorizontalAlignment','center');
xlabel('REACTION TIME [in msec]')
ylabel('PREDICTED REACTION TIME [in msec]')
set(gca,FS,FSval,'box','on');
set(gca, ...
  'Box'         , 'off'     , ...
  'TickDir'     , 'out'     , ...
  'TickLength'  , [.02 .02] , ...
  'XMinorTick'  , 'off'      , ...
  'YMinorTick'  , 'on'      , ...
  'YGrid'       , 'on'      );
% set(gca,'OuterPosition',[left bottom + 0.1 width height])
if 1
 % move legend and again save offline
    set(gcf, 'PaperUnits', 'centimeters');
    set(gcf, 'PaperPosition', [0 0 5 5]); %x_width=10cm y_width=sel_nharmcm        
    saveas(gcf,['./figures/randforest_val_predictions_subpool.fig']);
    print(['./figures/randforest_val_predictions_subpool.eps'],'-depsc','-r300');    
end

plot(pred_data{2}.Var2,pred_data{2}.Var2,'-','color',[0.7 0.7 0.7]);hold on;
scatter_kde(pred_data{2}.Var2,pred_data{2}.Var1,'Marker','.','MarkerSize',15);%,'DisplayStyle','tile','ShowEmptyBins','on','NumBins',[100 100]);
grid on;
h = text(300,1000,['r=' num2str(0.86)],'Color',[0 0 0],'FontSize',FSval,'HorizontalAlignment','center');
xlabel('REACTION TIME [in msec]')
ylabel('PREDICTED REACTION TIME [in msec]')
set(gca,FS,FSval,'box','on');
set(gca, ...
  'Box'         , 'off'     , ...
  'TickDir'     , 'out'     , ...
  'TickLength'  , [.02 .02] , ...
  'XMinorTick'  , 'off'      , ...
  'YMinorTick'  , 'on'      , ...
  'YGrid'       , 'on'      );
% set(gca,'OuterPosition',[left bottom + 0.1 width height])
if 1
 % move legend and again save offline
    set(gcf, 'PaperUnits', 'centimeters');
    set(gcf, 'PaperPosition', [0 0 5 5]); %x_width=10cm y_width=sel_nharmcm        
    saveas(gcf,['./figures/randforest_train_predictions_subpool.fig']);
    print(['./figures/randforest_train_predictions_subpool.eps'],'-depsc','-r300');    
end

end


% plot RT versus feats
MSval = 2;
FSval = 4;
indx = find(rt_data.ID~=0);
figure;
Y = rt_data.RT(indx);
X = rt_data.F0(indx);
X_a = [ones(length(X),1) X];
b = pinv(X_a)*Y;
Y1 = [ones(length(X),1) sort(X)]*b;

plot(X,Y,'o','color',[0 0.5 1],'MarkerSize',MSval-1,'MarkerFaceColor',[0 0.5 1],'MarkerEdgeColor',[0.5 0.5 0.5]); hold on;
plot(sort(X),Y1,'-','color','k','MarkerSize',MSval-1,'MarkerFaceColor',[0 0.5 1],LW,LWval);
grid on;
ylabel('REACTION TIME [in msec]');
xlabel('DISTANCE');
% xticks([1:9])
% xticklabels({'F0','LSF','MEL','MFCC','MFCC-D1','MFCC-D2','TEMP','PERCP','SPECT'});
% xtickangle(45);
% xlim([0 5]);
ylim([0 2000]);
grid on;
set(gca,FS,FSval,'box','on');
set(gca, ...
  'Box'         , 'off'     , ...
  'TickDir'     , 'out'     , ...
  'TickLength'  , [.02 .02] , ...
  'XMinorTick'  , 'off'      , ...
  'YMinorTick'  , 'on'      , ...
  'YGrid'       , 'on'      );
% set(gca,'OuterPosition',[left bottom + 0.1 width height])
if 1
 % move legend and again save offline
    set(gcf, 'PaperUnits', 'centimeters');
    set(gcf, 'PaperPosition', [0 0 3 4]); %x_width=10cm y_width=sel_nharmcm        
    saveas(gcf,['./figures/randforest_f0_rt_subpool.fig']);
    print(['./figures/randforest_f0_rt_subpool.eps'],'-depsc','-r300');    
end

figure;
Y = rt_data.RT(indx);
X = rt_data.MFCC(indx);
X_a = [ones(length(X),1) X];
b = pinv(X_a)*Y;
Y1 = [ones(length(X),1) sort(X)]*b;

plot(X,Y,'o','color',[0 0.5 1],'MarkerSize',MSval-1,'MarkerFaceColor',[0 0.5 1],'MarkerEdgeColor',[0.5 0.5 0.5]); hold on;
plot(sort(X),Y1,'-','color','k','MarkerSize',MSval-1,'MarkerFaceColor',[0 0.5 1],LW,LWval);

grid on;
% ylabel('REACTION TIME [in msec]');
xlabel('DISTANCE');
% xticks([1:9])
% xticklabels({'F0','LSF','MEL','MFCC','MFCC-D1','MFCC-D2','TEMP','PERCP','SPECT'});
% xtickangle(45);
% xlim([0 5]);
ylim([0 2000]);
grid on;
set(gca,FS,FSval,'box','on');
set(gca, ...
  'Box'         , 'off'     , ...
  'TickDir'     , 'out'     , ...
  'TickLength'  , [.02 .02] , ...
  'XMinorTick'  , 'off'      , ...
  'YMinorTick'  , 'on'      , ...
  'YGrid'       , 'on'      );
% set(gca,'OuterPosition',[left bottom + 0.1 width height])
if 1
 % move legend and again save offline
    set(gcf, 'PaperUnits', 'centimeters');
    set(gcf, 'PaperPosition', [0 0 3 4]); %x_width=10cm y_width=sel_nharmcm        
    saveas(gcf,['./figures/randforest_mfcc_rt_subpool.fig']);
    print(['./figures/randforest_mfcc_rt_subpool.eps'],'-depsc','-r300');    
end


figure;
Y = rt_data.RT(indx);
X = rt_data.MFCC_D1(indx);
X_a = [ones(length(X),1) X];
b = pinv(X_a)*Y;
Y1 = [ones(length(X),1) sort(X)]*b;

plot(X,Y,'o','color',[0 0.5 1],'MarkerSize',MSval-1,'MarkerFaceColor',[0 0.5 1],'MarkerEdgeColor',[0.5 0.5 0.5]); hold on;
plot(sort(X),Y1,'-','color','k','MarkerSize',MSval-1,'MarkerFaceColor',[0 0.5 1],LW,LWval);
grid on;
% ylabel('REACTION TIME [in msec]');
xlabel('DISTANCE');
% xticks([1:9])
% xticklabels({'F0','LSF','MEL','MFCC','MFCC-D1','MFCC-D2','TEMP','PERCP','SPECT'});
% xtickangle(45);
% xlim([0 5]);
ylim([0 2000]);
grid on;
set(gca,FS,FSval,'box','on');
set(gca, ...
  'Box'         , 'off'     , ...
  'TickDir'     , 'out'     , ...
  'TickLength'  , [.02 .02] , ...
  'XMinorTick'  , 'off'      , ...
  'YMinorTick'  , 'on'      , ...
  'YGrid'       , 'on'      );
% set(gca,'OuterPosition',[left bottom + 0.1 width height])
if 1
 % move legend and again save offline
    set(gcf, 'PaperUnits', 'centimeters');
    set(gcf, 'PaperPosition', [0 0 3 4]); %x_width=10cm y_width=sel_nharmcm        
    saveas(gcf,['./figures/randforest_mfcc_d1_rt_subpool.fig']);
    print(['./figures/randforest_mfcc_d1_rt_subpool.eps'],'-depsc','-r300');    
end



