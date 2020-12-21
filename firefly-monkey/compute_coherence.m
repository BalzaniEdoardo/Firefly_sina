%% list all file in a folder
%listing = dir('/Volumes/WD Edo/firefly_analysis/DATASET/PPC+PFC+MST/');
listing = dir('D:\Savin-Angelaki\saved\');
expression = '^m[0-9]+s[0-9]+.mat$';
for i = 1:length(listing)
    % check that file names matches with the regexp
    if isempty(regexp(listing(i).name,expression))
        continue
    end
    % load, set flags and analyze
    load(fullfile(listing(i).folder,listing(i).name))
    prs.fitGAM_coupled = 0;
    prs.compute_canoncorr = 0;
    prs.regress_popreadout = 0;
	prs.simulate_population = 0;
	prs.compute_coherencyLFP = 1;
	prs.corr_neuronbehverr = 0;
    stats_lfp = AnalysePopulation(lfps,trials_behv,behv_stats,lfps,prs);
    %save
    save(strcat('LFP_coherence_',listing(i).name),'stats_lfp')
end