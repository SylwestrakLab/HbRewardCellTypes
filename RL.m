%% Logistic regression with L1-penalty for fitting history to choices
% LeftChoice: 1:left, 0:right
% PastRewC: RewC history between -1 and -10 trials
% PastUnrC: UnrC history between -1 and -10 trials
% PastC: C history between -1 and -10 trials
%
% written by Ryoma Hattori, 2021

%load('BehavLogisticRegression.mat','LeftChoice','PastRewC','PastUnrC','PastC')
%% TO RUN IT THE WAY HE DOES
figure

load('~/Documents/GitHub/HbRewardCellTypes/data/RL.mat')


%%

R = [];
U = [];
C = [];  
LC = [];
for sessNum=1:20
%sessNum = 2
nPrevTrials = 10; %make this iterate l ater
PastRewC =[];  %spout of previously rewarded choice
PastUnrC =[];  %spout of previously unrewarded choice
PastC =[];     %previous  choice
LeftChoice =[];   %current choice

%Left Choice like Hattorri
t = nPrevTrials+1; %start trial left choice
LeftChoice = double(RL(sessNum).lick(t:end)==-1);


%Previous Choice 
for ii = 1:nPrevTrials
    t1 = nPrevTrials+1-ii; %start trial
    t2 = length(LeftChoice)+t1-1;
    PastC(:,ii) =  RL(sessNum).lick(t1:t2)==-1;
end

%Flip for easier plotting later
PastC = fliplr(PastC);

%PastRewC 
for ii = 1:nPrevTrials;
    t1 = nPrevTrials+1-ii; %start trial
    t2 = length(LeftChoice)+t1-1;
    PastRewC(:,ii) = RL(sessNum).rewarded(t1:t2)==1;
end
PastRewC = fliplr(PastRewC);

%Past Unrewarded Choice 
for ii = 1:nPrevTrials
    t1 = nPrevTrials+1-ii; %start trial
    t2 = length(LeftChoice)+t1-1;
    PastUnrC(:,ii) = RL(sessNum).rewarded(t1:t2)==0;
end
PastUnrC = fliplr(PastUnrC)

clearvars ii t t1 t2

R = [R; PastRewC];
U = [U; PastUnrC];
C = [C; PastC];  
LC = [LC; LeftChoice];

end
%% Lasso-regularized regression fit (Same as the one used in Hattori et al., 2019)
%[B, FitInfo] = lassoglm([PastRewC,PastUnrC,PastC],LeftChoice,'binomial','CV',5,'Alpha',1);
[B, FitInfo] = lassoglm([R,U,C],LC,'binomial','CV',5,'Alpha',1);

beta0_rR_lasso_1SE = FitInfo.Intercept(FitInfo.Index1SE);
beta4R_rR_lasso_1SE = B(1:10,FitInfo.Index1SE);
beta4uR_rR_lasso_1SE = B(10+1:10+1+10-1,FitInfo.Index1SE);
beta4C_rR_lasso_1SE = B(10+1+10:end,FitInfo.Index1SE);

plot(-10:-1,beta4R_rR_lasso_1SE,'-ro');hold on
plot(-10:-1,beta4uR_rR_lasso_1SE,'-bo'),hold on
plot(-10:-1,beta4C_rR_lasso_1SE,'-ko'),hold on
plot(-10:-1,repmat(beta0_rR_lasso_1SE,[1,10]),'Color',[0 0.5 0]),hold on
plot(-10:-1,zeros(1,10),':k'),hold on
xlabel('Past trials'),ylabel('History weight'),legend('Rewarded','Unrewarded','Choice','Left bias','Location','northwest')
ylim([-2 3])



