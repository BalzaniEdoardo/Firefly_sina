function trials = AddLOGData(file,prs)

% the logic of this function is complicated because of several changes
% that were made to the format of the log files since the experiment's
% inception -- (i) log file without randomizing intertrial/waiting time, 
% (ii) log file randomizing intertrial/waiting time, (iii) log file with
% floor lifetime enabled on a trial-by-trial basis, (iv) log files
% containing firely position present where several previous fields were
% no longer present at the beginning

count = 0;
fid = fopen(file, 'r');
eof=0; newline = 'nothingnew'; count=0;
%% check if this data was generated by replaying the stimulus movie
if strcmp(file(1:6),'replay'), replay_movie = true;
else, replay_movie = false; end
%% reward quantity, intertrial-interval, waiting time for reward, fixed ground landmark
% if limited lifetime is enabled (1), fixed_ground is 0
fixed_ground = []; intertrial_interval = nan; reward_duration = nan; stop_duration = nan;
while ~strcmp(newline(1:9),'Inter-tri') && ~strcmp(newline(1:6),'Reward')...
        && ~any(strcmp(newline(1:9),{'Enable Li','Floor Lif'}))
    newline = fgetl(fid);
end
if strcmp(newline(1:6),'Reward') % if the line contains reward duration
    reward_duration = str2double(newline(23:25));
elseif strcmp(newline(1:9),'Inter-tri') % if the line contains intertrial-interval
    intertrial_interval = str2double(newline(27));
    newline = fgetl(fid);
    reward_duration = str2double(newline(23:25));
    newline = fgetl(fid);
    stop_duration = str2double(newline(34:end))/1000;
elseif strcmp(newline(1:9),'Enable Li')
    fixed_ground = logical(1 - str2double(newline(18))); 
end
%% read speed limit for this experimental block
while ~strcmp(newline(1:13),'Joy Stick Max')
    newline = fgetl(fid);
