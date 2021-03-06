function [ s, picks, event ] = readQuakeML( quakemlFile )

% reads a quakeML file and returns a more easily accesible "picks" structure
% and/or an "event" structure if it exists in file;
% J. PESICEK 2017
%
if ~exist(quakemlFile,'file')==2 % single quakeml file input
    error('file DNE')
end

s = xml2struct(quakemlFile); %downloaded from matlab exchange
quake = s.q_colon_quakeml.eventParameters.event;

picks =  returnpicks(quake);
event =  returnevent(quake);
picks = addArrivals2picks(event,picks);

end
%%
function picks = returnpicks(quake)

numpicks = numel(quake.pick);
for i=1:numpicks
    tmp(i).sta   = quake.pick{1,i}.waveformID.Attributes.stationCode;
end

for i=1:numpicks
    
    pick(i).sta   = quake.pick{1,i}.waveformID.Attributes.stationCode;
    pick(i).chan = quake.pick{1,i}.waveformID.Attributes.channelCode;
    pick(i).net = quake.pick{1,i}.waveformID.Attributes.networkCode;
    pick(i).time  = quake.pick{1,i}.time.value.Text;
    try
        pick(i).phase = quake.pick{1,i}.phaseHint.Text;
    catch
        disp(['could not find phase hint for ',pick(i).sta])
    end
    try
        pick(i).uncert= str2double(quake.pick{1,i}.time.uncertainty.Text);
    catch
        disp(['could not find pick uncertainty for ',pick(i).sta])
    end
    try
        pick(i).dn = datenum(pick(i).time,'yyyy-mm-ddTHH:MM:SS.FFFZ');
    catch
        pick(i).dn = datenum(pick(i).time,'yyyy-mm-ddTHH:MM:SSZ');
    end
    try
        pick(i).loc = quake.pick{1,i}.waveformID.Attributes.locationCode;
    catch
        disp('No location code provided, using default')
        pick(i).loc = '--';
    end
    try
        pick(i).polarity = quake.pick{1,i}.polarity.Text;
    catch
        pick(i).polarity = '?';
    end
    try
        pick(i).onset = quake.pick{1,i}.onset.Text;
    catch
        pick(i).onset = '?';
    end
    pick(i).publicID = quake.pick{1,i}.Attributes.publicID;
    
end

[~,I]=sort(extractfield(pick,'sta'));
picks = pick(I);

end
%%
function event = returnevent(quake)

try
    origin = quake.origin;
    if numel(origin)>1
        origin = origin{1};
    end
    dt = origin.time.value.Text;
    event.DateTime = datestr(datenum(dt,'yyyy-mm-ddTHH:MM:SS.FFFZ'));
    event.Latitude = str2double(origin.latitude.value.Text);
    event.Longitude = str2double(origin.longitude.value.Text);
    event.Depth = str2double(origin.depth.value.Text)/1000;
    try
        event.Magnitude = str2double(quake.magnitude.mag.value.Text);
        event.MagType = quake.magnitude.type.Text;
    catch
        event.Magnitude = [];
        event.MagType = [];
    end
    % TODO: there are more fields to add...
    %     event.arrival = origin.arrival;
    for i=1:numel(quake.origin.arrival)
        try
            event.Arrival(i).azimuth = str2double(quake.origin.arrival{1,i}.azimuth.Text);
            try
                event.Arrival(i).takeoffAngle = str2double(quake.origin.arrival{1,i}.takeoffAngle.Text);
            catch
                event.Arrival(i).takeoffAngle = str2double(quake.origin.arrival{1,i}.takeoffAngle.value.Text);
            end
            event.Arrival(i).distance = str2double(quake.origin.arrival{1,i}.distance.Text);
            event.Arrival(i).pickID = quake.origin.arrival{1,i}.pickID.Text; %PICK ID
        catch
            warning('trouble')
        end
        % TODO: more fields to add later...
    end
catch
    warning('missing event data')
    event = [];
end
end

%% merge arrivals to picks
function picks = addArrivals2picks(event,picks)

try
    for i=1:numel(picks)
        for j=1:numel(event.Arrival)
            I = strcmp(picks(i).publicID,event.Arrival(j).pickID);
            if I==1
                picks(i).azimuth = event.Arrival(j).azimuth;
                picks(i).takeoffAngle = event.Arrival(j).takeoffAngle;
                picks(i).distance = event.Arrival(j).distance;
                break
            end
        end
    end
catch
    warning('adding arrival to picks failed')
end

end
