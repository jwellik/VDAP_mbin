%% params
% The script will use all entries from the configuration file to make all
% possible combinations of these variables, run the time series anlaysis,
% and save the output for each test

%% Catalog Parameters

catalog_scope = 'master'; % { 'separate' | ['master'] }
catalog_type = 'locations'; % { 'counts' | 'detections' | 'locations' }
catalog_background_time = {[datetime(2002,01,01), datetime(2013,01,01)]}
Mc_type = 'static'; % { 'static' | 'timeseries' }
minmag = {0}
maxdepth = {30}
annulus = {[2 30] [2 45] [0 30]}

%% Time series window parameters

%%% t_window is given as n-by-2 pairs, where 
% t_windows(:,1) is the step increment for the sampling times, and
% t_window(:,2) is the window length
t_window = {[-30 30] [-60 60] [-14 14] [-7 7] [1 1] [1 7] [1 14] [1 30]}; % all
t_window = {[-90 90] [-30 30] [1 1]}; % short version for testing
t_step = t_window(:,1);
t_width = t_window(:,2);

%% Network downtime

ntwk_down = [];

%% Beta parameters
it = {10000} % iterations for empirical beta
emp_threshold = {0.05} % confidence level; aka, be_thresPer

%% Analysis parameters

study_start = datetime(1970,1,1)
vei_reset = {2} % repose time is reset after each eruption of vei >= x
vei_forecast = {3} % success of forecast is determined for all eruptions of vei >= x
preEruptSearchTime =  {8*30} % days
repose_time = {0:1:25} % years
dur_variation = {0.2} % percent by which to vary eruption durations; subtracted and added from eruption end date