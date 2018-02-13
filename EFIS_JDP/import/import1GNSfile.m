function [catalog] = import1GNSfile(filename, startRow, endRow)
%IMPORTFILE Import numeric data from a text file as column vectors.
%   [PUBLICID,EVENTTYPE,ORIGINTIME,MODIFICATIONTIME,LONGITUDE,LATITUDE,MAGNITUDE,DEPTH,MAGNITUDETYPE,DEPTHTYPE,EVALUATIONMETHOD,EVALUATIONSTATUS,EVALUATIONMODE,EARTHMODEL,USEDPHASECOUNT,USEDSTATIONCOUNT,MAGNITUDESTATIONCOUNT,MINIMUMDISTANCE,AZIMUTHALGAP,ORIGINERROR,MAGNITUDEUNCERTAINTY]
%   = IMPORTFILE(FILENAME) Reads data from text file FILENAME for the
%   default selection.
%
%   [PUBLICID,EVENTTYPE,ORIGINTIME,MODIFICATIONTIME,LONGITUDE,LATITUDE,MAGNITUDE,DEPTH,MAGNITUDETYPE,DEPTHTYPE,EVALUATIONMETHOD,EVALUATIONSTATUS,EVALUATIONMODE,EARTHMODEL,USEDPHASECOUNT,USEDSTATIONCOUNT,MAGNITUDESTATIONCOUNT,MINIMUMDISTANCE,AZIMUTHALGAP,ORIGINERROR,MAGNITUDEUNCERTAINTY]
%   = IMPORTFILE(FILENAME, STARTROW, ENDROW) Reads data from rows STARTROW
%   through ENDROW of text file FILENAME.
%
% Example:
%   [publicid,eventtype,origintime,modificationtime,longitude,latitude,magnitude,depth,magnitudetype,depthtype,evaluationmethod,evaluationstatus,evaluationmode,earthmodel,usedphasecount,usedstationcount,magnitudestationcount,minimumdistance,azimuthalgap,originerror,magnitudeuncertainty] = importfile('GNS_Ruapehu.csv',2, 47967);
%
%    See also TEXTSCAN.

% Auto-generated by MATLAB on 2018/02/01 16:50:54

%% Initialize variables.
delimiter = ',';
if nargin<=2
    startRow = 2;
    endRow = inf;
end

%% Read columns of data as strings:
% For more information, see the TEXTSCAN documentation.
formatSpec = '%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%[^\n\r]';

%% Open the text file.
fileID = fopen(filename,'r');

%% Read columns of data according to format string.
% This call is based on the structure of the file used to generate this
% code. If an error occurs for a different file, try regenerating the code
% from the Import Tool.
dataArray = textscan(fileID, formatSpec, endRow(1)-startRow(1)+1, 'Delimiter', delimiter, 'HeaderLines', startRow(1)-1, 'ReturnOnError', false);
for block=2:length(startRow)
    frewind(fileID);
    dataArrayBlock = textscan(fileID, formatSpec, endRow(block)-startRow(block)+1, 'Delimiter', delimiter, 'HeaderLines', startRow(block)-1, 'ReturnOnError', false);
    for col=1:length(dataArray)
        dataArray{col} = [dataArray{col};dataArrayBlock{col}];
    end
end

%% Close the text file.
fclose(fileID);

%% Convert the contents of columns containing numeric strings to numbers.
% Replace non-numeric strings with NaN.
raw = repmat({''},length(dataArray{1}),length(dataArray)-1);
for col=1:length(dataArray)-1
    raw(1:length(dataArray{col}),col) = dataArray{col};
end
numericData = NaN(size(dataArray{1},1),size(dataArray,2));

