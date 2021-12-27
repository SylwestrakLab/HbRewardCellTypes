function idx = findStrInCell(str,C)
%IndexC = strfind(C,str);
IndexC = strfind(lower(C),lower(str));
idx = find(not(cellfun('isempty',IndexC)));
end