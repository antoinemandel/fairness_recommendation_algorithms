% given the values of n: number of agents, m: number of potential choices (m=n for a social network),
% a: number of acceptable choices per agent, c in [0,1]: level of correlation, the
% script generates and n x m matrix "acceptables" with coeff  (i,j) =1 if and only if j is acceptable for i
% such that for a=0 choices are independent and for a=1 choices are fully
% correlated.

% nb agents
n=10;
%nb objects
m=10;
%nb of admissible objects per agent
a=2;
%correlation level
c=0.3;

% set random seed for reproducibility;
seed=1;
rng(seed)

% if choices are fully correlated, each agent only accepts 1,2,3,...a.
% otherwise agents mix between random draw with probability c and a choice
% among  1,2,3,...a with probability (1-c)
acceptables=zeros(n,m);

for i=1:n
    rand_urn=(1:m);
    corr_urn=(1:a);
    for j=1:a
        if rand <c % with probability c, draw from the fixed set of potential choices in (1:a) 
            %draw a random link in the correlated urn 
            aux_draw=corr_urn(randi(length(corr_urn)));
            %remove the link drawn from the urn
            corr_urn=corr_urn(corr_urn~=aux_draw);
            acceptables(i,aux_draw)=1;
            
        else % with probability 1-c, draw from the wholse set of potential choices in (1:a) 
            aux_draw=rand_urn(randi(length(rand_urn)));
            %remove the link drawn from the urn
            rand_urn=rand_urn(rand_urn~=aux_draw);
            acceptables(i,aux_draw)=1;
        end
    end
end