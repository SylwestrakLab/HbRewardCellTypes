function K = bpod2mpc(SessionData)    

        Po1=[];
         K = zeros(SessionData.nTrials,20);
        for i=1:SessionData.nTrials
            K(i,1) = i;
            switch SessionData.TrialTypes(i)
                case 1; K(i,2) = 2;
                case 2; K(i,2) = 4;
                case 4; K(i,2) = 3;
            end
            lat = nan(4,1);
            for n=[1 2 4]
                field = ['Port' num2str(n) 'In'];
                if isfield(SessionData.RawEvents.Trial{i}.Events, field)
                    lat(n) = SessionData.RawEvents.Trial{i}.Events.(['Port' num2str(n) 'In'])(1);
                end
            end
            [~,idx] = min(lat);
            switch idx
                case 1; loc = 2;
                case 2; loc = 4;
                case 4; loc = 3;
            end
            
            K(i,3) = loc;
            if isfield(SessionData.RawEvents.Trial{i}.States,'NoReward')
                rewardTime = min([SessionData.RawEvents.Trial{i}.States.Reward(1),...
                SessionData.RawEvents.Trial{i}.States.NoReward(1)]);
            else
                rewardTime = SessionData.RawEvents.Trial{i}.States.Reward(1);
            end
            K(i,4)= rewardTime-SessionData.RawEvents.Trial{i}.States.WaitForResponse(1);
            K(i,6)= SessionData.RawEvents.Trial{i}.States.Drinking(1)-...
                rewardTime;
            K(i,7) = ~any(lat);
            if ~isnan(SessionData.RawEvents.Trial{i}.States.Punish(1))
                if isnan(SessionData.RawEvents.Trial{i}.States.WaitForResponse)
                K(i,14) = lat(idx);
                K(i,7)=0;
                else
                K(i,5) = lat(idx);
                K(i,7)=0;
                end
            end
            K(i,13) = SessionData.RewardDur(i);
            K(i,18) = SessionData.RawEvents.Trial{i}.States.WaitForResponse(2)-...
                SessionData.RawEvents.Trial{i}.States.WaitForResponse(1);
            K(i,19) = SessionData.GUI.ResponseTime;
            K(i,20) = SessionData.GUI.ITI;
            if any(lat)
            %Po1 = [Po1 pokes];
            end
            %adjust for pokes during session start. 
            if isnan(K(i,4))
                K(i,4)=0;
            end
            if sum(K(i,[4,5,14]))==0
                K(i,7)=1;
            end
        end
end