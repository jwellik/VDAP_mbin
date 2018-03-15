%% rebuild EFIS per volcano instead of piece-wise

clearvars -except catalogStruct %catalogISC catalogJMA catalogGEM catalogBMKG catalogSSN catalogSIL
% catalogs.JMA = []; % do this to save memory if not doing Japan
%%
input.gvp_volcanoes='/Users/jpesicek/Dropbox/Research/EFIS/GVP/GVP_volcanoes_v2.mat'; % imported via importEruptionCatalog, originally from S. Ogburn
input.gvp_eruptions='/Users/jpesicek/Dropbox/Research/EFIS/GVP/gvp_eruptions_with_ids_v2.mat';
input.GSHHS = '/Users/jpesicek/Dropbox/Research/Alaska/AKDVTs/data/gshhs_f.b'; %full res;
% input.ISCcatalog = '/Users/jpesicek/Dropbox/Research/EFIS/ISC/iscCatalogAll6wFMsTrim.mat'; % importISCcatalog.m
input.outDir = '/Users/jpesicek/Dropbox/Research/EFIS/globalV4'; % importISCcatalog.m
input.catalogsDir = input.outDir;
input.localCatDir = '~/Dropbox/Research/EFIS/localCatalogs';
input.JMAcatalog = '/Users/jpesicek/Dropbox/Research/EFIS/JMA/JMAcatalog.mat';
input.GEMcatalog = '/Users/jpesicek/Dropbox/Research/EFIS/ISC/GEM/catalogGEM.mat';
input.BMKGcatalog ='/Users/jpesicek/Dropbox/Research/EFIS/BMKG/catalogBMKG.mat';
input.SSNcatalog = '/Users/jpesicek/Dropbox/Research/EFIS/SSN/catalogSSN.mat';
input.SILcatalog = '/Users/jpesicek/Dropbox/Research/EFIS/SIL/catalogSIL.mat';
input.IGNcatalog = '/Users/jpesicek/Dropbox/Research/EFIS/IGN/catalogIGN.mat';
input.INGVcatalog = '/Users/jpesicek/Dropbox/Research/EFIS/INGV/catalogINGV.mat';

%% wingPlot params
params.coasts = true;
params.wingPlot = true;
params.topo = false;
params.visible = 'off';
params.srad = [0 75];
params.DepthRange = [-3 75]; % km
params.MagRange = [0 10];
params.YearRange = [1964 2017];
params.McMinN = 75; 
params.smoothDays = 90;% in (years,months,days) 
params.maxEvents2plot = 7500;
params.McType = 'constantTimeWindow'; % 'constantTimeWindow' or 'constantEventNumber'
params.McTimeWindow = 'year'; %calendarDuration(1,0,0); % in (years,months,days) %
params.vname = 'all'; % options are 'vname' or 'all'
% params.vname = 'Yufu-Tsurumi';
% params.vname = {'St. Helens','Agung','Crater Lake','Augustine','Bogoslof','Rabaul'};
params.country = 'Japan';
params.getCats = true;

% for filnal cat and plot
paramsF = params;
paramsF.srad = [0 35];
paramsF.DepthRange = [-3 35];
%%
if ~exist('catalogStruct','var') %&& isstruct(catalog)
    catalogStruct = [];
