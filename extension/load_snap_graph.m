function [A,ids] = load_snap_graph(dataset,data_dir)
%LOAD_SNAP_GRAPH Directed adjacency matrix of a large SNAP social network.
%   [A,IDS] = LOAD_SNAP_GRAPH(DATASET) with DATASET 'slashdot'
%   (soc-Slashdot0811) or 'pokec' (soc-pokec-relationships) returns the
%   sparse logical N x N matrix A with A(i,j)=1 iff the edge list contains
%   IDS(i) -> IDS(j), without self-loops or duplicates. The first call parses
%   the raw text file (slow for Pokec: ~30M edges) and stores the result in
%   DATA_DIR/<dataset>/<dataset>_graph.mat; later calls load that cache.
%
%   DATA_DIR defaults to the "data" folder next to this file.

    if nargin < 2
        data_dir = fullfile(fileparts(mfilename('fullpath')),'data');
    end

    switch lower(dataset)
        case 'slashdot'
            raw_name = 'soc-Slashdot0811.txt';
        case 'pokec'
            raw_name = 'soc-pokec-relationships.txt';
        otherwise
            error('Unknown dataset "%s" (use ''slashdot'' or ''pokec'').',dataset);
    end
    folder = fullfile(data_dir,lower(dataset));
    cache = fullfile(folder,sprintf('%s_graph.mat',lower(dataset)));

    if isfile(cache)
        s = load(cache,'A','ids');
        A = s.A;
        ids = s.ids;
        return;
    end

    raw_file = fullfile(folder,raw_name);
    assert(isfile(raw_file),'Raw file %s not found.',raw_file);
    fprintf('Parsing %s (one-time, cached afterwards)...\n',raw_file);
    E = readmatrix(raw_file,'FileType','text','CommentStyle','#');
    E = E(:,1:2);
    E = E(E(:,1) ~= E(:,2),:);
    [ids,~,ic] = unique(E(:));
    clear E;
    N = numel(ids);
    half = numel(ic)/2;
    A = sparse(ic(1:half),ic(half+1:end),true,N,N);
    clear ic;
    save(cache,'A','ids','-v7.3');
end
