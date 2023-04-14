function T = computeZscore(T)
nSessions = size(T,2);
for i=1:nSessions
    %Use stored mu and sigma from the entire session to compute zscores
    mu = T(i).mu;
    sigma = T(i).sigma;
    syncname = {'Start_df'; 'Cue_df'; 'Poke_df'; 'Reward_df';'HeadIn_df'};
    
    %Make new fields with zscores
    for s = 1:numel(syncname)
        dfName = split(syncname{s},'_');
        dfName = dfName{1};
        dF = T(i).(syncname{s});
        T(i).(dfName) = (dF - mu)/sigma;
    end
end

end
