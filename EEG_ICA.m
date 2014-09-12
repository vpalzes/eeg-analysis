%--------------------------------------------------------------------------
% Name : ERP_ICA.m
% 
% Author : Vanessa Palzes
% 
% Creation Date : 06/04/2014
% 
% Purpose : EEG recorded within the MRI scanner simultaneously suffers from
% severe artifacts that make it difficult to see the underlying brain
% responses. We recorded EEG data using a 32 channel BioSemi system, with FCz
% as a reference electrode.

% This script will run ICA on single trial data to identify
% independent components underlying the EEG signal. Hopefully this will
% help disambiguate EEG signals resulting from artifacts (e.g. muscle, 
% cardiobalistic, and MR) versus actual brain responses.
%
% I run this script after exporting single trial (stimulus/response time-
% locked epochs) from Brain Vision Analyzer, and then running canonical
% correlations based on Gratton & Coles methods as a first attempt to
% remove artifacts from the EEG. It will read in a '.mat' file with an EEG
% structure.
%
% Steps:
% 1. Undo FCz reference so we get FCz back. Add channel of 0s back, take
% average of each trial, subtract from all.
% 2. Merge all runs together into one EEG structure.
% 3. Do not include ECG channel in ICA.
%
% Inputs: None
%
% Output: A '.mat' file containing the subject's data (all runs) that have been
% run through ICA to determine independent components.
%
% Last modified: Vanessa
% 
% Last run : 07/22/2014
%--------------------------------------------------------------------------

clear
clc

% Data directories
datpath = '';
outpath = ''';

if ~exist(outpath,'dir')
    mkdir(outpath);
end

% Cell array list of subjects (e.g. {'Subject1'; 'Subject2'})
sublist = {};

% Cell array list of conditions (e.g. {'VisualRun1'; 'VisualRun2'}
condlist = {};

% Channel information
NUM_CHANS = 32;
ECG_CHAN = 32;
FCz_CHAN = 18;

% Epochs are 375 samples (-1000ms to 496ms)
% (Change based on your EEG setup)
NUM_SAMPLES = 375;
freqs = (250/375):(250/375):200;

% Baseline correction window
baseline = [-100 0];

% Set up matrices
allerps = zeros(size(sublist,1),size(condlist,1),NUM_CHANS,NUM_SAMPLES);
elecVec = [1:ECG_CHAN-1]; %32 is ECG - exclude from PCA
eeg_chans = 1:NUM_CHANS;
ALLEEG = [];

% For all subjects
for f = 1:length(sublist)
    
    sub = sublist{f};
    fname = [sub 'ica.mat'];
    
    if exist(fullfile(outpath,fname),'file')
        cprintf('comments','\nSkipping %s...already done!\n', sub);
        continue;
    end
    
    cprintf('comments', '\nWorking on %s...\n', sub);
    
    % Initialize EEG
    EEG = [];
    merge_EEG = [];
    ica_EEG = [];
    
    clear eeg avgeeg new_eeg
    
    % for all conditions
    for c = 1:size(condlist,1)
        
        % Current condition
        cond = deblank(condlist(c,:));
        condparts = strsplit(cond,'_');
        condName = [condparts{3} condparts{4}];
        run = condparts{2}(3);
        
        %         % NOTE: Average was taken BEFORE inserting FCz with 0s back into
        %         % the matrix for all data located in U:\export\ica
        %         % Get avgeeg (not including ECG) across chans not inc FCz 0s
        %         avgeeg = mean(eeg.data(1:31,:,:),1);
        
        try
            % Load the data
            load([datpath sub cond '.mat']);
            
            % Add in FCz at #18 chanloc
            new_eeg = eeg;
            new_eeg.nbchan = 33;
            new_eeg.data = zeros(new_eeg.nbchan,eeg.pnts,eeg.trials);
            new_eeg.data(1:FCz_CHAN-1,:,:) = eeg.data(1:FCz_CHAN-1,:,:);
            new_eeg.data(FCz_CHAN+1:new_eeg.nbchan,:,:) = eeg.data(FCz_CHAN:NUM_CHAN,:,:);
            new_eeg.chanlocs(FCz_CHAN).labels = 'FCz';
            new_eeg.chanlocs(FCz_CHAN+1:new_eeg.nbchan) = eeg.chanlocs(18:32);
            
            % Populate FCz position
            % Use EEG Lab's standard cap file
            new_eeg=pop_chanedit(new_eeg, 'lookup', ['\eeglab2007May07_beta\plugins\dipfit2.1\standard_BESA\standard-10-5-cap385.elp']);
            
            % Update eeg with changes
            eeg = new_eeg;
            
            % Get avgeeg (not including ECG) across chans inc FCz 0s
            avgeeg = mean(eeg.data(1:NUM_CHAN,:,:),1);
            
            % Create average reference (not including ECG)
            eeg.data(eeg_chans,:,:) = eeg.data(eeg_chans,:,:)-repmat(avgeeg, [NUM_CHAN,1]);
            
            % Baseline Correction
            for t = 1:eeg.trials
                eeg.data(:,:,t) = rmbase(eeg.data(:,:,t),eeg.pnts,find(eeg.times<=baseline(2) & eeg.times>=baseline(1)));
            end
            
            % Put into EEG cell matrix
            EEG = [EEG; eeg];
            
        catch error
            cprintf('blue', '\nCould not find %s\n', [datpath sub cond  '_noOcpL.mat']);
            
        end % end try
            
    end % end for condition
    
    % Merge datasets for subject
    merge_EEG = EEG(1);
    for d = 2:length(EEG)
        merge_EEG.epoch = [];
        merge_EEG = pop_mergeset(merge_EEG,EEG(d));
    end
    
    % Run ICA
    icaEEG = pop_runica(merge_EEG,'icatype','runica','verbose','off','chanind',eeg_chans);
    
    % Save .mat for each subject
    save(fullfile(outpath, fname),'icaEEG');
    
end % end for subject
