% SIMU_FERRARA_REAL_NETWORK
% Configuration where the acceptable links are read off a real network
% instead of being generated synthetically: SNAP soc-Slashdot0811 or
% soc-Pokec (directed "a links to b"; raw files in data/slashdot and
% data/pokec, parsed once into a cached sparse matrix by LOAD_SNAP_GRAPH).
%
% Each Monte Carlo replication is one real sample: a connected sub-network
% of n_target nodes collected by plain BFS/snowball sampling (SNOWBALL_SAMPLE)
% from a seed node, with neighbours visited in random order. Seeds are drawn
% reproducibly among nodes of degree >= seed_min_degree and are never taken
% from inside an earlier sample, so samples do not overlap. The observed
% directed links among the sampled nodes are the acceptable links (i finds j
% acceptable iff i links to j); agents and objects are the same n_target
% nodes, as the Ferrara algorithms require. The dynamics start from the empty
% network and are the same as in simu_ferrara.m, for every algorithm on every
% sample.
%
% Capacities are heterogeneous: agent i can keep cap_frac*|E_i| links (at
% least one, at most cap_max), see CAPACITIES_FROM_ACCEPTABLES. Sampled
% sub-networks of sparse social graphs are sparse, so a fixed capacity of 3
% would leave most agents with no choice at all. The unfairness benchmark is
% the general sum_i 1{j in E_i} caps(i)/|E_i| (see RUN_RECOMMENDATION_DYNAMICS).
%
% Run TEST_FERRARA_ALGORITHMS.M first, then this script, then
% POSTPROCESS_SIMU_FERRARA_REAL_NETWORK.M.

tic;
clearvars;

%% Simulation parameters
dataset = 'pokec';      % 'slashdot' or 'pokec'
n_target = 100;         % nodes per sample (set the sample size here)
MC = 50;                % number of real samples (BFS seeds)
cap_frac = 0.5;         % share of its acceptable objects an agent can keep
cap_max = 3;            % upper bound on capacity
seed_min_degree = 20;   % BFS seeds are nodes with in+out degree >= this
Tmax = 150000;
sample_seed = 12345;    % selects seeds and neighbour orders, reproducibly

algorithms = {'UN','PA_0.25','PA_0.5','PA_0.75','PA','2H','PPR','WTF','CF','N2V'};
algorithm_labels = {'Uniform','Sublinear PA (\alpha=0.25)', ...
    'Sublinear PA (\alpha=0.5)','Sublinear PA (\alpha=0.75)', ...
    'Preferential attachment (\alpha=1)','Two-hops', ...
    'Personalized PageRank','Who-to-follow','Common-followed','Node2Vec'};
n_algorithms = numel(algorithms);

rec_opts.epsilon = 1;
rec_opts.ppr_alpha = 0.85;
rec_opts.ppr_tol = 1e-10;
rec_opts.ppr_max_iter = 500;
rec_opts.cot_size = 10;
rec_opts.salsa_tol = 1e-10;
rec_opts.salsa_max_iter = 500;
rec_opts.n2v_dimensions = min(64,n_target-1);
rec_opts.n2v_walk_length = 10;
rec_opts.n2v_refresh = n_target;
rec_opts.exclude_existing = false;
rec_opts.exclude_self = false;

file_name = sprintf('simus_ferrara_real_%s_n%d_mc%d.mat',dataset,n_target,MC);

%% Collect the samples (BFS/snowball from reproducibly drawn seeds)
[A,ids] = load_snap_graph(dataset);
At = A';
N = size(A,1);
deg = full(sum(A,1))' + full(sum(A,2));
candidates = find(deg >= seed_min_degree);
assert(numel(candidates) >= MC,'Too few seed candidates for MC=%d.',MC);
rng(sample_seed,'twister');
candidates = candidates(randperm(numel(candidates),min(numel(candidates),100*MC)));

sample_acceptables = cell(MC,1);
sample_node_ids = cell(MC,1);
sample_seed_node = zeros(MC,1);
used = false(N,1);
n_samples = 0;
for c = 1:numel(candidates)
    if n_samples == MC
        break;
    end
    seed_node = candidates(c);
    if used(seed_node)
        continue;
    end
    rng(sample_seed + n_samples + 1,'twister');
    [acc,keep] = snowball_sample(A,At,seed_node,n_target);
    if isempty(acc)
        continue;            % seed in a component smaller than n_target
    end
    n_samples = n_samples + 1;
    used(keep) = true;
    sample_acceptables{n_samples} = acc;
    sample_node_ids{n_samples} = ids(keep);
    sample_seed_node(n_samples) = ids(seed_node);
