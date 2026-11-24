function fixed_links = generate_fixed_links(acceptables,n_init,mode,fixed_corr,seed)
%GENERATE_FIXED_LINKS Random seed links held fixed throughout the dynamics.
%   FIXED_LINKS = GENERATE_FIXED_LINKS(ACCEPTABLES,N_INIT,MODE,FIXED_CORR,SEED)
%   draws, for each agent, N_INIT distinct objects that are neither
%   acceptable to the agent nor the agent itself, and marks them as
%   permanently linked. The links represent a pre-existing/exogenous network
%   that sits on top of the basic choice problem: since they never coincide
%   with an acceptable object, every agent keeps the same acceptable objects
%   and the same free capacity whatever N_INIT is (see
%   RUN_RECOMMENDATION_DYNAMICS).
%
%   MODE 'uniform': objects drawn uniformly from the agent's pool (all
%   objects outside its acceptable set, itself excluded).
%
%   MODE 'correlated': each draw comes, with probability FIXED_CORR, from a
%   common popular block of objects, and uniformly from the rest of the pool
%   otherwise. This is the preference generator GENERATE_ACCEPTABLES applied
%   to the fixed links, so the pre-existing network has popular objects when
%   FIXED_CORR>0. The block is the a objects just after the common set 1:a
%   of the preferences, i.e. a+1:min(m,2a) with a=max_i|E_i|: the common set
%   itself cannot be used, because it is acceptable to most agents at high
%   correlation and so is excluded from their pool. FIXED_CORR=0 gives the
%   uniform mode.
%
%   SEED selects a private random stream, so the call does not touch the
%   global random number generator, and the draws are nested: the order in
%   which each agent's pool is drawn does not depend on N_INIT, so the fixed
%   links for N_INIT contain those for any smaller N_INIT with the same
%   SEED. Using one SEED for all N_INIT in a sweep therefore isolates the
%   effect of the number of fixed links, and N_INIT=0 leaves a simulation
%   identical to the one without fixed links.

    [n,m] = size(acceptables);
    acceptables = logical(full(acceptables));
    if n_init < 0
        error('n_init must be non-negative.');
    end
    if ~any(strcmp(mode,{'uniform','correlated'}))
        error('mode must be ''uniform'' or ''correlated''.');
    end
    if fixed_corr < 0 || fixed_corr > 1
        error('fixed_corr must lie in [0,1].');
    end

    stream = RandStream('twister','Seed',seed);

    a = max(sum(acceptables,2));
    popular = (a+1):min(m,2*a);
    if strcmp(mode,'correlated') && fixed_corr > 0 && isempty(popular)
        error('No popular block available: need m > max_i|E_i|.');
    end

    fixed_links = false(n,m);
    for i = 1:n
        pool = find(~acceptables(i,:));
        pool(pool == i) = [];
        if numel(pool) < n_init
            error('Agent %d has only %d objects outside its acceptable set, fewer than n_init=%d.', ...
                i,numel(pool),n_init);
        end

        % Full ordering of the pool (independent of n_init, hence nested).
        if strcmp(mode,'uniform') || fixed_corr == 0
            order = pool(randperm(stream,numel(pool)));
        else
            remaining = pool;
            popular_remaining = intersect(pool,popular);
            order = zeros(1,numel(pool));
            for k = 1:numel(pool)
                if rand(stream) < fixed_corr && ~isempty(popular_remaining)
                    obj = popular_remaining(randi(stream,numel(popular_remaining)));
                else
                    obj = remaining(randi(stream,numel(remaining)));
                end
                order(k) = obj;
                remaining(remaining == obj) = [];
                popular_remaining(popular_remaining == obj) = [];
            end
        end
        fixed_links(i,order(1:n_init)) = true;
    end
end
