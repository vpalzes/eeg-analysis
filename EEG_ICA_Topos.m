%--------------------------------------------------------------------------
% Name : EEG_ICA_Topos.m
% 
% Author : Vanessa Palzes
% 
% Creation Date : 06/11/2014
% 
% Purpose : This will create topoplots for the components generated in the
% ICA from EEG_ICA.m. Each subject should have a '.mat' file that contains
% an EEG structure with the data and the ICA output.
%
% Inputs: None
%
% Output: '.png' files for each subject's IC topoplots
%
% Last modified: Vanessa
% 
% Last run : 06/11/2014
%--------------------------------------------------------------------------

% Data dir
datadir = '';
outdir = '';

if ~exist(outdir,'dir')
    mkdir(outdir);
end

% Subject .mat files
subs = dir([datadir '*.mat']);
subs = {subs.name}';

% IC info
NUM_ICS = 32;

% Loop through subjects
for s = 1:length(subs)
    
    % Get subject ID
    subjid = strtok(subs{s},'ica.mat');
    fname = [subjid 'ICAtopo'];
    
    %Check if subject is already plotted
    if exist(fullfile(outdir,[fname '.png']),'file')
        cprintf('blue','\nSkipping %s...already done!\n',subjid);
        continue;
    end
    
    cprintf('blue','\nPlotting %s...\n',subjid);
    
    % Load the data
    load(fullfile(datadir, subs{s}));
    
    % Make a topoplot of the components
    pop_topoplot(icaEEG,0,[1:NUM_ICS],[subjid ' ICA']);
    
    % Save the plot
    print ('-dpng', fullfile(outdir, fname))
    close
    
end % end for subs
    
