%% Script for extracting the data pre-GAM fit
% Save the for the repo
if contains(computer,'MAC')
    separ = '/';
else
    separ = '\';
end
this_path = pwd;
path_split = split(this_path,separ);
base_fold = join(path_split(1:end-1),separ);
if ~contains(path,base_fold{1})
    addpath(fullfile(base_fold{1},'genpath2'))
    addpath(genpath2(base_fold{1},{'.git','genpath2'}))
    
end

w = warning ('off','all');

%% extract a file

monk_id = 53;
sess_list = [  108, 109,...
    110, 111, 113, 114, 115, 128, 132, 133, 134, 136, 120, 123, 124,... 
       92, 93, 116, 30, 31, 32, 33, 34, 90,99,122,126,127,130];
not_done = [];

for session_id = sess_list
        experiments = experiment('firefly-monkey');
        prs = default_prs(monk_id,session_id);
        try
            experiments.AddSessions(monk_id,session_id,{'behv','units','lfps'});
        catch
            disp
            not_done = [not_done,session_id];
            save([this_path,separ,'not_done.mat'],'not_done')
        end
        disp('...clearing exp after session extraction')
        clear experiments
end
