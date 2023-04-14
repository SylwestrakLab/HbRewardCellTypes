# HbRewardCellTypes

This code is associated with the following publication

Sylwestrak EL, Jo Y, Vesuna S, Wang X, Holcomb B, Tien RH, Kim DK, Fenno L, Ramakrishnan C, Allen WE, Chen R, Shenoy KV, Sussillo D, Deisseroth K. Cell-type-specific population dynamics of diverse reward computations. Cell. 2022 Sep 15;185(19):3568-3587.e27. doi: 10.1016/j.cell.2022.08.019. PMID: 36113428. 

This code can be used to re-generate the Fiber Photometry Data for Figures 2-4.  Code related to each of the figures is in the associated folder and a set of functions required across scripts is locted in the utils folder.

# Getting Started

1. Download data using DANDI
2. Run Figure scripts. Select the destination directory of the DANDI download when prompted. 


# Description of data
The scripts will output panels as they were generated for the figures.  The data is organized into a T struct for each genetype cohort and behavioral protocol type, with row entries representing individual behavioral sessions.  
The fields are as follows: 

ntrials: number of trials in the behavioral session

outcome: trial outcome where 1=correct; 2-incorrect; 3=omission; 4=premature

ITI: intertrial interval

CueDur: cue light duration

rewardDur: code associated with the reward trial type.  Only relevant for RewLight sessions (Figure 3).  0 = Light + No reward; 1 = Light + reward; 2 = No Light + No Reward ; 3 = No Light + Reward

subject = animal id

rewLat = time from nosepoke to reward port entry

respLat = time from cue onset to nosepoke

header = session info

filterHz = filtering info

baselineF = average voltage after demodulation across the session

bls = regression parameters

stage = id for session type across training and testing

trialNum = vector of trial numbers

rewardProb = session reward probability

d = output from Synapse fiber photometry software

# Behavioral syncs

The remaining fields are associated with behavioral syncs.  Those with 'df' are the dF/F values Those without 'df' are z scored values.  Each matrix row is a trial, 7 seconds before and after the behavioral sync.



