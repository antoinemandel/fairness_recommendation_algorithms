% TEST_FERRARA_ALGORITHMS Fast smoke tests for recommendation validity.
rng(1,'twister');
n = 8;
net = sparse([1 1 2 3 4 5 6],[2 3 3 4 5 6 7],1,n,n);

opts.epsilon = 1;
opts.ppr_alpha = 0.85;
opts.ppr_tol = 1e-10;
opts.ppr_max_iter = 500;
opts.cot_size = 4;
opts.salsa_tol = 1e-10;
opts.salsa_max_iter = 500;
opts.n2v_dimensions = 4;
opts.n2v_walk_length = 5;
opts.n2v_refresh = n;
opts.exclude_existing = false;
opts.exclude_self = false;

algorithms = {'UN','PA_0.25','PA_0.5','PA_0.75','PA','2H','PPR','WTF','CF','N2V'};
for k = 1:numel(algorithms)
    cache = struct();
    draws = zeros(1,50);
    for t = 1:50
        [draws(t),cache,probs] = ferrara_recommendation( ...
            net,1,algorithms{k},opts,cache,t);
        assert(all(isfinite(probs)) && all(probs >= 0));
        assert(abs(sum(probs)-1) < 1e-12);
    end
    assert(all(draws >= 1 & draws <= n));
end

% Regression tests: the algorithms shared with simu.m must generate exactly
% its probability vectors.
degs = full(sum(net,1));
[~,~,p_un] = ferrara_recommendation(net,1,'UN',opts,struct(),1);
[~,~,p_pa] = ferrara_recommendation(net,1,'PA',opts,struct(),1);
[~,~,p_2h] = ferrara_recommendation(net,1,'2H',opts,struct(),1);

expected_un = ones(1,n)/n;
expected_pa = opts.epsilon + degs;
expected_pa = expected_pa/sum(expected_pa);
expected_2h = opts.epsilon + full(net(1,:)*net);
expected_2h = expected_2h/sum(expected_2h);

assert(max(abs(p_un-expected_un)) < 1e-12);
assert(max(abs(p_pa-expected_pa)) < 1e-12);
assert(max(abs(p_2h-expected_2h)) < 1e-12);

% Sublinear/general PA_f must match simu.m's vals=epsilon+degs.^alpha branch
% for alpha<2 exactly, for both a fractional (sublinear) and an integer
% exponent that is not itself aliased to another algorithm.
for pa_alpha = [0.25 0.5 0.75 3]
    [~,~,p_pa_alpha] = ferrara_recommendation( ...
        net,1,sprintf('PA_%g',pa_alpha),opts,struct(),1);
    expected_pa_alpha = opts.epsilon + degs.^pa_alpha;
    expected_pa_alpha = expected_pa_alpha/sum(expected_pa_alpha);
    assert(max(abs(p_pa_alpha-expected_pa_alpha)) < 1e-12);
end

% PA_2 is reserved for two-hops to avoid ambiguity with the hops family.
threw = false;
try
    ferrara_recommendation(net,1,'PA_2',opts,struct(),1);
catch
    threw = true;
end
assert(threw);

acceptables0 = generate_acceptables(10,10,4,0);
acceptables1 = generate_acceptables(10,10,4,1);
assert(all(sum(acceptables0,2) == 4));
assert(all(sum(acceptables1,2) == 4));
assert(all(all(acceptables1(:,1:4))));

%% run_recommendation_dynamics / fixed_links checks
n2 = 12; m2 = 12; a2 = 5; cap2 = 3; corr2 = 0.3;
rng(3,'twister');
acc2 = generate_acceptables(n2,m2,a2,corr2);
caps2 = cap2*ones(n2,1);
opts2 = opts; opts2.n2v_refresh = n2;

% No fixed links must exactly match the plain (no-fixed_links) call.
rng(21,'twister');
r_plain = run_recommendation_dynamics(acc2,caps2,'PA',opts2,4000,[]);
rng(21,'twister');
r_empty_fixed = run_recommendation_dynamics( ...
    acc2,caps2,'PA',opts2,4000,false(n2,m2));
assert(isequal(r_plain.Tconv,r_empty_fixed.Tconv));
assert(isequal(r_plain.ave_degs,r_empty_fixed.ave_degs));

%% Fixed links sit on top of the choice problem
% generate_fixed_links: outside the acceptable set, not self, n_init per agent,
% nested in n_init, private random stream, and correlated mode concentrates on
% the popular block a+1:2a.
for mode = {'uniform','correlated'}
    mode = mode{1};
    rng(31,'twister'); state_before = rng;
    f2 = generate_fixed_links(acc2,2,mode,0.7,99);
    f4 = generate_fixed_links(acc2,4,mode,0.7,99);
    state_after = rng;
    assert(isequal(state_before.State,state_after.State), ...
        'generate_fixed_links must not touch the global random stream.');
    for fl = {f2,f4}
        fl = fl{1};
        assert(~any(any(fl & acc2)), 'fixed links must avoid acceptable objects');
        assert(~any(diag(fl)), 'fixed links must avoid self');
    end
    assert(all(sum(f2,2) == 2) && all(sum(f4,2) == 4));
    assert(all(all(f4(f2))), 'fixed links must be nested in n_init');
    assert(~any(any(generate_fixed_links(acc2,0,mode,0.7,99))));