end
v_max = str2double(newline(32:34));
newline = fgetl(fid); w_max = str2double(newline(41:44));
isavailable_fireflystatus = true;
while newline ~= -1
    %% get ground plane density
    while ~strcmp(newline(1:9),'Floor Den')
        newline = fgetl(fid);
        if newline == -1, break; end
    end
    if newline == -1, break; end
    count = count+1;
    
    trials(count).prs.floordensity = str2double(newline(27:34));
    %% initialise
    trials(count).logical.landmark_distance = false;
    trials(count).logical.landmark_angle = false; % #$%^&&^&*^danger - change false to nan immediately (what if field missing from log file??)
    trials(count).prs.ptb_linear = 0;
    trials(count).prs.ptb_angular = 0;
    trials(count).prs.ptb_delay = 0;
    trials(count).prs.intertrial_interval = intertrial_interval;
    trials(count).logical.firefly_fullON = nan;
    trials(count).prs.stop_duration = stop_duration;
    trials(count).logical.replay = replay_movie;
    trials(count).logical.landmark_fixedground = false;% #$%^&&^&*^danger - change false to nan immediately (what if field missing from log file??)
    
    trials(count).prs.v_max = v_max; % cm/s (default 200) 
    trials(count).prs.w_max = w_max; % deg/s (default 90)
    trials(count).prs.reward_duration = reward_duration; % ms (default 150)
    %% get landmark status, ptb velocities and ptb delay
    newline = fgetl(fid);
    if newline == -1, break; end
    if strcmp(newline(1:9),'Enable Di')
        trials(count).logical.landmark_distance = str2double(newline(26)); % 1=distance landmark was ON
        newline = fgetl(fid);
        trials(count).logical.landmark_angle = str2double(newline(25)); % 1=angular landmark was ON
        newline = fgetl(fid);
        trials(count).prs.ptb_linear = str2double(newline(35:end)); % amplitude of linear velocity ptb (cm/s)
        newline = fgetl(fid);
        trials(count).prs.ptb_angular = str2double(newline(37:end)); % amplitude of angular velocity ptb (deg/s)
        newline = fgetl(fid);
        trials(count).prs.ptb_delay = str2double(newline(31:end)); % time after trial onset at which to begin ptb
        newline = fgetl(fid);
    end
    %% get inter-trial interval and firefly status
    if newline == -1, break; end
    if strcmp(newline(1:9),'Inter-tri')
        trials(count).prs.intertrial_interval = str2double(newline(27:end)); % time between end of this trial and beg of next trial (s)
        newline = fgetl(fid);
    elseif exist('intertrial_interval','var')
        trials(count).prs.intertrial_interval = intertrial_interval;
    end    
    if strcmp(newline(1:10),'Firefly Fu')
        trials(count).logical.firefly_fullON = str2double(newline(18)); % 1=firefly was ON throughout the trial
        newline = fgetl(fid);
    end
    %% get stopping duration for reward
    if newline == -1, break; end
    if strcmp(newline(1:8),'Distance')
        trials(count).prs.stop_duration = str2double(newline(34:end))/1000; % wait duration after stopping before monkey is given feedback (s)
    elseif exist('stop_duration','var')
        trials(count).prs.stop_duration = stop_duration;
    end
    %% check for fixed ground

    if newline == -1, break; end
    if ~strcmp(newline(1:9),'Trial Num')        
        if isempty(fixed_ground)
            while ~strcmp(newline(1:9),'Enable Li') && ~contains(newline,'Trial Num')
                newline = fgetl(fid);
                if newline == -1, break; end
            end
            if newline ~= -1
                if ~contains(newline,'Trial Num')
                    trials(count).logical.landmark_fixedground = logical(1 - str2double(newline(18)));
                else
                    trials(count).logical.landmark_fixedground = false;
                end
            else
                trials(count).logical.landmark_fixedground = false;
            end
        end
        
    else
        trials(count).logical.landmark_fixedground = false;
    end
    if newline == -1, break; end
    %% firefly position if available
    if ~contains(newline,'Trial Num')
        newline = fgetl(fid);
    end
    if all(newline ~= -1) && strcmp(newline(1:7),'Firefly') &&  (str2double(newline(9))==0 || str2double(newline(9))==1)
        FFparams = split(newline,' ');
        trials(count).prs.xfp = -str2double(FFparams{prs.FFparams_xpos}); 
        trials(count).prs.yfp = -str2double(FFparams{prs.FFparams_ypos});
        trials(count).prs.reward_duration = str2double(FFparams{prs.FFparams_rewardDur});
        trials(count).prs.fly_duration = str2double(FFparams{prs.FFparams_flyDuration});
        if ~isnan(trials(count).prs.fly_duration)
            if trials(count).prs.fly_duration > 0.4
                trials(count).logical.firefly_fullON = 1;
            else
                trials(count).logical.firefly_fullON = 0;
            end
        end
        % status not avilable in new log file (assuming always OFF)
        if isnan(trials(count).logical.firefly_fullON)
            trials(count).logical.firefly_fullON = false;
        end
    end
    if newline ~= -1
        while ~(contains(newline,'Joy Stick Gain:') || contains(newline,'Trial Num')  || all(newline == -1))
            newline = fgetl(fid);
            if all(newline == -1)
                break
            end
        end
    end
    if newline == -1, break; end
%     if contains(newline,'Trial Num')
%         splt = split(newline,'Trial Num# ');
%         if str2num(splt{2}) == 750
%             splt
%         end
%     end
    if length(newline) >= 15 && strcmp(newline(1:15),'Joy Stick Gain:')
            trials(count).logical.joystick_gain = str2num(newline(16:end));
            newline = fgetl(fid);
    end
end

%% firefly status from mat file if not available in log file
if isnan(trials(1).logical.firefly_fullON)
    flist = dir('*.log');
    indx = find(strcmp({flist.name},file));
    flist = dir('*.mat');    
    if ~isempty(flist)
        matfiledata = load(flist(indx).name,'ntrls','trials_flyON');
        matfiledata.trials_flyON = circshift(matfiledata.trials_flyON,-(matfiledata.ntrls - count + 1));
        firefly_fullON = logical(matfiledata.trials_flyON(1:count));
%         if matfiledata.ntrls == count, matfiledata.trials_flyON = [0 matfiledata.trials_flyON]; end
%         firefly_fullON = logical(matfiledata.trials_flyON(matfiledata.ntrls - count:matfiledata.ntrls - 1));
    end    
    for i=1:count
        trials(i).logical.firefly_fullON = firefly_fullON(i);
    end
end

%% close file
fclose(fid);