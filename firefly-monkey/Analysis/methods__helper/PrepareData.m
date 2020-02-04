
%% How-to?
% in default_prs, only enable fitGAM_coupled
% pause execution of experiments.AddSessions(...,{'behv','lfps','units','pop'}) at line 120 of
% AnalysePopulation.m and then run this script until line 19 (spike raster)
% then set unitcount appropriately: best case scenario is unitcount = nunits
% then continue execution to save dataset

%% visualise spike raster
% figure; imagesc(data_concat.Yt',[0 1]);

%% remove rows that have zero spikes -- bad bad spike sorting!!!
% unitcount = [1:40 50:56];
% data_concat.Yt = Yt(:,unitcount);
% data_concat.lfp_phase = lfp_phase(:,unitcount);
% units = units(unitcount);

%% convert to struct

for k=1:numel(this.sessions.units), units(k) = struct(this.sessions.units(k)); end
for k=1:numel(this.sessions.lfps), lfps(k) = struct(this.sessions.lfps(k)); end
trials_behv= this.sessions.behaviours.trials;
behv_stats = this.sessions.behaviours.stats;

exportname = ['m',num2str(monk_id),'s',num2str(sess_id),'.mat'];

%% Export after analysis

% for k=1:numel(experiments.sessions.units), units(k) = struct(experiments.sessions.units(k)); end
% for k=1:numel(experiments.sessions.lfps), lfps(k) = struct(experiments.sessions.lfps(k)); end
% trials_behv= experiments.sessions.behaviours.trials;
% behv_stats = experiments.sessions.behaviours.stats;
% prs= default_prs(experiments.sessions.monk_id,experiments.sessions.sess_id);
% 
% exportname = ['m',num2str(experiments.sessions.monk_id),'s',num2str(experiments.sessions.sess_id),'.mat'];

%% put concatenated data in a struct
if prs.addconcat
    data_concat.Yt = Yt;
    data_concat.Xt = xt;
    data_concat.Xt(:,7) = NaN; data_concat.Xt(:,12) = NaN;
    lfp_phase = [];
    for k=1:nunits
        lfp_phase(:,k) = ConcatenateTrials(var_phase{k},[],{trials_spks_temp.tspk},{continuous_temp.ts},timewindow_full);
    end
    data_concat.lfp_phase = lfp_phase;
    
    cd(prs.filepath_neur);
    disp(['Saving exported data: ', exportname]);
    save(exportname,'behv_stats','data_concat','lfps','prs','trials_behv','units');
%     save([prs.sess_date,'.mat'],'behv_stats','data_concat','lfps','prs','trials_behv','units');
else
    cd(prs.filepath_neur);
    if prs.compute_spectrum
        lfp_beta = struct();
        lfp_theta = struct();
        lfp_alpha = struct();
        lfps_new = struct();
        for ch = 1: length(lfps)
            lfp_beta(ch).trials = struct();
            lfp_theta(ch).trials = struct();
            lfp_alpha(ch).trials = struct();
            lfps_new(ch).trials = struct('lfp',[]);
            lfps_new(ch).channel_id = lfps(ch).channel_id;
            lfps_new(ch).electrode_id = lfps(ch).electrode_id;
            lfps_new(ch).brain_area = lfps(ch).brain_area;
            for tr = 1:length(lfps(ch).trials)
                lfp_beta(ch).trials(tr).lfp_beta = lfps(ch).trials(tr).lfp_beta;
                lfp_theta(ch).trials(tr).lfp_beta = lfps(ch).trials(tr).lfp_theta;
                lfp_alpha(ch).trials(tr).lfp_alpha = lfps(ch).trials(tr).lfp_alpha;
                lfps_new(ch).trials(tr) = rmfield(lfps(ch).trials(tr),{'lfp_beta','lfp_alpha','lfp_theta'});

            end
        end
        
        lfps = lfp_new;
        disp(['Saving exported data: ', exportname]);
        save(exportname,'behv_stats','lfps','prs','trials_behv','units');
        exportname2 = ['lfp_beta_','m',num2str(monk_id),'s',num2str(sess_id),'.mat'];
        save(exportname2,'lfps_beta');
        exportname2 = ['lfp_alpha_','m',num2str(monk_id),'s',num2str(sess_id),'.mat'];
        save(exportname2,'lfps_alpha');
        exportname2 = ['lfp_theta_','m',num2str(monk_id),'s',num2str(sess_id),'.mat'];
        save(exportname2,'lfps_theta');
   else
        disp(['Saving exported data: ', exportname]);
        save(exportname,'behv_stats','lfps','prs','trials_behv','units');
    end
end
