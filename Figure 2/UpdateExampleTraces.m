%% Update example traces for Figure 1
%Example animals and session used in Figure 1.  This runs the
%grab_session_example script that makes a heatplot of all cued trials,
%sorted by trial number.  

cd '~/Dropbox/MHb Figure Drafts/Data/'

close all

%% Figure 2
grab_session_example('Th','m407','6',1);
grab_session_example('Tac','m219','6',1);
grab_session_example('chat','m385','6',2);
grab_session_example('calb','m726','6',1);
grab_session_example('LHbCombo2','m417','6',1);

%% Figure 3
grab_session_example('Int-LHb2','m1109','7',1);
