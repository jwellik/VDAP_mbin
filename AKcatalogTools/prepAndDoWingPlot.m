function fh_wingplot = prepAndDoWingPlot(vinfo,params,inputFiles,catalog,outer,inner,plot_windows,plot_names)

disp('WingPlot...')
%% Geographical Plot
longannO = outer(:,2); latannO=outer(:,1);
% if ~isnan(inner)
%     longannI = inner(:,2); latannI=inner(:,1);
% end

%%
%map axes
% catalog = filterTime( catalog, t1, t2);
if size(catalog,2) > 0
    elat = extractfield(catalog, 'Latitude');
    elong = extractfield(catalog, 'Longitude');
else
    elat = [];
    elong = [];
end
latlim = [min([latannO]) max([latannO])];

% deal with crossing 180 longitude for semisepochnoi
if sign(min(longannO)) ~= sign(max(longannO))
    warning('avoiding LON meridian bug, NO stations or summits yet!')
    vinfo.lon(vinfo.lon<0) = vinfo.lon(vinfo.lon<0) + 360;
    vinfo.vcoords(vinfo.vcoords(:,2)<0,2) = vinfo.vcoords(vinfo.vcoords(:,2)<0,2) +360;
    %     vlonann(vlonann<0) = vlonann(vlonann<0) + 360;
    elong(elong<0) = elong(elong<0) + 360;
    longannO(longannO<0) = longannO(longannO<0) + 360;
    lonlim = [min([elong'; longannO]) max([elong'; longannO])];
    [latlim, lonlim] = bufgeoquad(latlim, lonlim, .005, .005);
    lonlim(lonlim<0) = lonlim(lonlim<0)+360  ;
else
    lonlim = [min([longannO]) max([longannO])];
    [latlim, lonlim] = bufgeoquad(latlim, lonlim, .005, .005);
end

% coastline database - full res
if params.coasts
    disp('  coastlines...')
    indexname = [inputFiles.GSHHS(1:end-1),'i'];
    if ~exist(indexname,'file')
        try
            indexname = gshhs(inputFiles.GSHHS, 'createindex');
        catch
            pause(2)
            indexname = gshhs(inputFiles.GSHHS, 'createindex');
        end
    end
    mapdata.coastlines = gshhs(inputFiles.GSHHS, latlim, lonlim);
    %     delete(indexname)
end

% add for topo
if params.topo
    disp('  topo...')
    try
        layers = wmsfind('nasa.network*elev', 'SearchField', 'serverurl');
        layers = wmsupdate(layers);
        srtmplus = layers.refine('srtm30', 'SearchField', 'layername');
        cellSize = dms2degrees([0 0 10]);
        [ZA, RA] = wmsread(srtmplus, 'Latlim', latlim, 'Lonlim', lonlim, ...
            'CellSize', cellSize, 'ImageFormat', 'image/bil','RelTolCellSize',0.01);
        
        mapdata.ZA = ZA;
        mapdata.RA = RA;
    catch
        warning('TOPO NO BUENO')
    end
end
%%
% AK stations
try
    [~,AVlat,AVlon,AVelev] = importStationFile(inputFiles.AKstas);
    id_a2 = inpolygon(AVlon, AVlat, longannO, latannO);
    mapdata.sta_lat = AVlat(id_a2);
    mapdata.sta_lon = AVlon(id_a2);
    mapdata.sta_elev = AVelev(id_a2);
catch
    mapdata.sta_lat = [];
    mapdata.sta_lon = [];
    mapdata.sta_lat = [];
end
mapdata.outer = outer;
mapdata.inner = inner;
disp(['# of events = ' num2str(length(elat))]);

disp('Enter wing plot...')

outDirName=[params.outDir,'/',vinfo.name];
if ~exist(outDirName,'dir')
    [~,~,~] = mkdir(outDirName);
end

if ~isfield(params,'catlabel')
    params.catlabel = '';
end

% now need to loop over window periods and make new maps
for i=1:size(plot_windows,1)
    
    t1 = plot_windows(i,1);
    t2 = plot_windows(i,2);
    catalog_t = filterTime(catalog,t1,t2);
    fh_wingplot = wingPlot_AK5(vinfo, t1, t2, catalog_t, mapdata, params);
    print(fh_wingplot,'-dpng',[outDirName,'/',vinfo.name,'_WingPlot',params.catlabel,'_',char(plot_names(i,:))])
    
end

end