end
assert(n_samples == MC,'Only %d of %d samples could be collected.',n_samples,MC);
clear A At deg used candidates;   % keep the saved .mat small

%% Output arrays: [algorithm, mc] (or [.., n_target] for degrees)
stat_degrees = zeros(n_algorithms,MC,n_target);
stat_time = zeros(n_algorithms,MC);
stat_progress = zeros(n_algorithms,MC);
stat_fairness_norm = zeros(n_algorithms,MC);
stat_fairness_div = zeros(n_algorithms,MC);

% Descriptors of each sample (to interpret differences across samples)
sample_n_links = zeros(MC,1);
sample_density = zeros(MC,1);
sample_reciprocity = zeros(MC,1);
sample_mean_E = zeros(MC,1);
sample_frac_choice = zeros(MC,1);   % agents with more acceptable objects than slots
sample_sum_caps = zeros(MC,1);
sample_indeg_gini = zeros(MC,1);

if isempty(gcp('nocreate'))
    parpool;
end

% Samples are independent, so they run in parallel; every algorithm on a
% sample reseeds with rng(mc), so results do not depend on the worker count.
parfor mc = 1:MC
    acceptables = sample_acceptables{mc};
    E_sizes = sum(acceptables,2);
    caps = capacities_from_acceptables(acceptables,cap_frac,cap_max);

    sample_n_links(mc) = nnz(acceptables);
    sample_density(mc) = nnz(acceptables)/(n_target*(n_target-1));
    sample_reciprocity(mc) = nnz(acceptables & acceptables')/max(nnz(acceptables),1);
    sample_mean_E(mc) = mean(E_sizes);
    sample_frac_choice(mc) = mean(E_sizes > caps);
    sample_sum_caps(mc) = sum(caps);
    indeg = sort(sum(acceptables,1),'ascend');
    sample_indeg_gini(mc) = sum((2*(1:n_target)-n_target-1).*indeg) / ...
        (n_target*max(sum(indeg),1));

    time_col = zeros(n_algorithms,1);
    progress_col = zeros(n_algorithms,1);
    fnorm_col = zeros(n_algorithms,1);
    fdiv_col = zeros(n_algorithms,1);
    degs_col = zeros(n_algorithms,n_target);
    for jx = 1:n_algorithms
        % Same dynamics seed for every algorithm on a given sample.
        rng(mc,'twister');
        result = run_recommendation_dynamics( ...
            acceptables,caps,algorithms{jx},rec_opts,Tmax,[]);
        progress_col(jx) = result.progress;
        time_col(jx) = result.Tconv;
        degs_col(jx,:) = result.ave_degs;
        fnorm_col(jx) = result.fairness_norm;
        fdiv_col(jx) = result.fairness_div;
    end
    stat_progress(:,mc) = progress_col;
    stat_time(:,mc) = time_col;
    stat_degrees(:,mc,:) = reshape(degs_col,[n_algorithms 1 n_target]);
    stat_fairness_norm(:,mc) = fnorm_col;
    stat_fairness_div(:,mc) = fdiv_col;
end

for mc = 1:MC
    fprintf('Sample %d/%d (seed %d): %d links, mean |E_i| %.1f, %.0f%% agents with a choice, sum caps %d\n', ...
        mc,MC,sample_seed_node(mc),sample_n_links(mc),sample_mean_E(mc), ...
        100*sample_frac_choice(mc),sample_sum_caps(mc));
    fprintf('    Tconv: %s\n',strjoin(compose('%s=%d',string(algorithms(:)),stat_time(:,mc)),', '));
end

mean_time = mean(stat_time,2);
mean_fairness_div = mean(stat_fairness_div,2,'omitnan');
mean_fairness_norm = mean(stat_fairness_norm,2,'omitnan');
mean_progress = mean(stat_progress,2);

nzmean_time = NaN(n_algorithms,1);
for jx = 1:n_algorithms
    times = stat_time(jx,:);
    if any(times > 0)
        nzmean_time(jx) = mean(times(times > 0));
    end
end

save(file_name);
toc;
