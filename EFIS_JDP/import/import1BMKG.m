function [catalog] = import1BMKG(filename, startRow, endRow)
%IMPORTFILE Import numeric data from a text file as column vectors.
%   [DATE,TIME,LATITUDE,LONGITUDE,DEPTH,MAG,TYPEMAG,SMAJ,SMIN,AZ,RMS1,CPHASE,REGION]
%   = IMPORTFILE(FILENAME) Reads data from text file FILENAME for the
%   default selection.
%
%   [DATE,TIME,LATITUDE,LONGITUDE,DEPTH,MAG,TYPEMAG,SMAJ,SMIN,AZ,RMS1,CPHASE,REGION]
%   = IMPORTFILE(FILENAME, STARTROW, ENDROW) Reads data from rows STARTROW
%   through ENDROW of text file FILENAME.
%
% Example:
%   [Date,Time,Latitude,Longitude,Depth,Mag,TypeMag,smaj,smin,az,rms1,cPhase,Region] = importfile('BMKG_0ct30download.txt',1, 394);
%
%    See also TEXTSCAN.

% Auto-generated by MATLAB on 2017/10/30 13:02:54

%% Initialize variables.
delimiter = {'\t\t','\t'};
if nargin<=2
    startRow = 1;
    endRow = inf;
end

%% Read columns of data as strings:
% For more information, see the TEXTSCAN documentation.
formatSpec = '%s%s%s%s%s%s%s%s%s%s%s%s%s%[^\n\r]';

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

for col=[3,4,5,6,8,9,10,11,12]
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
rawNumericColumns = raw(:, [3,4,5,6,8,9,10,11,12]);
rawCellColumns = raw(:, [1,2,7,13]);


%% Replace non-numeric cells with NaN
R = cellfun(@(x) ~isnumeric(x) && ~islogical(x),rawNumericColumns); % Find non-numeric cells
rawNumericColumns(R) = {NaN}; % Replace non-numeric cells

%% Allocate imported array to column variable names
Date = rawCellColumns(:, 1);
Time = rawCellColumns(:, 2);
Latitude = cell2mat(rawNumericColumns(:, 1));
Longitude = cell2mat(rawNumericColumns(:, 2));
Depth = cell2mat(rawNumericColumns(:, 3));
Mag = cell2mat(rawNumericColumns(:, 4));
TypeMag = rawCellColumns(:, 3);
smaj = cell2mat(rawNumericColumns(:, 5));
smin = cell2mat(rawNumericColumns(:, 6));
az = cell2mat(rawNumericColumns(:, 7));
rms1 = cell2mat(rawNumericColumns(:, 8));
cPhase = cell2mat(rawNumericColumns(:, 9));
Region = rawCellColumns(:, 4);


%%
for i=1:length(Date)-1
    
    dts(i) = datenum([char(Date(i)),' ',char(Time(i))]);
    
    catalog(i).Latitude = Latitude(i);
    catalog(i).Longitude = Longitude(i);
    catalog(i).Depth = Depth(i);
    catalog(i).Magnitude = Mag(i);
    catalog(i).DateTime = datestr(dts(i),'yyyy/mm/dd HH:MM:SS.FFF');
    catalog(i).TypeMag = TypeMag(i);
    catalog(i).smaj = smaj(i);
    catalog(i).smin = smin(i);
    catalog(i).az = az(i);
    catalog(i).rms1 = rms1(i);
    catalog(i).cPhase = cPhase(i);
    catalog(i).Region = Region(i);    
    catalog(i).AUTHOR = 'BMKG';
end