for col=[5,6,7,8,14,15,16,17,18,19,20,21]
    % Converts strings in the input cell array to numbers. Replaced non-numeric
    % strings with NaN.
    rawData = dataArray{col};
    for row=1:size(rawData, 1);
        % Create a regular expression to detect and remove non-numeric prefixes and
        % suffixes.
        regexstr = '(?<prefix>.*?)(?<numbers>([-]*(\d+[\,]*)+[\.]{0,1}\d*[eEdD]{0,1}[-+]*\d*[i]{0,1})|([-]*(\d+[\,]*)*[\.]{1,1}\d+[eEdD]{0,1}[-+]*\d*[i]{0,1}))(?<suffix>.*)';
        try
            result = regexp(rawData{row}, regexstr, 'names');
            numbers = result.numbers;
            
            % Detected commas in non-thousand locations.
            invalidThousandsSeparator = false;
            if any(numbers==',');
                thousandsRegExp = '^\d+?(\,\d{3})*\.{0,1}\d*$';
                if isempty(regexp(numbers, thousandsRegExp, 'once'));
                    numbers = NaN;
                    invalidThousandsSeparator = true;
                end
            end
            % Convert numeric strings to numbers.
            if ~invalidThousandsSeparator;
                numbers = textscan(strrep(numbers, ',', ''), '%f');
                numericData(row, col) = numbers{1};
                raw{row, col} = numbers{1};
            end
        catch me
        end
    end
end


%% Split data into numeric and cell columns.
rawNumericColumns = raw(:, [5,6,7,8,14,15,16,17,18,19,20,21]);
rawCellColumns = raw(:, [1,2,3,4,9,10,11,12,13]);


%% Replace non-numeric cells with NaN
R = cellfun(@(x) ~isnumeric(x) && ~islogical(x),rawNumericColumns); % Find non-numeric cells
rawNumericColumns(R) = {NaN}; % Replace non-numeric cells

%% Allocate imported array to column variable names
publicid = rawCellColumns(:, 1);
eventtype = rawCellColumns(:, 2);
origintime = rawCellColumns(:, 3);
modificationtime = rawCellColumns(:, 4);
longitude = cell2mat(rawNumericColumns(:, 1));
latitude = cell2mat(rawNumericColumns(:, 2));
magnitude = cell2mat(rawNumericColumns(:, 3));
depth = cell2mat(rawNumericColumns(:, 4));
magnitudetype = rawCellColumns(:, 5);
depthtype = rawCellColumns(:, 6);
evaluationmethod = rawCellColumns(:, 7);
evaluationstatus = rawCellColumns(:, 8);
evaluationmode = rawCellColumns(:, 9);
earthmodel = cell2mat(rawNumericColumns(:, 5));
usedphasecount = cell2mat(rawNumericColumns(:, 6));
usedstationcount = cell2mat(rawNumericColumns(:, 7));
magnitudestationcount = cell2mat(rawNumericColumns(:, 8));
minimumdistance = cell2mat(rawNumericColumns(:, 9));
azimuthalgap = cell2mat(rawNumericColumns(:, 10));
originerror = cell2mat(rawNumericColumns(:, 11));
magnitudeuncertainty = cell2mat(rawNumericColumns(:, 12));
%% JP
parfor i=1:numel(publicid)
    catalog(i).EVENTID = publicid(i);
    catalog(i).eventtype = eventtype(i);
    %    catalog(i).origintime = origintime(i);
    catalog(i).DateTime = datestr(datenum(origintime(i),'yyyy-mm-ddTHH:MM:SS.FFFZ'),'yyyy/mm/dd HH:MM:SS.FFF');
    catalog(i).modificationtime = modificationtime(i);
    catalog(i).Longitude = longitude(i);
    catalog(i).Latitude = latitude(i);
    
    if magnitude(i) == -9
        magnitude(i) = nan;
    end
    catalog(i).Magnitude = magnitude(i);
    
    if depth(i) <=-9
        depth(i) = nan;
    end
    catalog(i).Depth = depth(i);
    catalog(i).magnitudetype = magnitudetype(i);
    catalog(i).depthtype = depthtype(i);
    catalog(i).evaluationmethod = evaluationmethod(i);
    catalog(i).evaluationstatus = evaluationstatus(i);
    catalog(i).evaluationmode = evaluationmode(i);
    catalog(i).earthmodel = earthmodel(i);
    catalog(i).usedphasecount = usedphasecount(i);
    catalog(i).usedstationcount = usedstationcount(i);
    catalog(i).magnitudestationcount = magnitudestationcount(i);
    catalog(i).minimumdistance = minimumdistance(i);
    catalog(i).azimuthalgap = azimuthalgap(i);
    catalog(i).originerror = originerror(i);
    catalog(i).magnitudeuncertainty = magnitudeuncertainty(i);
    catalog(i).AUTHOR = 'GNS';
end
