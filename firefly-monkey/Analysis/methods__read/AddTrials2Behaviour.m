function trials = AddTrials2Behaviour(prs)

trials = []; % initialise
cd(prs.filepath_behv)
%% list all files to read
flist_log=dir('*.log'); 

for i=1:length(flist_log)
    % get idx letter
    idx_letters = regexp(flist_log(i).name,'[a-zA-Z]');
    % first should be m and the last 3 should be log
    idx_letters = idx_letters(2:end-3);
    delim = flist_log(i).name(idx_letters);
    splt = split(flist_log(i).name,delim);
    splt = splt{2};
    splt = split(splt,'.');
    splt = splt{1};
    fnum_log(i) = str2num(splt); 
end
flist_smr=dir('*.smr');
for i=1:length(flist_smr)
    % get idx letter
    idx_letters = regexp(flist_smr(i).name,'[a-zA-Z]');
    % first should be m and the last 3 should be smr
    idx_letters = idx_letters(2:end-3);
    delim = flist_log(i).name(idx_letters);
    splt = split(flist_smr(i).name,delim);
    splt = splt{2};
    splt = split(splt,'.');
    splt = splt{1};
    fnum_smr(i) = str2num(splt);
end
% flist_mat=dir('*.mat');
% for i=1:length(flist_mat), fnum_mat(i) = str2num(flist_mat(i).name(end-6:end-4)); end
nfiles = length(flist_log);

%% read files
cnt_tr = 0;
for i=1:nfiles
    fprintf(['... reading ' flist_log(i).name '\n']);
    % read .log file
    trials_log = AddLOGData(flist_log(i).name);
    % read all .smr files associated with this log file
    if i<nfiles, indx_smr = find(fnum_smr >= fnum_log(i) & fnum_smr < fnum_log(i+1));
    else indx_smr = find(fnum_smr >= fnum_log(i)); end
    trials_smr = [];
    for j = indx_smr
        data_smr = ImportSMR(flist_smr(j).name);
        trials_smr = [trials_smr AddSMRData(data_smr,prs)];
    end
    % merge contents of .log and .smr files
    ntrls_log = length(trials_log); ntrls_smr = length(trials_smr);
    cnt_tr = cnt_tr + ntrls_log;

    if ntrls_smr <= ntrls_log
%         for j=1:length(trials_smr), trials_temp(j) = catstruct(trials_smr(j),trials_log(j)) ; end
        for j=1:length(trials_smr), trials_temp(j) = concat_smr_log(trials_smr(j),trials_log(j)) ; end
    else  % apply a very dirty fix if spike2 was not "stopped" on time (can happen when replaying stimulus movie)
%         for j=1:ntrls_log, trials_temp(j) = catstruct(trials_smr(j),trials_log(j)) ; end
        for j=1:ntrls_log, trials_temp(j) = concat_smr_log(trials_smr(j),trials_log(j)) ; end
        dummy_trials_log = trials_log(1:ntrls_smr-ntrls_log);
%         for j=1:(ntrls_smr-ntrls_log); trials_temp(ntrls_log+j) = catstruct(trials_smr(ntrls_log+j),dummy_trials_log(j)); end
        for j=1:(ntrls_smr-ntrls_log); trials_temp(ntrls_log+j) = concat_smr_log(trials_smr(ntrls_log+j),dummy_trials_log(j)); end

    end
    % add contents of .mat file
%     trials_temp = AddMATData(flist_mat(i).name,trials_temp);
    trials = [trials trials_temp];
    clear trials_temp;
    fprintf(['... total trials = ' num2str(length(trials)) '\n']);
end