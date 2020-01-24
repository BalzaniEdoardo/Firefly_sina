%% Script for extracting the data pre-GAM fit
% Save the for the repo
this_path = pwd;
path_split = split(this_path,filesep);
base_fold = join(path_split(1:end-1),filesep);
if ~contains(path,base_fold{1})
    addpath(fullfile(base_fold{1},'genpath2'))
    addpath(genpath2(base_fold{1},{'.git','genpath2'}))
    
end



%% extract a file
experiments = experiment('firefly-monkey');
monk_id = 53;
session_id = 107;
experiments.AddSessions(monk_id,session_id,{'behv','units','lfps'});