end
catalogStruct = loadCatalogs(input,catalogStruct);
%%
load(input.gvp_volcanoes); % volcanoCat struct imported via importEruptionCatalog.m from OGBURN FILE
load(input.gvp_eruptions); % spits out eruptionCat
%%
% if isempty(gcp('nocreate'))
%     disp('making parpool...')
%     try
%         parpool(6); %each thread needs about 5GB memory,could prob do 8, but use 6 to be safe
%     catch
%         parpool(4);
%     end
% end
%% FIND specific volcano or set of volcanoes, if desired
volcanoCat = filterCatalogByVnameList(volcanoCat,params.vname,'in',params.country);
%% set up diary
[~,~,~] = mkdir(input.catalogsDir);
diaryFileName = [input.catalogsDir,filesep,datestr(now,30),'_diary.txt'];
diary(diaryFileName);
disp(mfilename('fullpath'));disp(' ');disp(input);disp(' ');disp(params)
tic
%% NOW get and save volcano catalogs
for i=1:size(volcanoCat,1)  %% PARFOR APPROVED, BUT: ISC wget calls don't like parfor, use only for getCats = no
    
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
%     catalog_ISC = getVolcCatFromLargerCat(input,params,vinfo,mapdata,catalogs.ISC,'ISC');
    catalog_ISC = getISCcat(input,params,vinfo,mapdata);
    
    %% look for and plot GEM events < 1964
    catalog_gem = getVolcCatFromLargerCat(input,params,vinfo,mapdata,catalogStruct.GEM,'GEM');
    [catalog_ISC,~] = mergeTwoCatalogs(catalog_gem,catalog_ISC);
    %%
    catalog_local = getLocalCatalog(catalogStruct,input,params,vinfo,mapdata,vinfo.country);
       
    %% compute MASTER catalog
%     catName=fullfile(vpath,['cat_MASTER_',int2str(vinfo.Vnum)]);
%     if params.getCats
%         disp('merge catalogs...')
%         [catMaster,H] = mergeTwoCatalogs(catalog_ISC,catalog_local,'yes');
%         if ~isempty(H); print(H,fullfile(vpath,'QC_MASTER_Merge_map'),'-dpng'); end;
%         catMaster = getVolcCatFromLargerCat(input,params,vinfo,mapdata,catMaster,'MASTER');
%     else
%         if exist([catName,'.mat'],'file')
%             warning('loading pre-existing catalog')
%             catMaster = load(catName); catMaster = catMaster.catalog;
%         else
%             error('catalog DNE')
%         end
%     end

%     [CatalogStatus,catNames] = check4catalogs(vpath,vinfo.Vnum,input.localCatDir);

    %%  NOW DONE MAKING CATALOG, now Mc
%     if ~isempty(catMaster)
%         %% GET Mc
%         disp('Compute Mc...')
%         % NOTE: or just do this on demand when answering a question ???!!!
%         % or both!!
%         [McG,McL,MasterMc] = buildMcbyVolcano(catMaster,catalog_ISC,catalog_local,vinfo,einfo,params,vpath);
%         %%
%         F1 = catalogQCfig(catMaster,vinfo,einfo,MasterMc.McDaily,params.visible);
%         fname=fullfile(vpath,['QC_MASTER_',int2str(vinfo.Vnum),'']);
%         print(F1,fname,'-dpng')
%         try savefig(F1,fname); catch; warning('savefig error'); end
% 
%         %% make QC plots
%         if params.wingPlot
%             disp('Map figs...')
%             F2 = catalogQCmap(catMaster,vinfo,params,mapdata);
%             print(F2,fullfile(vpath,['QC_MASTER_',int2str(vinfo.Vnum),'_map']),'-dpng')
%             mkEruptionMapQCfigs(catMaster,einfo,vinfo,mapdata,params,vpath)
%         end
%         %% FINAL CATALOG if different from Mc catalog
%         disp('Finalize...')
%         [ outer_ann, inner_ann ] = getAnnulusm( vinfo.lat, vinfo.lon, paramsF.srad);
%         mapdata = prep4WingPlot(vinfo,paramsF,input,outer_ann,inner_ann);
%         catFinal = getVolcCatFromLargerCat(input,paramsF,vinfo,mapdata,catMaster,'FINAL');
%     end
    if strcmpi(params.vname,'all')
        close all
    end
    % check DB integrity
    %     [McStatus,catNames2]= check4catalogMcs(vpath,vinfo.Vnum);
end
toc
if strcmpi(params.vname,'all')
    [CatalogStatus,catNames,result,offenderCountries,offenderVolcanoes,I] = check4catalogs(input.catalogsDir,volcanoCat,input.localCatDir);
end
