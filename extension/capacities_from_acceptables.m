function caps = capacities_from_acceptables(acceptables,cap_frac,cap_max)
%CAPACITIES_FROM_ACCEPTABLES Heterogeneous capacities for real samples.
%   CAPS = CAPACITIES_FROM_ACCEPTABLES(ACCEPTABLES,CAP_FRAC,CAP_MAX) gives
%   agent i the capacity
%
%       min(CAP_MAX, max(min(1,|E_i|), floor(CAP_FRAC*|E_i|)))
%
%   i.e. a fraction CAP_FRAC of its acceptable objects (at least one when it
%   has any), bounded by CAP_MAX. For CAP_FRAC<1 every agent with at least
%   two acceptable objects has strictly fewer slots than acceptable objects,
%   so the algorithm genuinely chooses among equivalent links (the paper's
%   a>cap regime); agents with a single acceptable object are forced, and
%   agents with none have capacity 0 and stay inactive.

    if cap_frac <= 0 || cap_frac >= 1
        error('cap_frac must lie in (0,1).');
    end
    E_sizes = sum(acceptables,2);
    caps = min(cap_max,max(min(1,E_sizes),floor(cap_frac*E_sizes)));
end
