function [obj,cache,probs] = ferrara_recommendation(net,ag,algorithm,opts,cache,t)
%FERRARA_RECOMMENDATION Draw one object using a Ferrara-style algorithm.
%   [OBJ,CACHE,PROBS] = FERRARA_RECOMMENDATION(...)
%   returns a stochastic recommendation for agent AG and its probability
%   vector. Every algorithm follows the convention of the original simu.m:
%
%       probability(j) is proportional to epsilon + score_j.
%
%   In the paper-compatible configuration, existing and self links remain
%   recommendable. Optional filters are retained only for separate social-
%   network robustness exercises.

    [n,m] = size(net);
    if n ~= m
        error('Ferrara algorithms require a square social-network matrix.');
    end

    algorithm = upper(char(algorithm));
    raw = zeros(1,m);

    % General preferential attachment PA_f with f(d)=d^alpha, i.e. the
    % paper's PA_f family (Eq. 8) / simu.m's vals=epsilon+degs.^alpha branch
    % for alpha<2. 'PA' remains the alias for standard/linear PA (alpha=1).
    % Sublinear PA (0<alpha<1, e.g. 'PA_0.25','PA_0.5','PA_0.75') and
    % superlinear PA (alpha>1) are both reached through this same pattern.
    pa_alpha_token = regexp(algorithm,'^PA_([0-9]*\.?[0-9]+)$','tokens','once');

    if ~isempty(pa_alpha_token)
        pa_alpha = str2double(pa_alpha_token{1});
        if pa_alpha == 2
            error(['PA_2 collides with the hops-style algorithms; use ', ...
                '''2H'' for two-hops instead.']);
        end
        raw = full(sum(net,1)).^pa_alpha;
    else

    switch algorithm
        case 'UN'
            % Additive epsilon alone gives the uniform distribution.
            raw(:) = 0;

        case 'PA'
            raw = full(sum(net,1));

        case {'2H','2HP'}
            % Number of directed paths ag -> k -> j (Ferrara Eq. 3).
            raw = full(net(ag,:) * net);

        case 'CF'
            % Number of objects followed both by ag and candidate j
            % (Ferrara Eq. 4). Candidates are nodes because n=m.
            raw = full(net(ag,:) * net');

        case 'PPR'
            raw = personalized_pagerank(net,ag,opts);

        case 'WTF'
            raw = who_to_follow_scores(net,ag,opts);

        case 'N2V'
            refresh = ~isfield(cache,'n2v_scores') || ...
                mod(t-1,max(1,opts.n2v_refresh)) == 0;
            if refresh
                embedding = node2vec_netmf_embedding(net,opts);
                cache.n2v_scores = cosine_similarity_matrix(embedding);
            end
            raw = cache.n2v_scores(ag,:);

        otherwise
            error('Unknown recommendation algorithm: %s',algorithm);
    end
    end

    raw(~isfinite(raw) | raw < 0) = 0;
    eligible = true(1,m);
    if opts.exclude_self
        eligible(ag) = false;
    end
    if opts.exclude_existing
        eligible = eligible & ~logical(full(net(ag,:)));
    end

    if ~any(eligible)
        % This can only occur with aggressive candidate filtering.
        eligible(:) = true;
        if opts.exclude_self
            eligible(ag) = false;
        end
    end

    epsilon = opts.epsilon;
    if ~isscalar(epsilon) || ~isfinite(epsilon) || epsilon <= 0
        error('opts.epsilon must be a strictly positive scalar.');
    end

    % Exact analogue of vals=epsilon+score in the original simu.m.
    weights = epsilon + raw;
    weights(~eligible) = 0;
    probs = weights/sum(weights);
    obj = sample_discrete_weights(weights);
end

function pi = personalized_pagerank(net,seed,opts)
    n = size(net,1);
    P = row_stochastic(net);
    restart = zeros(1,n);
    restart(seed) = 1;
    pi = restart;

    for iter = 1:opts.ppr_max_iter
        updated = (1-opts.ppr_alpha)*restart + opts.ppr_alpha*(pi*P);
        if norm(updated-pi,1) <= opts.ppr_tol
            pi = updated;
            break;
        end
        pi = updated;
    end
end

function scores = who_to_follow_scores(net,seed,opts)
    n = size(net,1);
    ppr = personalized_pagerank(net,seed,opts);
    ppr(seed) = -Inf;
    [~,order] = sort(ppr,'descend');
    cot = order(1:min(opts.cot_size,n-1));

    % SALSA authority chain on hubs in the circle of trust and the nodes
    % they follow. H(h,j)=1 when circle-of-trust hub h follows authority j.
    H = double(full(net(cot,:)) > 0);
    if nnz(H) == 0
        scores = zeros(1,n);
        return;
    end

    hub_degree = sum(H,2);
    authority_degree = sum(H,1);
    hub_degree(hub_degree == 0) = 1;
    authority_degree(authority_degree == 0) = 1;

    P_hub_to_auth = H ./ hub_degree;
    P_auth_to_hub = H' ./ authority_degree';
    authority_transition = P_auth_to_hub * P_hub_to_auth;

    scores = ones(1,n)/n;
    for iter = 1:opts.salsa_max_iter
        updated = scores * authority_transition;
        if sum(updated) > 0
            updated = updated/sum(updated);
        end
        if norm(updated-scores,1) <= opts.salsa_tol
            scores = updated;
            break;
        end
        scores = updated;
    end
end

function P = row_stochastic(net)
    n = size(net,1);
    P = double(full(net) > 0);
    rowsums = sum(P,2);
    dangling = rowsums == 0;
    rowsums(dangling) = 1;
    P = P ./ rowsums;
    P(dangling,:) = 1/n;
end

function embedding = node2vec_netmf_embedding(net,opts)
% Deterministic matrix-factorization approximation to Node2Vec with p=q=1.
% It uses the expected random-walk co-occurrence matrix rather than fitting
% skip-gram to sampled walks. This avoids an external Python dependency and
% is reproducible. See README for the distinction from Ferrara's N2V run.
    n = size(net,1);
    if nnz(net) == 0
        embedding = zeros(n,1);
        return;
    end
    P = row_stochastic(net);
    walk_matrix = zeros(n);
    powerP = eye(n);
    for r = 1:opts.n2v_walk_length
        powerP = powerP * P;
        walk_matrix = walk_matrix + powerP/r;
    end

    cooc = (walk_matrix + walk_matrix')/2;
    total = sum(cooc,'all');
    if total <= 0
        embedding = eye(n,min(opts.n2v_dimensions,n));
        return;
    end

    joint = cooc/total;
    marginal = sum(joint,2);
    expected = marginal*marginal';
    ppmi = log(max(joint,realmin)./max(expected,realmin));
    ppmi(ppmi < 0 | ~isfinite(ppmi)) = 0;

    dim = min([opts.n2v_dimensions,n-1,rank(ppmi)]);
    if dim < 1
        embedding = zeros(n,1);
        return;
    end
    [U,S,~] = svd(ppmi,'econ');
    embedding = U(:,1:dim)*sqrt(S(1:dim,1:dim));
end

function similarities = cosine_similarity_matrix(embedding)
    norms = sqrt(sum(embedding.^2,2));
    norms(norms == 0) = 1;
    normalized = embedding ./ norms;
    similarities = normalized*normalized';
    % Cosine similarity can be negative, while recommendation scores cannot.
    similarities = max(similarities,0);
end

function index = sample_discrete_weights(weights)
    % Same cumulative-sum sampling expression as in the original simu.m.
    distribution = cumsum(weights)/sum(weights);
    index = find(rand(1) <= distribution,1,'first');
    if isempty(index)
        index = numel(weights); % protects against round-off at 1
    end
end
