function mArray = get_mice(cohortName)

switch cohortName
    case 'Tac'
        mArray = {'m217','m219','m220','m440','m441','m802','m826'};     
    case 'Th'
        mArray = {'m600','m223','m247','m248','m407'};
    case 'chat'   
        mArray = {'m385','m322','m2840','m2841','m2843'};  %mice to analyze
    case 'Calb'
        mArray = {'m726','m727','m730','m733','m734'};
    case 'presurgical'
         mArray = {'m331','m331','m333','m334','m335','m336','m337','m338','m339','m340','m341','m342','m343','m344','m345'};
    case 'Int-LHb2'
        mArray = {'m1108','m1109','m1133','m1144','m1425','m1426','m1427'};  
    case 'Int-MHb4-ChR2'
        mArray = {'m1470','m1473'};
    case 'Int-MHb4-NpHR'
        mArray = {'m1477','m1478','m1479','m1506','m1507','m1508'};
    case 'LHbCombo'
        mArray = {'m203','m417','m418','m419','m420','m1200','m1201','m1202'};
    case 'FP_Stanford'
        mArray = {'m217','m219','m220','m440','m441','m802','m826',...
            'm600','m223','m247','m248','m407',...
            'm726','m727','m730','m733','m734',...
            'm203','m417','m418','m419','m420',...
            'm385','m322','m2840','m2841','m2843'};
    case 'FP_Oregon'
        mArray = { 'm1200','m1201','m1202','m1108','m1109','m1133','m1144','m1425','m1426','m1427'};
end