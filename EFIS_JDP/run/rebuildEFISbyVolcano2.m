%% rebuild EFIS per volcano instead of piece-wise

clearvars -except catalogISC catalogJMA catalogGEM catalogBMKG catalogSSN
%%
input.gvp_volcanoes='/Users/jpesicek/Dropbox/Research/EFIS/GVP/GVP_volcanoes_v2.mat'; % imported via importEruptionCatalog, originally from S. Ogburn
input.gvp_eruptions='/Users/jpesicek/Dropbox/Research/EFIS/GVP/gvp_eruptions_with_ids_v2.mat';
input.GSHHS = '/Users/jpesicek/Dropbox/Research/Alaska/AKDVTs/data/gshhs_f.b'; %full res;
input.ISCcatalog = '/Users/jpesicek/Dropbox/Research/EFIS/ISC/iscCatalogAll6wFMsTrim.mat'; % importISCcatalog.m
input.outDir = '/Users/jpesicek/Dropbox/Research/EFIS/testNewMc'; % importISCcatalog.m
input.catalogsDir = input.outDir;
input.localCatDir = '~/Dropbox/Research/EFIS/localCatalogs';
input.JMAcatalog = '/Users/jpesicek/Dropbox/Research/EFIS/JMA/JMAcatalog.mat';
input.GEMcatalog = '/Users/jpesicek/Dropbox/Research/EFIS/ISC/GEM/catalogGEM.mat';
input.BMKGcatalog ='/Users/jpesicek/Dropbox/Research/EFIS/BMKG/catalogBMKG.mat';
input.SSNcatalog = '/Users/jpesicek/Dropbox/Research/EFIS/SSN/catalogSSN.mat';

%% wingPlot params
params.coasts = true;
params.wingPlot = false;
params.topo = false;
params.visible = 'off';
params.srad = [0 100];
params.DepthRange = [-3 70]; % km
params.MagRange = [0 10];
params.YearRange = [1964 2016];
params.McMinN = 50;
params.smoothYrs = 3;
params.maxEvents2plot = 10000;

params.vname = 'all'; % options are 'vname' or 'all'
params.country = 'New Zealand';

% for filnal cat and plot
paramsF = params;
paramsF.srad = [0 35];
paramsF.DepthRange = [-3 35];

%% set up diary
[~,~,~] = mkdir(input.catalogsDir);
diaryFileName = [input.catalogsDir,filesep,datestr(now,30),'_diary.txt'];
diary(diaryFileName);
disp(mfilename('fullpath'))
disp(' ')
disp(input)
disp(' ')
disp(params)
%%
% LOAD catalogs % must be preloaded vars for PARFOR, not on demand
if ~exist('catalogISC','var') %&& isstruct(catalog)
    disp('loading catalogISC...') %this could be avoided by alternatively calling on demand from ISC (getISCcat.m)
    load(input.ISCcatalog); %created using importISCcatalog.m
    disp('...catalog loaded')
end
if ~exist('catalogGEM','var')
    disp('loading catalogGEM...')
    load(input.GEMcatalog);
    disp('...catalog loaded')
end
if ~exist('catalogJMA','var') %&& isstruct(catalog)
    disp('loading catalogJMA...')
    load(input.JMAcatalog); %created using importISCcatalog.m
    disp('...catalog loaded')
end
if ~exist('catalogBMKG','var') %&& isstruct(catalog)
    disp('loading catalogBMKG...')
    load(input.BMKGcatalog); %created using importISCcatalog.m
    disp('...catalog loaded')
end
if ~exist('catalogSSN','var') %&& isstruct(catalog)
    disp('loading catalogSSN...')
    load(input.SSNcatalog); %created using importISCcatalog.m
    disp('...catalog loaded')
end

load(input.gvp_volcanoes); % volcanoCat struct imported via importEruptionCatalog.m from OGBURN FILE
load(input.gvp_eruptions); % spits out eruptionCat
%%
if isempty(gcp('nocreate'))
    disp('making parpool...')
    try
        parpool(6); %each thread needs about 5GB memory,could prob do 8, but use 6 to be safe
    catch
        parpool(4);
    end
end
%% FIND specific volcano or set of volcanoes, if desired
if ~strcmpi(params.vname,'all')
    vnames = extractfield(volcanoCat,'Volcano');
    vi = find(strcmp(params.vname,vnames));
    volcanoCat = volcanoCat(vi);
    if isempty(volcanoCat);error('bad vname');end
end
if ~strcmpi(params.country,'all')
    volcanoCat = filterCatalogByCountry(volcanoCat,params.country);
