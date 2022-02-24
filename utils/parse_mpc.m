function m = parse_mpc(filename);

%{
Parse a Med-Associates 'annotated' file into a struct.
    Variables used here are:
    line = line of data file
    sepi = seperating colon (:) in line
%}

%CHECK THAT FILE EXISTS
if exist(filename, 'file'),
    fid = fopen(filename);
else
    error(['file not found: ' filename]);
end

%READ IN FILE LINE BY LINE TO CELL ARRAY
ml = {};
while true
    line = fgetl(fid);
    
    if isempty(line) %go back if line is empty
        continue
    end
    
    if line(1) == -1 %break
        break
    end
    
    sepi = find(line == ':'); %define seperating colon
    if isempty(sepi)
        warning(['Non-empty line with no '':'' separator: ' l]);
        continue; 
    end
    
    key = line(1:sepi-1);
    val = line(sepi+1:end);
    
    ml = [ml; {key val}]; %add to ml
end 

%GET HEADERS (MORE THAN 1 CHARACTER,COME BEFORE VARIABLES)
nLines = size(ml,1);

m.header = struct();
k = 1;
while k <= nLines,
    key = ml{k,1};
    val = ml{k,2};
    
    if size(key,2) == 1, break; end
    
    %clean up spaces in key and var
    key(key == ' ') = '_';
    if ~isvarname(key)
        error(['Header key string constains non-space invalid chars: ' ...
            key]);
    end
    
    if val(1) == ' ',
        val(1) = [];
    end
    
    m.header.(key) = val;
    k = k+1;
end

%GET SCALAR VARIABLES
while k<=nLines
  key = ml{k,1};
  val = ml{k,2};
  if size(val,2) == 0, % found an array variable, bail
    break
  end
  m.(key) = str2double(val);
  k = k+1;
end

% GET ARRAY VARIABLES
while k<=nLines
  key = ml{k,1};
  val = ml{k,2};

  if size(val,2) == 0, % found an array label (line with no value)
    arrtmp = ''; % reset tmp var for array string data
    k = k+1;

    while k<=nLines % loop to get this array's data
      val = ml{k,2};

      if size(val,2) > 0, % found data
        arrtmp = [arrtmp ' ' val]; % append
        k = k+1;
      end
      
      if size(val,2) == 0 || k > nLines % end of data, write out
        [m.(key) noerr] = str2num(char(arrtmp));
        if ~noerr
          warning(['Str2num conversion failure: ' val]);        
        end
        break % out of while loop 
      end
      
    end
  else
    error(['Non-array data found after start of array section: ' val]);
  end
end

% reorder fields: header, then vars alphabetically
m = reorderstructure(orderfields(m), 'header');

end



    