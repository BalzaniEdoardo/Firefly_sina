% load('/Volumes/WD Edo/firefly_analysis/LFP_band/DATASET/PPC+PFC+MST/m53s133.mat')
close all


valid = find(behv_stats.trialtype.all.trlindx==1);
sele = randsample(valid,10,false);
% tr_ind = valid(122);
for tr_ind = sele
    r_stop = cell2mat(behv_stats.pos_rel.r_stop(tr_ind));
    theta_stop = cell2mat(behv_stats.pos_rel.theta_stop(tr_ind));
    t_start = trials_behv(tr_ind).events.t_targ;
    t_stop = trials_behv(tr_ind).events.t_stop - 0.0;
    
    theta_targ = cell2mat(behv_stats.pos_rel.theta_targ(tr_ind));

    x = r_stop .* cos(theta_stop/360*pi*2);
    y = r_stop .* sin(theta_stop/360*pi*2);
    
    v_x = trials_behv(tr_ind).events.w; % v sin(theta)/r
    v_y = trials_behv(tr_ind).events.v; % v cos(theta)
    v_ang = sqrt(v_x.^2 + v_y.^2).*sin(theta_stop)/r_stop;
    
    figure
%     plot(x,y)
% %     hold on 
    i_start = find(trials_behv(tr_ind).continuous.ts >= t_start,1)+1;
    i_stop = find(trials_behv(tr_ind).continuous.ts <= t_stop,1,'last');
%     plot([x(i_start),x(i_start)],[min(y),max(y)])
%     plot([x(i_stop),x(i_stop)],[min(y),max(y)])
    subplot(121)
    title('v ang')
    plot(v_ang(i_start:i_stop))
    subplot(122)
    title('r')
    plot(r_stop(i_start:i_stop))
    [r_stop(i_stop),theta_stop(i_stop)]
end

