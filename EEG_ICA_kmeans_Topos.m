%--------------------------------------------------------------------------
% Name : EEG_ICA_kmeans_Topos.m
% 
% Author : Vanessa Palzes
% 
% Creation Date : 06/11/2014
% 
% Purpose : This will create topoplots for the clusters generated from
% kmeans on the ICAs for each subject. It can also create topoplots for each
% of the ICs and how they cluster together for a specific value of k.
%
% Inputs: None
%
% Output: '.png' files for each k cluster for each subject.
%
% Notes: 
%
% Last modified: Vanessa
% 
% Last run : 06/11/2014
%--------------------------------------------------------------------------

% Data dir
datadir = '';
outdir = '';

% Subject .mat files
subs = dir([datadir '*.mat']);
subs = {subs.name}';

% Load ICA data
load(fullfile(datadir, 'ICA.mat'));

% Load chanlocs (specific to EEG set-up)
load('chanlocs.mat');
load('channames.mat');
NUM_CHANS = 32;

for i = 1:NUM_CHANS
    
    % Make topos for the kmeans you want
    k = i;
    
    % Set paper size and subplots
    if i<=6
        paperSize = [12 3];
        plotSize = [1 k];
    elseif i>5 && i<=12
        paperSize = [12 4];
        plotSize = [2 6];
    elseif i>12 && i<=18
        paperSize = [12 6];
        plotSize = [3 6];
    elseif i>18 && i<=24
        paperSize = [12 8];
        plotSize = [4 6];
    elseif i>24 && i<=30
        paperSize = [12 10];
        plotSize = [5 6];
    else
        paperSize = [12 12];
        plotSize = [6 6];
    end 
    
    % Load kmeans data
    load(fullfile(datadir, ['kmeans' num2str(k) '.mat']));
    
    % File name for k cluster centroid topos
    fname = ['k' num2str(k) 'clusters.png'];
    
    % See if it's already been made
    if ~exist(fullfile(outdir, fname),'file');
        % Set up figure
        page = figure('NumberTitle', 'off', 'PaperOrientation', 'portrait', 'PaperPosition', [0 0 paperSize(1) paperSize(2)], 'Units', 'inches', 'Position', [0 0 paperSize(1) paperSize(2)]);
        % Load kmeans data
        load(fullfile(datadir,['kmeans' num2str(k) '.mat']));
        % C contains the centroids for each cluster
        min1 = min(min(C));
        max1= max(max(C));
        for i = 1:k
            subplot(plotSize(1),plotSize(2),i);
            topoplot(C(i,:),chanlocs);
            title(['Cluster ' num2str(i)]);
            %colorbar
        end
        % Save the plot
        print ('-dpng', fullfile(outdir, fname))
        close
    end
    
%     % Get standard deviation of all components from cluster centroid
%     for c = 1:k
%         % File name
%         fname = ['k' num2str(k) 'c' num2str(c) 'error.png'];
%         % See if it's already been made
%         if ~exist(fullfile(outdir, fname),'file');
%             cluster_diff = [];
%             cluster_idx = find(IDX==c);
%             cluster_std = std(ICA(cluster_idx,:));
%             for ci = 1:size(cluster_idx,1)
%                 cluster_diff(ci,:) = ICA(cluster_idx(ci),:) - C(c,:);
%             end
%             mean_cluster_diff = mean(cluster_diff,1);
%             
%             % Set up figure
%             page = figure('NumberTitle', 'off', 'PaperOrientation', 'portrait', 'PaperPosition', [0 0 10 7], 'Units', 'inches', 'Position', [0 0 10 7]);
%             
%             % Split into 2 subplots
%             % Make barplot
%             subplot(2,2,1:2);
%             bar(1:32,mean_cluster_diff);
%             set(gca,'XTick',1:32,'XTickLabel',channames,'FontSize',7);
%             title(['Centroid Difference k=' num2str(k) ', cluster=' num2str(c)],'FontSize',12,'FontWeight','bold');
%             
%             % Make topo
%             subplot(2,2,3);
%             topoplot(C(c,:),chanlocs);
%             title(['Centroid of Cluster ' num2str(c)]);
%             colorbar;
%             
%             subplot(2,2,4);
%             topoplot(mean_cluster_diff,chanlocs);
%             title('Mean Cluster-Centroid');
%             colorbar;
%             
% %             subplot(2,3,6);
% %             topoplot(cluster_std,chanlocs);
% %             title('Centroid STD');
% %             colorbar;
%             
%             % Save the plot
%             print ('-dpng', fullfile(outdir, fname))
%             close
%         end
%         
%     end    
end

% For each kmeans result, now you can plot how each of
% the ICs group together in clusters for the subjects

% k you want to plot for subjects
k = 7;

% Load kmeans data
load(fullfile(datadir,['kmeans' num2str(k) '.mat']));

% Loop through subjects
for s = 1:2
    
    % Get subject ID
    subjid = strtok(subs{s},'ica.mat');
    fname = [subjid ' k' num2str(k) ' cluster topo'];
    
    % Check if subject is already plotted
    if exist(fullfile(outdir,[fname '.png']),'file')
        cprintf('blue','\nSkipping %s...already done!\n',subjid);
        continue;
    end
    
    cprintf('blue','\nPlotting %s...\n',subjid);
    
    % Get indices of components
    idx = 1:32;
    idx = idx + (32 * (s-1));
    
    % Start Figure
    page = figure('NumberTitle', 'off', 'PaperOrientation', 'portrait', 'PaperPosition', [0 0 12 12], 'Units', 'inches', 'Position', [0 0 12 12]);
    
%     % Get min and max
%     min1 = min(min(ICA(idx,:)));
%     max1 = max(max(ICA(idx,:)));
    
    % Loop through components
    count = 1;
    for c = idx
        subplot(6,6,count);
        %topoplot(ICA(c,:), chanlocs, 'maplimits', [min1 max2]);
        topoplot(ICA(c,:), chanlocs);
        title(['Comp ' num2str(count) ' = Cluster ' num2str(IDX(c))]);
        %colorbar;
        count=count+1;
    end
    suplabel([subjid ' Component Clusters'],'t',[0 0 0.93 0.95]);
    
    % Save the plot
    print ('-dpng', fullfile(outdir, fname))
    close
    
end % end for subs
    