end
tic
%% NOW get and save volcano catalogs
parfor i=14:size(volcanoCat,1)  %% PARFOR APPROVED
    
    catalog_local = []; catMaster = [];
    
    [vinfo] = getVolcanoInfo(volcanoCat,[],i);
    disp([int2str(i),'/',int2str(size(volcanoCat,1)),', ',vinfo.name,', ',vinfo.country])
    einfo = getEruptionInfoFromNameOrNum(vinfo.Vnum,eruptionCat);
    
    vpath = fullfile(input.catalogsDir,fixStringName(vinfo.country),fixStringName(vinfo.name));
    volcOutName = fixStringName(vinfo.name);
    outVinfoName=fullfile(vpath,['vinfo_',int2str(volcanoCat(i).Vnum),'.mat']);
    [~,~,~] = mkdir(vpath);
    
    [ outer_ann, inner_ann ] = getAnnulusm( vinfo.lat, vinfo.lon, params.srad);
    mapdata = prep4WingPlot(vinfo,params,input,outer_ann,inner_ann);
    
    %% get ISC catalog
    catalog_ISC = getVolcCatFromLargerCat(input,params,vinfo,mapdata,catalogISC,'ISC');
    % look for and plot GEM events < 1964
    catalog_gem = getVolcCatFromLargerCat(input,params,vinfo,mapdata,catalogGEM,'GEM');
    [catalog_ISC,~] = mergeTwoCatalogs(catalog_gem,catalog_ISC);
    
    %% ANSS
    if strcmpi(vinfo.country,'United States')
        catalog_local = getANSScat(input,params,vinfo,mapdata); %wget
    end
    %% GNS
    if strcmpi(vinfo.country,'New Zealand')
        catalog_local = getGNScat(input,params,vinfo,mapdata); %wget
    end
    %% JMA
    if strcmpi(vinfo.country,'Japan') || strcmp(vinfo.country,'Japan - administered by Russia')
        catalog_local = getVolcCatFromLargerCat(input,params,vinfo,mapdata,catalogJMA,'JMA');
    end
    %% BMKG
    if strcmpi(vinfo.country,'Indonesia')
        catalog_local = getVolcCatFromLargerCat(input,params,vinfo,mapdata,catalogBMKG,'BMKG');
    end
    %% SSN
    if strcmpi(vinfo.country,'Mexico') || strcmp(vinfo.country,'Mexico-Guatemala')
        catalog_local = getVolcCatFromLargerCat(input,params,vinfo,mapdata,catalogSSN,'SSN');
    end
    %% local catalog
    LocalCatalogFile = fullfile(input.localCatDir,['local_',int2str(vinfo.Vnum),'.mat']);
    if exist(LocalCatalogFile,'file')
        if ~isempty(catalog_local)
            error('You may be overwriting regional catalog here') % merge later
        end
        catalog_local = load(LocalCatalogFile); catalog_local = catalog_local.catalog;
        catalog_local = getVolcCatFromLargerCat(input,params,vinfo,mapdata,catalog_local,'LOCAL');
    end
    %     [CatalogStatus,catNames] = check4catalogs(vpath,vinfo.Vnum,input.localCatDir);
    
    %% compute MASTER catalog
    disp('merge catalogs...')
    [catMaster,H] = mergeTwoCatalogs(catalog_ISC,catalog_local,'yes');
    if ~isempty(H); print(H,fullfile(vpath,'QC_MASTER_Merge_map'),'-dpng'); end;
    outCatName=fullfile(vpath,['cat_MASTER_',int2str(vinfo.Vnum),'.mat']);
    parsave_catalog(outCatName,catMaster);
    
    %%  NOW DONE MAKING CATALOG, now MC
    if ~isempty(catMaster)
        %% GET Mc
        disp('Compute Mc...')
        [McG,McL,MasterMc] = buildMcbyVolcano(catMaster,catalog_ISC,catalog_local,vinfo,params,vpath);
        %%
        F1 = catalogQCfig(catMaster,vinfo,einfo,MasterMc.McDaily,params.visible);
        fname=fullfile(vpath,['QC_MASTER_',int2str(vinfo.Vnum),'']);
        print(F1,fname,'-dpng')
        try savefig(F1,fname); catch; warning('savefig error'); end
    end
    % check DB integrity
    %     [McStatus,catNames2]= check4catalogMcs(vpath,vinfo.Vnum);
    %%
    if ~isempty(catMaster)
        %% make QC plots
        if params.wingPlot
            disp('Map figs...')
            F2 = catalogQCmap(catMaster,vinfo,params,mapdata);
            print(F2,fullfile(vpath,['QC_MASTER_',int2str(vinfo.Vnum),'_map']),'-dpng')
            
            %full catalog
            dts = datenum(extractfield(catMaster,'DateTime'));
            t1min = min(dts);
            t1a = min([t1min,datenum(params.YearRange(1),1,1)]); t2a=datenum(params.YearRange(2)+1,1,1);
            figname=fullfile(vpath,['map_MASTER_',fixStringName(vinfo.name)]);
            fh_wingplot = wingPlot1(vinfo, t1a, t2a, catMaster, mapdata, params,1);
            print(fh_wingplot,'-dpng',[figname,'.png'])
            
            mkEruptionMapQCfigs(catalog,einfo,vinfo,mapdata,params,vpath)
        end
        
        %% FINAL CATALOG if different from Mc catalog
        disp('Finalize...')
        catalog = filterDepth( catMaster, paramsF.DepthRange); % (d)
        %         catalog = filterMag( catalog, paramsF.MagRange); % (e)
        catalog = filterAnnulusm( catalog, vinfo.lat,vinfo.lon, paramsF.srad); % (e)
        outCatName=fullfile(vpath,['cat_FINAL_',int2str(vinfo.Vnum),'.mat']);
        parsave_catalog(outCatName,catalog);
        if params.wingPlot && ~isempty(catalog)
            [ outer_ann, inner_ann ] = getAnnulusm( vinfo.lat, vinfo.lon, paramsF.srad);
            mapdata = prep4WingPlot(vinfo,paramsF,input,outer_ann,inner_ann);
            dts = datenum(extractfield(catalog,'DateTime'));
            t1min = min(dts);
            t1a = min([t1min,datenum(paramsF.YearRange(1),1,1)]); t2a=datenum(paramsF.YearRange(2)+1,1,1);
            figname=fullfile(vpath,['map_FINAL_',fixStringName(vinfo.name)]);
            fh_wingplot = wingPlot1(vinfo, t1a, t2a, catalog, mapdata, paramsF,1);
            print(fh_wingplot,'-dpng',[figname,'.png'])
        end
    end
    close all
end
toc
% [result,status,offenderCountries,offenderVolcanoes,I] = checkCatalogDBintegrity(input.catalogsDir,volcanoCat);
