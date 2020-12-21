%% Script for extracting the data pre-GAM fit
% 
clc; 
cd 'C:\Users\lab\Documents\Savin-Angelaki\Firefly_sina'

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

%% load and save the monkey info
monkeyInfoFile_joysticktask;
%save('monkey_info.mat','monkeyInfo')

%% extract a file

monk_id = 71;
sess_list = 1;

%monk_id = 53;
%sess_list = 108;

not_done = [];
except_struct = struct();
for session_id = sess_list
        experiments = experiment('firefly-monkey');
        prs = default_prs(monk_id,session_id);
        try
            experiments.AddSessions(monk_id,session_id,{'behv','units','lfps'});
        catch ME
            str_id = sprintf('m%ds%d',monk_id,session_id);
            except_struct.(str_id) = ME;
            not_done = [not_done,session_id];
            save([this_path,separ,'not_done.mat'],'not_done','except_struct')
        end
        disp('...clearing exp after session extraction')
        clear experiments
end
