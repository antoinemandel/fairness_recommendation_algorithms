function result = run_recommendation_dynamics(acceptables,caps,algorithm,opts,Tmax,fixed_links)
%RUN_RECOMMENDATION_DYNAMICS Shared network-formation core.
%   RESULT = RUN_RECOMMENDATION_DYNAMICS(ACCEPTABLES,CAPS,ALGORITHM,OPTS,TMAX)
%   runs, from an empty network, the same recommendation-driven dynamics as
%   simu.m/simu_ferrara.m for one Monte Carlo replication: at each step an
%   agent is drawn uniformly at random, FERRARA_RECOMMENDATION proposes an
%   object, and the link is formed if acceptable, evicting a uniformly
%   random existing link of the same agent if this exceeds its capacity.
%
%   ACCEPTABLES is n x m (logical or 0/1), ACCEPTABLES(i,j)=1 iff object j
%   is acceptable to agent i. CAPS is an n x 1 vector of out-degree
%   capacities (need not be uniform). ALGORITHM and OPTS are passed through
%   to FERRARA_RECOMMENDATION.
%
%   RESULT = RUN_RECOMMENDATION_DYNAMICS(...,FIXED_LINKS) additionally seeds
%   the network with the n x m logical matrix FIXED_LINKS. Fixed links sit ON
%   TOP of the basic choice problem: they are present from t=0 and never
%   evicted, but they do not use up any of CAPS (the free capacity, governed
%   by the recommendation algorithm) and must not coincide with an
%   acceptable object, so every agent keeps exactly the same acceptable
%   objects and CAPS(i) free slots whatever the number of fixed links. The
%   total out-degree of agent i is CAPS(i)+rowsum(FIXED_LINKS)(i). Fixed
%   links only change the network the algorithms see (degrees, paths,
%   random walks, embeddings). Omit or pass [] for the plain case (no fixed
%   links), which reproduces simu.m/simu_ferrara.m exactly.
%
%   Returns a struct with fields:
%     Tconv          first t at which every agent's free capacity is full (0
%                    if never reached within Tmax)
%     progress       share of the free capacity filled at t=Tmax
%     ave_degs       1 x m, time-average in-degree during the stationary
%                    phase (includes the fixed contribution, if any)
%     ave_degs_free  ave_degs with the (constant) fixed in-degree removed;
%                    this is what should be compared to the benchmark
%     micro_alloc    1 x m proportional benchmark for the free capacity:
%                    micro_alloc(j) = sum_i acceptables(i,j)*caps(i)/|E_i|,
%                    which reduces to (cap/a)*debts when caps and |E_i| are
%                    uniform, as in the original synthetic experiments
%     fairness_norm, fairness_div  distance of ave_degs_free from
%                    micro_alloc (NaN if Tconv==0)

    [n,m] = size(acceptables);
    acceptables = double(acceptables);

    if nargin < 6 || isempty(fixed_links)
        fixed_links = false(n,m);
    end
    if ~isequal(size(fixed_links),[n,m])
        error('fixed_links must be n x m, matching acceptables.');
    end
    fixed_links = logical(full(fixed_links));

    caps = full(caps(:));
    if numel(caps) ~= n
        error('caps must have n entries.');
    end
    if any(any(fixed_links & acceptables > 0))
        error(['fixed_links must lie outside the acceptable objects, so that ', ...
            'they do not reduce the choices left to the agent.']);
    end
    % Fixed links are on top of the free capacity.
    total_caps = caps + sum(fixed_links,2);

    E_sizes = sum(acceptables,2);

    net = sparse(double(fixed_links));
    ave_degs = zeros(1,m);
    Tconv = 0;
    n_stationary_obs = 0;
    cache = struct();

    for t = 1:Tmax
        ag = randi(n,1);
        [obj,cache] = ferrara_recommendation(net,ag,algorithm,opts,cache,t);

        if acceptables(ag,obj)
            net(ag,obj) = 1;
            if sum(net(ag,:)) > total_caps(ag)
                % Only non-fixed links of ag are eligible for eviction; this
                % set is always non-empty here because the overflow was
                % caused by the free link just added (fixed links are
                % never acceptable, so the new link is a free one).
                candidates = find(net(ag,:) > 0 & ~fixed_links(ag,:));
                unobj = randsample(candidates,1);
                net(ag,unobj) = 0;
            end
        end

        if Tconv == 0 && nnz(net) >= sum(total_caps)
            Tconv = t;
        end

        if Tconv > 0
            n_stationary_obs = n_stationary_obs + 1;
            degs = full(sum(net,1));
            ave_degs = ave_degs + (degs-ave_degs)/n_stationary_obs;
        end
    end

    result.Tconv = Tconv;
    result.progress = (nnz(net)-nnz(fixed_links))/sum(caps);
    result.ave_degs = ave_degs;

    fixed_degs = full(sum(fixed_links,1));
    ave_degs_free = ave_degs - fixed_degs;
    result.ave_degs_free = ave_degs_free;

    w = zeros(n,1);
    has_E = E_sizes > 0;
    w(has_E) = caps(has_E) ./ E_sizes(has_E);
    micro_alloc = w' * acceptables;
    result.micro_alloc = micro_alloc;

    if Tconv > 0
        result.fairness_norm = norm(ave_degs_free-micro_alloc);
        positive = (ave_degs_free > 0) & (micro_alloc > 0);
        result.fairness_div = sum( ...
            ave_degs_free(positive).*log(ave_degs_free(positive)./micro_alloc(positive)));
    else
        result.fairness_norm = NaN;
        result.fairness_div = NaN;
    end
end