end
% Correlated mode: more of the fixed links fall in the popular block.
big = generate_acceptables(40,40,6,0);
popular_block = false(1,40); popular_block(7:12) = true;
share = @(f) mean(sum(f(:,popular_block),2)./sum(f,2));
share_uniform = share(generate_fixed_links(big,4,'uniform',1,5));
share_correlated = share(generate_fixed_links(big,4,'correlated',1,5));
assert(share_correlated > 0.95 && share_uniform < 0.4);
assert(isequal(generate_fixed_links(big,4,'correlated',0,5), ...
    generate_fixed_links(big,4,'uniform',0,5)));

% With fixed links the core must keep the same choice problem: same free
% capacity (benchmark), same acceptable objects, total out-degree = cap + n_init.
fixed2 = generate_fixed_links(acc2,2,'uniform',0,7);
rng(22,'twister');
r_fixed = run_recommendation_dynamics(acc2,caps2,'PA',opts2,12000,fixed2);
assert(r_fixed.Tconv > 0);
assert(isequal(r_fixed.micro_alloc,r_plain.micro_alloc), ...
    'the free-capacity benchmark must not depend on the fixed links');
assert(max(abs(r_fixed.ave_degs_free - (r_fixed.ave_degs - sum(fixed2,1)))) < 1e-9);

% n_init = 0 through generate_fixed_links is identical to no fixed links.
rng(21,'twister');
r_zero = run_recommendation_dynamics(acc2,caps2,'PA',opts2,4000, ...
    generate_fixed_links(acc2,0,'uniform',0,7));
assert(isequal(r_plain.Tconv,r_zero.Tconv) && isequal(r_plain.ave_degs,r_zero.ave_degs));

% Replay the dynamics by hand: fixed links never evicted, each agent ends with
% exactly caps2 free links on top of its fixed links, and every free link is acceptable.
rng(22,'twister');
total_caps2 = caps2 + sum(fixed2,2);
net_check = sparse(double(fixed2));
cache2 = struct();
for t = 1:6000
    ag = randi(n2,1);
    [obj,cache2] = ferrara_recommendation(net_check,ag,'PA',opts2,cache2,t);
    if acc2(ag,obj)
        net_check(ag,obj) = 1;
        if sum(net_check(ag,:)) > total_caps2(ag)
            candidates = find(net_check(ag,:) > 0 & ~fixed2(ag,:));
            unobj = randsample(candidates,1);
            net_check(ag,unobj) = 0;
        end
    end
    assert(all(all(full(net_check(fixed2)))), ...
        'A fixed link was evicted at step %d.',t);
end
free_net = full(net_check) & ~fixed2;
assert(all(sum(free_net,2) <= caps2) && ~any(any(free_net & ~acc2)));

% Fixed links overlapping the acceptable objects must error: they would
% silently shrink the agent's choices.
threw = false;
try
    run_recommendation_dynamics(acc2,caps2,'PA',opts2,10,acc2);
catch
    threw = true;
end
assert(threw);

%% Real-network sampler checks on a synthetic directed graph
% Nodes 1-6: a hub (1) linked to 2..5, plus 2<->3, 4->5, 6->1; nodes 7,8 form
% a separate 2-node component.
A_t = sparse([1 1 1 1 2 3 4 6 7],[2 3 4 5 3 2 5 1 8],true,8,8);
At_t = A_t';
rng(9,'twister');
[acc_t,keep_t] = snowball_sample(A_t,At_t,1,5);
assert(isequal(size(acc_t),[5 5]) && numel(unique(keep_t)) == 5);
assert(keep_t(1) == 1);                           % starts at the seed
assert(all(ismember(keep_t,1:6)));                % stays in the seed's component
assert(isequal(acc_t,full(A_t(keep_t,keep_t)) > 0));
assert(max(conncomp(graph(double(acc_t | acc_t')))) == 1);
[acc_e,keep_e] = snowball_sample(A_t,At_t,1,7);   % component too small
assert(isempty(acc_e) && isempty(keep_e));
[acc_s,keep_s] = snowball_sample(A_t,At_t,7,3);   % 2-node component < 3
assert(isempty(acc_s));

% Capacity rule: fraction of |E_i|, at least 1 if any, at most cap_max, and
% strictly below |E_i| whenever |E_i|>=2.
E_t = [0 1 2 3 4 6 7 20]';
acc_c = false(numel(E_t),30);
for i = 1:numel(E_t), acc_c(i,1:E_t(i)) = true; end
caps_c = capacities_from_acceptables(acc_c,0.5,3);
assert(isequal(caps_c(:)',[0 1 1 1 2 3 3 3]));
assert(all(caps_c(E_t >= 2) < E_t(E_t >= 2)));

% Heterogeneous capacities and acceptable sets run through the shared core.
n3 = 8; rng(4,'twister');
acc3 = rand(n3) < 0.5; acc3(1:n3+1:end) = false;
acc3(8,:) = false;                                  % agent 8 follows nobody
caps3 = min(2,sum(acc3,2));
assert(caps3(8) == 0);
r3 = run_recommendation_dynamics(acc3,caps3,'UN',opts,6000,[]);
assert(r3.Tconv > 0);
assert(abs(sum(r3.micro_alloc) - sum(caps3)) < 1e-9);

disp(['All Ferrara extension smoke tests passed, including exact ', ...
    'UN/PA/PA_alpha/2H compatibility checks, fixed_links mechanics and ', ...
    'real-network sampler checks.']);
