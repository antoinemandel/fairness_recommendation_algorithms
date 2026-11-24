% SIMU_FERRARA
% Extension of simu.m to the five algorithms studied by Ferrara et al.:
% Personalized PageRank (PPR), Who-to-Follow (WTF), Two-Hops (2H),
% Common-Followed (CF), and Node2Vec (N2V), together with the uniform
% benchmark and the sublinear/general preferential-attachment family.
%
% The state transition and the output statistics deliberately follow simu.m.
% Recommendations are made to one randomly selected agent per period.
%
% The script loops over several (n,a) configurations and saves one .mat file
% per configuration. Ferrara's algorithms need a square social network, so
% m=n. n=20 is a size used in the paper (a=4 and a=10); n=200 is too costly
% for the Ferrara algorithms and n=50 is run instead as the larger size.
% The Monte Carlo replications of a configuration run in parallel (parfor);
% every replication reseeds with rng(mc), so results do not depend on the
% number of workers.

tic;
clearvars;

%% Simulation parameters
% One row per configuration: [n, a, Tmax]. Tmax is far above the convergence
% times observed (<= a few thousand at n=20, <= ~30,000 at n=50) and mostly
% serves the stationary averaging used for the unfairness statistics.
configs = [20  4 100000
           20 10 100000
           50  4 200000
           50 10 200000];
cap = 3;               % out-degree capacity
MC = 25;
corrs = 0.2 * (0:5);

% Existing benchmarks, the sublinear/general PA_f family (paper Eq. 8), and
% all algorithms in Ferrara et al. PA_<alpha> uses f(d)=d^alpha; alpha<1 is
% sublinear (weaker attachment than standard PA), alpha=1 is standard PA.
algorithms = {'UN','PA_0.25','PA_0.5','PA_0.75','PA','2H','PPR','WTF','CF','N2V'};
algorithm_labels = {'Uniform','Sublinear PA (\alpha=0.25)', ...
    'Sublinear PA (\alpha=0.5)','Sublinear PA (\alpha=0.75)', ...
    'Preferential attachment (\alpha=1)','Two-hops', ...
    'Personalized PageRank','Who-to-follow','Common-followed','Node2Vec'};
n_algorithms = numel(algorithms);
n_corrs = numel(corrs);

if isempty(gcp('nocreate'))
    parpool;
end

for cfg = 1:size(configs,1)
    n = configs(cfg,1);
    m = n;
    a = configs(cfg,2);
    Tmax = configs(cfg,3);

    assert(m == n, ['Ferrara algorithms are defined on a square directed ', ...
        'social network, so this script requires m == n.']);
    assert(a > cap);
    caps = cap * ones(n,1);

    %% Recommendation options
    % Paper-compatible rule: probability is proportional to epsilon + score.
    % This reproduces simu.m exactly for UN, PA, PA_<alpha> and 2H.
    rec_opts = struct();
    rec_opts.epsilon = 1;
    rec_opts.ppr_alpha = 0.85;
    rec_opts.ppr_tol = 1e-10;
    rec_opts.ppr_max_iter = 500;
    rec_opts.cot_size = 10;
    rec_opts.salsa_tol = 1e-10;
    rec_opts.salsa_max_iter = 500;
    rec_opts.n2v_dimensions = min(64,n-1);
    rec_opts.n2v_walk_length = 10;
    rec_opts.n2v_refresh = n;      % Ferrara recomputes rankings once per round
    % Keep the candidate universe of simu.m. Existing links and diagonal
    % entries remain recommendable. Set either option to true only in a
    % separate social-recommender robustness exercise, not in paper-comparable
    % simulations.
    rec_opts.exclude_existing = false;
    rec_opts.exclude_self = false;

    file_name = sprintf('simus_ferrara_n%d_m%d_mc%d_a%d.mat',n,m,MC,a);
    fprintf('=== Configuration %d/%d: n=%d, a=%d, Tmax=%d -> %s\n', ...
        cfg,size(configs,1),n,a,Tmax,file_name);

    %% Output arrays (same organization as simu.m)
    stat_degrees = zeros(n_corrs,n_algorithms,MC,m);
    stat_time = zeros(n_corrs,n_algorithms,MC);
    stat_progress = zeros(n_corrs,n_algorithms,MC);
    stat_fairness_norm = zeros(n_corrs,n_algorithms,MC);
    stat_fairness_div = zeros(n_corrs,n_algorithms,MC);

    for ix = 1:n_corrs
        corr = corrs(ix);
        fprintf('Correlation %g (%d/%d)\n',corr,ix,n_corrs);

        for jx = 1:n_algorithms
            algorithm = algorithms{jx};
            fprintf('  Algorithm %s (%d/%d)\n',algorithm,jx,n_algorithms);

            time_mc = zeros(MC,1);
            progress_mc = zeros(MC,1);
            fnorm_mc = zeros(MC,1);
            fdiv_mc = zeros(MC,1);
            degs_mc = zeros(MC,m);

            parfor mc = 1:MC
                % Match simu.m: the same seed is reused at every correlation
                % and algorithm for a given Monte Carlo replication.
                rng(mc,'twister');
                acceptables = generate_acceptables(n,m,a,corr);
                acceptable_counts = sum(acceptables,2);
                assert(all(acceptable_counts >= caps), ...
                    'Each agent must have at least cap eligible acceptable objects.');

                % Shared core (also used by the fixed-initial-links and
                % real-network variants); called here with no fixed links,
                % which reproduces the dynamics of simu.m exactly.
                result = run_recommendation_dynamics( ...
                    acceptables,caps,algorithm,rec_opts,Tmax,[]);

                progress_mc(mc) = result.progress;
                time_mc(mc) = result.Tconv;
                degs_mc(mc,:) = result.ave_degs;
                fnorm_mc(mc) = result.fairness_norm;
                fdiv_mc(mc) = result.fairness_div;
            end

            stat_progress(ix,jx,:) = progress_mc;
            stat_time(ix,jx,:) = time_mc;
            stat_degrees(ix,jx,:,:) = reshape(degs_mc,[1 1 MC m]);
            stat_fairness_norm(ix,jx,:) = fnorm_mc;
            stat_fairness_div(ix,jx,:) = fdiv_mc;
        end
    end

    mean_time = mean(stat_time,3);
    mean_fairness_div = mean(stat_fairness_div,3,'omitnan');
    mean_fairness_norm = mean(stat_fairness_norm,3,'omitnan');
    mean_progress = mean(stat_progress,3);

    nzmean_time = NaN(n_corrs,n_algorithms);
    for ix = 1:n_corrs
        for jx = 1:n_algorithms
            times = squeeze(stat_time(ix,jx,:));
            if any(times > 0)
                nzmean_time(ix,jx) = mean(times(times > 0));
            end
        end
    end

    save(file_name,'n','m','a','cap','MC','Tmax','corrs','algorithms', ...
        'algorithm_labels','n_algorithms','n_corrs','rec_opts', ...
        'stat_degrees','stat_time','stat_progress','stat_fairness_norm', ...
        'stat_fairness_div','mean_time','mean_fairness_div', ...
        'mean_fairness_norm','mean_progress','nzmean_time');
    fprintf('Saved %s (%.1f min elapsed)\n',file_name,toc/60);
end
toc;
