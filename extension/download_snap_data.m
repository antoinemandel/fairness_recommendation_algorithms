function download_snap_data(dataset)
%DOWNLOAD_SNAP_DATA Download a SNAP social network used by simu_ferrara_real_network.m.
%   DOWNLOAD_SNAP_DATA('slashdot')  soc-Slashdot0811 (about 3 MB compressed)
%   DOWNLOAD_SNAP_DATA('pokec')     soc-pokec-relationships (about 130 MB compressed,
%                                   about 400 MB once unpacked)
%
%   The edge list is stored in data/<dataset>/ next to this file, where
%   LOAD_SNAP_GRAPH looks for it. Files already present are not downloaded again.
%   Source: https://snap.stanford.edu/data/ (Leskovec and Krevl, SNAP Datasets).

    switch lower(dataset)
        case 'slashdot'
            raw_name = 'soc-Slashdot0811.txt';
        case 'pokec'
            raw_name = 'soc-pokec-relationships.txt';
        otherwise
            error('Unknown dataset "%s" (use ''slashdot'' or ''pokec'').',dataset);
    end

    folder = fullfile(fileparts(mfilename('fullpath')),'data',lower(dataset));
    if ~isfolder(folder)
        mkdir(folder);
    end
    raw_file = fullfile(folder,raw_name);
    gz_file = [raw_file '.gz'];

    if isfile(raw_file)
        fprintf('%s already present.\n',raw_file);
        return;
    end
    if ~isfile(gz_file)
        url = ['https://snap.stanford.edu/data/' raw_name '.gz'];
        fprintf('Downloading %s ...\n',url);
        websave(gz_file,url);
    end
    fprintf('Unpacking %s ...\n',gz_file);
    gunzip(gz_file,folder);
    fprintf('Done: %s\n',raw_file);
end
