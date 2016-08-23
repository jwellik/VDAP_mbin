function [ ax ] = addXAxes( eruptions, ax, xaxes, xaxesloc )
%ADDXAXES Adds additional x-axes (for repose time and precursor time) to a
%plot of eruptions
%   Detailed explanation goes here

%%

% initialization variables for additional axes
nxaxes = numel(xaxes); % # of x axes
ntopxaxes = numel(strfind(xaxesloc,'t')); % # of x axes on top
nbotxaxes = numel(strfind(xaxesloc,'b')); % # of x axes on bottom
if ntopxaxes + nbotxaxes ~= nxaxes; error('There is an error with the number of axes specified.'); end
xaxesheight = 0.75; % centimeters - height of each x axes; i.e., amt of vertical room needed for each additional x axes

% change units in original axis and figure to centimeters
ax.Units = 'centimeters';
f = gcf; f.Units = 'centimeters';

% change position of the main plot axis ('ax1')
f.Position(4) = f.Position(4) + nxaxes * xaxesheight; % adjust the figure size to accomodate the additional axes
ax1.Position(2) = ax1.Position(2) + nbotxaxes*xaxesheight; % moves the bottom of the axes up by enough cm to accomodate additional bottom axes
ax1.Position(4) = ax1.Position(4) - ntopxaxes*xaxesheight; % shortens the axes by enough cm to accomodate additional x axes on the top

% create and place the additional axes
n = 2;
ax(n) = axes;
ax(n).Units = 'centimeters';
ax(n).Position(2) = ax(n-1).Position(2) - xaxesheight - 0.1;
ax(n).Position(4) = 0;

n = 3;
ax(n) = axes;
ax(n).Units = 'centimeters';
ax(n).Position(2) = ax(n-1).Position(2) - xaxesheight - 0.1;
ax(n).Position(4) = 0;

linkaxes(ax, 'x');

%%

% get eruption starts and stops
eruption_starts = get(eruptions, 'start');
eruption_ends = get(eruptions, 'stop');

% Tick Label for Repose Years
RYTick = [];
RYTickLabel = [];
for n = 1:numel(eruption_starts)-1
    RYTick = [RYTick, eruption_ends(n):1:eruption_starts(n+1)]; % "Repose Years Tick"
    RYTickLabel = [RYTickLabel, (eruption_ends(n):1:eruption_starts(n+1))-eruption_ends(n)]; % "Repose Years Tick Label"
end
RYTick = [RYTick, eruption_ends(n+1):1:max_date]; % "Repose Years Tick"
RYTickLabel = [RYTickLabel, (eruption_ends(n+1):1:max_date)-eruption_ends(n+1)]; % "Repose Years Tick Label"

RYTickLabel2 = num2cell(RYTickLabel);
ax2.XTick = RYTick;
ax2.XTickLabel = RYTickLabel2;

% ax2.XLabel.String = 'Years in Repose';
% % ax2.XLabel.Units = 'centimeters';
% % ax2.XLabel.Position = ax2.Position(1:3);
% % ax2.XLabel.HorizontalAlignment = 'center';
% % ax2.XLabel.VerticalAlignment = 'cap';
% ax2.XLabel.String = 'Time: Date, Years in Repose, Years Until Eruption';

%%

% Tick Label for Years to Eruption
Y2ETick = [];
Y2ETickLabel = [];
Y2ETick = [Y2ETick, flip(eruption_starts(1):-1:min_date)];
Y2ETickLabel = [Y2ETickLabel, eruption_starts(1)-flip(eruption_starts(1):-1:min_date)];
for n = 2:numel(eruption_starts)
    Y2ETick = [Y2ETick, flip(eruption_starts(n):-1:eruption_ends(n-1))]; 
    Y2ETickLabel = [Y2ETickLabel, eruption_starts(n)-flip(eruption_starts(n):-1:eruption_ends(n-1))];
end
Y2ETickLabel2 = num2cell(Y2ETickLabel);
ax3.XTick = Y2ETick;
ax3.XTickLabel = Y2ETickLabel2;

ax3.XLabel.String = 'Years to Eruption';
% ax2.XLabel.Units = 'centimeters';
% ax2.XLabel.Position = ax2.Position(1:3);
% ax2.XLabel.HorizontalAlignment = 'center';
% ax2.XLabel.VerticalAlignment = 'cap';
ax3.XLabel.String = 'Time: Date, Years in Repose, Years to Eruption';


end

