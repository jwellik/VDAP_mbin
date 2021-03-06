%% PLOT CATALOG and TRIGGER SIDE by SIDE

%% get unlocated triggered events

% ! load command only works if the LOG is limited to 1 volcano

load(fullfile('/Users/jaywellik/Documents/MATLAB/VDAP_mbin/dataseries/UnitedStates_explosions/data/',LOG.volcano_name{1},'trigger.mat'))
trigger2 = trigger(isnan(trigger.LAT), :);
triggerLP = trigger2(strcmpi(trigger2.TYPE, 'longperiod'), :);
triggerVT = trigger2(strcmpi(trigger2.TYPE, 'local'), :);

[TLP, NLP, ~] = histcountst(triggerLP.DATETIME);

%% get unlocated VTs and add it to located VTs
% (assume all located events are VTs; this is mostly true)

j = 5;

[tVT, nVT, ~] = histcountst([triggerVT.DATETIME; datetime2(LOG.DATA(j).CAT.DateTime);]);
[tTrig, nTrig] = histcountst(triggerVT.DATETIME);
[tLoc, nLoc] = histcountst(datetime2(LOG.DATA(j).CAT.DateTime));

%% get RSAM data

% ds = datasource('winston', 'localhost', 16022);
% tag = ChannelTag('D.REF.--.EHZ');
% R = quickRSAM(ds, tag, datetime(2009,2,15), datetime(2009,06,01), 'rms', 10);

%% Plot

R = R0;

f = figure;

plot(LOG.DATA(j).E); hold on

r = get(R, 'data');
t = datetime2(get(R, 'timevector'));
p(1) = plot(t,r,'Color', [0.5 0.5 0.5]);

% p(1) = stairs(LOG.DATA(j).tc, LOG.DATA(j).binCounts, 'Color', [0.5 0.5 0.5], 'LineWidth', 2); hold on
yyaxis('right');
% p(2) = stairs(tLoc(1:end-1), nLoc, 'Color', 'g', 'LineWidth', 2, 'LineStyle', '-'); hold on
p(2) = stairs(tVT(1:end-1), nVT, 'k', 'LineWidth', 2, 'LineStyle', '-');
p(3) = stairs(TLP(1:end-1), NLP, 'b', 'LineWidth', 2);

ax = f.Children;
ax.Title.String = LOG.volcano_name{j};
ax.YAxis(1).TickValues = ax.YAxis(1).Limits(1):1000:ax.YAxis(1).Limits(end);
ax.YAxis(2).Color = 'k';
ax.YAxis(1).Label.String = 'RSAM';
ax.YAxis(2).Label.String = 'Event Counts';


l = legend([p(2) p(3) p(1)], 'VTs', 'LFs', 'RSAM', 'Location', 'northwest');