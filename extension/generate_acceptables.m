function acceptables = generate_acceptables(n,m,a,corr)
%GENERATE_ACCEPTABLES Preference generator extracted from simu.m.
% For each agent, each of its a acceptable objects is drawn from the common
% set 1:a with probability corr and from all remaining objects otherwise.

    if a > m
        error('a cannot exceed m.');
    end
    if corr < 0 || corr > 1
        error('corr must lie in [0,1].');
    end

    acceptables = false(n,m);
    for i = 1:n
        random_urn = 1:m;
        correlated_urn = 1:a;
        for draw = 1:a
            use_correlated = rand < corr && ~isempty(correlated_urn);
            if use_correlated
                pos = randi(numel(correlated_urn));
                obj = correlated_urn(pos);
            else
                pos = randi(numel(random_urn));
                obj = random_urn(pos);
            end
            random_urn(random_urn == obj) = [];
            correlated_urn(correlated_urn == obj) = [];
            acceptables(i,obj) = true;
        end
    end
end

