%--------------------------------------------------------------------------
% Name : EEG_ICA_kmeans.m
% 
% Author : Vanessa Palzes
% 
% Creation Date : 06/11/2014
% 
% Purpose : After running ICA on the EEG data, it is now important to try
% to understand what each of the independent components represent. When
% dealing with a large sample of subjects with many runs of different tasks,
% doing this task manually would be extremely burdensome. In addition,
% personal bias may be introduced in such a process, so having a more
% automatic way to characterize, or group, the components would be beneficial.
%
% I established this script to automate this process using kmeans to cluster
% the indpendent components. It will load all of the '.mat' ICA files for
% each subject and concatenate into one big structure where each row is a
% subject and each column is the component. Then it will run kmeans.
%
% You can specify what value of k you want, but given that my data has 32
% channels, I can get a maximum of 32 ICs. I run 1 through 32 to see what
% works the best.
%
% Inputs: None
%
% Output: A '.mat' file for each value of k that contains results from
% running kmeans on the ICA data.
%
% Last modified: Vanessa
% 
% Last run : 06/25/2014
%--------------------------------------------------------------------------

% Data dir
datadir = '';

% Subject .mat files
subs = dir([datadir '.mat']);
subs = {subs.name}';

% Channel info
NUM_CHANS = 32;
K = 32;

% Loop through subjects and add them into ICA
ICA = zeros(NUM_CHANS*length(subs),K);

for s = 1:length(subs)
    
    clear icaEEG
    
    % Get subject ID
    subjid = strtok(subs{s},'ica.mat');
    
    cprintf('blue','\nLoading %s...\n',subjid);
    
    % Load the data
    load(fullfile(datadir, subs{s}));
    
    % Current indices
    idx = [1:NUM_CHANS] + (NUM_CHANS*(s-1));
    
    % icawinv is 32 channels x 32 components, so need to transpose it
    % ICAinv will be rows of subjsxelec by 32 components
    ICA(idx,:) = icaEEG.icawinv';
    
end % end for subs

% Save ICA to .mat file
save(fullfile(datadir,'ICA.mat'));

% Tell me when it's saved
cprintf('blue','\nICA.mat file saved!\n');

% Run k means on the data with 1-32 clusters
for k = 1:K
    
    cprintf('blue','\nWorking on k=%i...\n',k);
    
    [IDX, C, SUMD, D] = kmeans(ICA, k);
    
    save(fullfile(datadir, ['kmeans' num2str(k) '.mat']),'IDX','C','SUMD','D');
    
end
