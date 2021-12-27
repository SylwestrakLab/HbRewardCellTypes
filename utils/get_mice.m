function mArray = get_mice(cohortName)

switch cohortName
    case 'GFP'
        mArray = {'m833','m834','m836'};
    case 'Tac'
        %mArray = {'m217','m219','m220','m417','m418','m419','m420','m440','m441','m244','m245','m714','m802'}; 
        %mArray = {'m826','m827','m828'}; 
        %mArray = {'m826'}
        mArray = {'m217','m219','m220','m440','m441','m802','m826'}; 
        
        %mArray = {'m714','m802'}; 
    case 'TacPVT'
         mArray = {'m218','m244'}; 
    case 'TacLHb'
        mArray = {'m714','m802'}; 

    case 'Attn'
         mArray = {'m334','m341','m331','m345','m143','m146'}; 
         
    case 'Th'
        mArray = {'m600','m223','m247','m248','m407'};
        %mArray = {'m600','m223','m247','m248','m407','m384','m381','m406','m407','m598','m599','m602'};
    case 'Impulsivity'
        mArray = {'m334','m341','m331','m345'}; 

    case 'MHb'
        mArray = {'m203','m204'};
        
    case 'PV'
        mArray = {'m147'};
        
    case 'Learning'
         mArray = {'m143','m145','m146'};
         
    case 'Thalamus'
        mArray = {'m516'};
        
    case 'morphine'   
        mArray = {'m331','m345','m146','m334','m341','m143'}; 
        
    case 'control'   
        mArray = {'m336','m340'};  
    case 'chat'   
        mArray = {'m385','m322','m2840','m2841','m2843'};  %mice to analyze
        %mArray = {'m320'};
    case 'Calb'
       %mArray = {'m426','m427','m428','m429','m453','m454','m410'};  
        mArray = {'m726','m727','m730','m733','m734'};
    case 'calbPVT'
       %mArray = {'m426','m427','m428','m429','m453','m454','m410'};  
        %mArray = {'m726','m727','m730','m731','m733','m734'};
         mArray = {'m454','m410','m429'};
    case 'LHb'
      mArray = {'m203','m417','m418','m419','m420'};
    case 'Opto'
        
        mArray = {'m787','m788',...
    'm860','m863','m911',...
    'm965','m967','m955','m789','m960','m961',...
    'm861','m626','m977',...
   'm966','m956'};
        
%         mArray = {'m787','m789','m788','m960','m961',...
%     'm860','m861','m863','m626','m911','m977','m976','m975',...
%     'm965','m966','m967','m955','m956'};
     case 'eNPAC'
        mArray = {'m787','m788',...
    'm860','m863','m911',...
    'm965','m967','m955'};
     case 'YFP'
        mArray = {'m789','m960','m961',...
    'm861','m626','m977',...
   'm966','m956'};
    case 'BpodFP'
           mArray =   {'m969','m855','m959','m972'};
    case 'ThNew'
         mArray =   {'m4366','m4369'};FP
    case 'OptoHisto'
        mArray = {'m911','m967','m861','m960','m961'};
    case 'eNPAChisto'
        mArray = {'m911','m967'};
    case 'YFPhisto'
        mArray = {'m861','m960','m961'};
    case 'AllJune2019'
         mArray = {'m139';'m401';'m406';'m142';'m143';'m144';'m135';...
            'm136';'m145';'m147';'m125';'m126';'m403';'m404';...
            'm988';'m989';'m990';'m409'};
    case 'presurgical'
         mArray = {'m331','m331','m333','m334','m335','m336','m337','m338','m339','m340','m341','m342','m343','m344','m345'};
    case 'Intersect'
        mArray = {'m1108','m1109','m1133','m1144'};
    case 'Nonspecific'
        mArray = {'m1108','m1109','m1110','m1120'};
    case 'Int-LHb'
        mArray = {'m1108','m1109','m1133','m1144'};   
       case 'All-Int-MHb'
        mArray = {'m1148','m1149','m1150','m1151','m1152','m1161','m1162'};
    case 'Int-MHb'
        mArray = {'m1148'};
    case 'Int-MHb2'
        mArray = {'m1312','m1313','m1314','m1315','m1316','m1317','m1318','m1319','m1320','m1321'};
    case 'LHb2'
        mArray = {'m1200','m1201','m1202'};
%     case 'Int-LHb2'
%         mArray = {'m1108','m1109','m1313','m1133','m1144','m1323'};
%         mArray = {'m1108','m1109','m1313','m1323','m1144'};
    case 'Int-MHb3'
        mArray = {'m1334','m1335','m1336','m1337','m1338','m1339'};
    case 'targetTacLHb'
        mArray = {'m1109','m1444','m1313'};
    case 'Th-RTPP'
        mArray = {'m1378','m1379','m1380','m1381'};
    case 'TacLHb-RTPP'
        mArray = {'m1387','m1388','m1389','m1390', 'm1391','m1392','m1393'}
    case 'Str'
        mArray = {'m1418','m1419','m1420'}
    case 'Int-LHb2'
        mArray = {'m1108','m1109','m1133','m1144','m1425','m1426','m1427'};  
    case 'targetTacLHb2'
        mArray = {'m1425','m1426','m1427','m1428'};
    case 'Int-MHb4-ChR2'
        mArray = {'m1470','m1473'};
    case 'Int-MHb4-NpHR'
        mArray = {'m1477','m1478','m1479','m1506','m1507','m1508'};
    case 'LHA'
        mArray = {'m1464','m1465','m1466','m1467'}
    case 'Int-Mistargeted'
        mArray = {'m1468','m1469','m1471','m1472'};
end