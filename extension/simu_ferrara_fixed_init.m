% SIMU_FERRARA_FIXED_INIT
% Configuration where each agent has, on top of the basic choice problem of
% simu_ferrara.m, n_init fixed links that are present from t=0 and remain
% throughout the dynamics (never evicted). They are an exogenous,
% pre-existing network: they do NOT use up any of the agent's capacity and
% are drawn outside its acceptable set, so every agent keeps the same a
% acceptable objects and cap free slots whatever n_init is. n_init only
% changes the network that the algorithms see (in-degrees, paths, random
% walks, embeddings), which is what this configuration isolates.
%
% n_init plays the role of a swept parameter, like "a" in simu.m: n_init = 0
% is the plain simu_ferrara.m case (reproduced bit for bit). Two designs for
% the fixed links are run (one result file each, see GENERATE_FIXED_LINKS):
%   'uniform'    objects drawn uniformly outside the agent's acceptable set;
%   'correlated' with probability corr (the correlation of the preferences)
%                the object is drawn from a common popular block, so the
%                pre-existing network has popular objects.
% For a given replication the preferences, the fixed-link draws (nested in
% n_init) and the dynamics' random numbers are common across n_init, so
% differences across n_init come from the fixed links alone.
%
% Run TEST_FERRARA_ALGORITHMS.M first. Then run this script, then
% POSTPROCESS_SIMU_FERRARA_FIXED_INIT.M.

tic;
clearvars;

if isempty(gcp('nocreate'))
    parpool;
end

%% Simulation parameters
n = 30;
m = 30;
a = 8;                  % acceptable objects per agent
cap = 5;                % free out-degree capacity (fixed links come on top)
MC = 50;
Tmax = 60000;
corrs = [0 0.5];
n_inits = [0 1 2 4 6 8];  % 0 = no fixed links (matches simu_ferrara.m exactly)
fixed_modes = {'uniform','correlated'};
fixed_seed_offset = 1e6;  % private stream of the fixed-link draws: mc+offset

assert(m == n, ['Ferrara algorithms are defined on a square directed ', ...
    'social network, so this script requires m == n.']);
assert(a > cap);
assert(max(n_inits) <= m-a-1, 'n_init exceeds the objects outside the acceptable set.');

caps = cap * ones(n,1);

algorithms = {'UN','PA_0.25','PA_0.5','PA_0.75','PA','2H','PPR','WTF','CF','N2V'};
algorithm_labels = {'Uniform','Sublinear PA (\alpha=0.25)', ...
    'Sublinear PA (\alpha=0.5)','Sublinear PA (\alpha=0.75)', ...
    'Preferential attachment (\alpha=1)','Two-hops', ...
    'Personalized PageRank','Who-to-follow','Common-followed','Node2Vec'};
n_algorithms = numel(algorithms);
n_corrs = numel(corrs);
n_inits_n = numel(n_inits);

rec_opts.epsilon = 1;
rec_opts.ppr_alpha = 0.85;
rec_opts.ppr_tol = 1e-10;
rec_opts.ppr_max_iter = 500;
rec_opts.cot_size = 10;
rec_opts.salsa_tol = 1e-10;
rec_opts.salsa_max_iter = 500;
rec_opts.n2v_dimensions = min(64,n-1);
rec_opts.n2v_walk_length = 10;
rec_opts.n2v_refresh = n;
rec_opts.exclude_existing = false;
rec_opts.exclude_self = false;

for mode_idx = 1:numel(fixed_modes)
    fixed_mode = fixed_modes{mode_idx};
    fprintf('Fixed links: %s\n',fixed_mode);
    file_name = sprintf('simus_ferrara_fixed_init_%s_n%d_m%d_mc%d_a%d.mat', ...
        fixed_mode,n,m,MC,a);

    %% Output arrays: [n_init, corr, algorithm, mc] (or [.., m] for degrees)
    stat_degrees = zeros(n_inits_n,n_corrs,n_algorithms,MC,m);
    stat_time = zeros(n_inits_n,n_corrs,n_algorithms,MC);
    stat_progress = zeros(n_inits_n,n_corrs,n_algorithms,MC);
    stat_fairness_norm = zeros(n_inits_n,n_corrs,n_algorithms,MC);
    stat_fairness_div = zeros(n_inits_n,n_corrs,n_algorithms,MC);

    for kx = 1:n_inits_n
        n_init = n_inits(kx);
        fprintf('n_init %d (%d/%d)\n',n_init,kx,n_inits_n);

        for ix = 1:n_corrs
            corr = corrs(ix);
            fprintf('  Correlation %g (%d/%d)\n',corr,ix,n_corrs);

            for jx = 1:n_algorithms
                algorithm = algorithms{jx};
                fprintf('    Algorithm %s (%d/%d)\n',algorithm,jx,n_algorithms);

                time_mc = zeros(MC,1);
                progress_mc = zeros(MC,1);
                fnorm_mc = zeros(MC,1);
                fdiv_mc = zeros(MC,1);
                degs_mc = zeros(MC,m);

                parfor mc = 1:MC
                    % Same seed convention as simu_ferrara.m: reused across
                    % n_init, corr and algorithm for a given replication.
                    % The fixed links come from a private stream, so the
                    % global stream (preferences, then dynamics) is the
                    % same for every n_init and n_init=0 reproduces
                    % simu_ferrara.m bit for bit. Every replication
                    % reseeds, so results do not depend on the number of
                    % parallel workers.
                    rng(mc,'twister');
                    acceptables = generate_acceptables(n,m,a,corr);
                    acceptable_counts = sum(acceptables,2);
                    assert(all(acceptable_counts >= caps), ...
                        'Each agent must have at least cap eligible acceptable objects.');

                    fixed_links = generate_fixed_links(acceptables,n_init, ...
                        fixed_mode,corr,mc+fixed_seed_offset);

                    result = run_recommendation_dynamics( ...
                        acceptables,caps,algorithm,rec_opts,Tmax,fixed_links);

                    progress_mc(mc) = result.progress;
                    time_mc(mc) = result.Tconv;
                    degs_mc(mc,:) = result.ave_degs;
                    fnorm_mc(mc) = result.fairness_norm;
                    fdiv_mc(mc) = result.fairness_div;
                end

                stat_progress(kx,ix,jx,:) = progress_mc;
                stat_time(kx,ix,jx,:) = time_mc;
                stat_degrees(kx,ix,jx,:,:) = reshape(degs_mc,[1 1 1 MC m]);
                stat_fairness_norm(kx,ix,jx,:) = fnorm_mc;
                stat_fairness_div(kx,ix,jx,:) = fdiv_mc;
            end
        end
    end

    mean_time = mean(stat_time,4);
    mean_fairness_div = mean(stat_fairness_div,4,'omitnan');
    mean_fairness_norm = mean(stat_fairness_norm,4,'omitnan');
    mean_progress = mean(stat_progress,4);

    nzmean_time = NaN(n_inits_n,n_corrs,n_algorithms);
    for kx = 1:n_inits_n
        for ix = 1:n_corrs
            for jx = 1:n_algorithms
                times = squeeze(stat_time(kx,ix,jx,:));
                if any(times > 0)
                    nzmean_time(kx,ix,jx) = mean(times(times > 0));
                end
            end
        end
    end

    save(file_name);
    fprintf('Saved %s (non-converged runs: %d of %d)\n',file_name, ...
        sum(stat_time(:) == 0),numel(stat_time));
end
toc;
