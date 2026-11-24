function [acceptables,keep] = snowball_sample(A,At,seed,n_target)
%SNOWBALL_SAMPLE Connected BFS/snowball sub-network of N_TARGET nodes.
%   [ACCEPTABLES,KEEP] = SNOWBALL_SAMPLE(A,AT,SEED,N_TARGET) grows a sample
%   from node SEED by plain breadth-first search on the undirected version of
%   the graph (a link in either direction connects two nodes), visiting the
%   neighbours of each node in random order (the caller controls the random
%   stream through RNG), until N_TARGET nodes are collected. The last BFS
%   layer is therefore truncated at random, as in standard snowball sampling.
%
%   A is the sparse directed adjacency matrix and AT = A' (passed in so it is
%   computed once for large graphs). KEEP are the sampled node indices, in
%   discovery order; ACCEPTABLES = full(A(KEEP,KEEP)) > 0 holds the observed
%   directed links among them, so agents and objects are the same nodes.
%   Returns empty outputs if the component of SEED has fewer than N_TARGET
%   nodes.

    N = size(A,1);
    visited = false(N,1);
    visited(seed) = true;
    keep = zeros(n_target,1);
    keep(1) = seed;
    n_found = 1;
    head = 1;

    while head <= n_found && n_found < n_target
        v = keep(head);
        head = head + 1;
        nb = [find(A(:,v)); find(At(:,v))];
        nb = nb(~visited(nb));
        nb = unique(nb);
        nb = nb(randperm(numel(nb)));
        take = min(numel(nb),n_target-n_found);
        keep(n_found+1:n_found+take) = nb(1:take);
        visited(nb(1:take)) = true;
        n_found = n_found + take;
    end

    if n_found < n_target
        acceptables = [];
        keep = [];
        return;
    end
    acceptables = full(A(keep,keep)) > 0;
end
