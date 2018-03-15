function catalogs = loadCatalogs(input,catalogs)

% LOAD catalogs % must be preloaded vars for PARFOR, not on demand
% if ~isfield(catalogs,'ISC') %&& isstruct(catalog)
%     disp('loading catalogISC...') %this could be avoided by alternatively calling on demand from ISC (getISCcat.m)
%     load(input.ISCcatalog); %created using importISCcatalog.m
%     disp('...catalog loaded')
%     catalogs.ISC = catalogISC;
%     clear catalogISC;
% end
if ~isfield(catalogs,'GEM')
    disp('loading catalogGEM...')
    load(input.GEMcatalog);
    disp('...catalog loaded')
    catalogs.GEM = catalogGEM;
    clear catalogGEM;
end
if ~isfield(catalogs,'JMA') %&& isstruct(catalog)
    disp('loading catalogJMA...')
    load(input.JMAcatalog); %created using importISCcatalog.m
    disp('...catalog loaded')
    catalogs.JMA = catalogJMA;
    clear catalogJMA;
end
if ~isfield(catalogs,'BMKG') %&& isstruct(catalog)
    disp('loading catalogBMKG...')
    load(input.BMKGcatalog); %created using importISCcatalog.m
    disp('...catalog loaded')
    catalogs.BMKG = catalogBMKG;
    clear catalogBMKG;
end
if ~isfield(catalogs,'SSN') %&& isstruct(catalog)
    disp('loading catalogSSN...')
    load(input.SSNcatalog); %created using importISCcatalog.m
    disp('...catalog loaded')
    catalogs.SSN = catalogSSN;
    clear catalogSSN;
end
if ~isfield(catalogs,'SIL') %&& isstruct(catalog)
    disp('loading catalogSIL...')
    load(input.SILcatalog); %created using importISCcatalog.m
    disp('...catalog loaded')
    catalogs.SIL = catalogSIL;
    clear catalogSIL;
end
if ~isfield(catalogs,'IGN') %&& isstruct(catalog)
    disp('loading catalogIGN...')
    load(input.IGNcatalog); %created using importISCcatalog.m
    disp('...catalog loaded')
    catalogs.IGN = catalogIGN;
    clear catalogIGN;
end
if ~isfield(catalogs,'INGV') %&& isstruct(catalog)
    disp('loading catalogINGV...')
    load(input.INGVcatalog); %created using importISCcatalog.m
    disp('...catalog loaded')
    catalogs.INGV = catalogINGV;
    clear catalogINGV;
end
end