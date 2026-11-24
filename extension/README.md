# MATLAB extension for Ferrara link recommendation algorithms

Run `simu_ferrara.m`, then `postprocess_simu_ferrara.m`. The original code
of the paper is in `../baseline/` and is unchanged by this extension. All
commands are run from this folder; every simulation script writes a `.mat`
file here and every postprocess script reads the `.mat` files from here, so the
precomputed results in this folder reproduce the figures without rerunning the
simulations.

The script adds the five algorithms in Ferrara et al. (2022):

- `PPR`: personalized PageRank, with alpha 0.85.
- `WTF`: personalized-PageRank circle of trust followed by SALSA authority
  ranking; the circle contains at most 10 nodes.
- `2H`: number of directed paths of length two.
- `CF`: number of common followed nodes.
- `N2V`: cosine similarity in a network embedding.

`UN` and `PA` are retained as benchmarks, alongside the general/sublinear
preferential-attachment family `PA_<alpha>` (Grabisch-Mandel-Rusinowska's
PA_f with `f(d)=d^alpha`, their Eq. 8): `PA_0.25`, `PA_0.5`, and `PA_0.75`
are included by default in `simu_ferrara.m` as sublinear (weaker-than-linear)
attachment, and any `PA_<alpha>` string with `alpha` not equal to 2 is
accepted (`alpha=2` is reserved for `2H`, since `mat=net^2` already covers
that case in `simu.m`). Every algorithm uses the original paper's stochastic
recommendation convention:

`probability(j) proportional to epsilon + score(j)`, with `epsilon=1`.

For `UN`, `PA`, `PA_<alpha>`, and `2H`, the resulting probability vectors are
exactly those of the supplied `simu.m` (`vals=epsilon+degs.^alpha` for
`alpha<2`). The smoke test includes explicit regression checks for this
equivalence.

## Important modeling choices

Ferrara's methods are people recommenders defined on a square social network.
The script therefore requires `n==m`. It does not invent a bipartite extension
for cases such as `n=200,m=400`.

Existing and self links remain recommendable by default, exactly as in the
supplied `simu.m`. This is important: filtering existing links turns uniform
recommendation into sampling without replacement and materially changes its
convergence time. Optional filters remain available for a separately labelled
social-recommender robustness exercise, but should not be used for figures
compared with the original paper.

The acceptable-link generator, random seeds, capacity/replacement rule,
convergence criterion, stationary averaging and micro-founded benchmark also
follow `simu.m`.

Ferrara fits Node2Vec using sampled walks and skip-gram. To keep this MATLAB
bundle self-contained, `N2V` uses a deterministic NetMF-style factorization of
the expected random-walk co-occurrence matrix with `p=q=1`, followed by cosine
similarity. It is a transparent approximation, not a numerically identical
Node2Vec implementation. Embeddings are refreshed every `n` periods, matching
Ferrara's round-based recomputation. If exact replication of their N2V results
is required, the helper can later be connected to a MATLAB or Python Node2Vec
package without changing the simulation or output arrays.

## Outputs

The `.mat` output retains the main variables of `simu.m`, with the second
dimension indexing `algorithms`. In particular: `stat_time`, `stat_degrees`,
`stat_progress`, `stat_fairness_norm`, `stat_fairness_div`, `mean_time`,
`nzmean_time`, `mean_fairness_norm`, and `mean_fairness_div`.

Run `test_ferrara_algorithms.m` first for a quick smoke test.

## Shared simulation core

The dynamics themselves (draw an agent, get a recommendation, form the link
if acceptable, evict on overflow, track convergence/degrees/fairness) live
in `run_recommendation_dynamics.m`, used by every driver script below.
Calling it with no fixed links reproduces `simu.m`/`simu_ferrara.m` exactly
(verified bit-for-bit against the original inline dynamics, including for
the `PA_<alpha>` family).

## Configuration: fixed initial links (`simu_ferrara_fixed_init.m`)

Each agent has `n_init` fixed links that are present from t=0 and are
*never evicted*, **on top of** the basic choice problem. They are an
exogenous, pre-existing network: they do not use up any of the agent's
capacity (`cap` stays the number of *free* slots, so the total out-degree is
`cap + n_init`) and they are drawn outside the agent's acceptable set (and
never the agent itself), so every agent keeps the same `a` acceptable
objects and the same `cap` free slots whatever `n_init` is. `n_init` only
changes the network the algorithms see (in-degrees, paths, random walks,
embeddings), and the number of open choices is never affected.
`run_recommendation_dynamics.m` enforces this: it errors if a fixed link
coincides with an acceptable object, and the fairness benchmark
`micro_alloc(j) = sum_i acceptables(i,j) * caps(i) / |E_i|` is the same for
every `n_init` (so unfairness is comparable across `n_init`).

`generate_fixed_links.m` offers two designs (`fixed_modes` in the script,
one result file each):

- `'uniform'`: objects drawn uniformly among those outside the agent's
  acceptable set.
- `'correlated'`: with probability `corr` (the correlation of the
  preferences) the object is drawn from a common popular block, otherwise
  uniformly; i.e. the preference generator applied to the fixed links, so
  the pre-existing network has popular objects. The block is `a+1:2a`
  (right after the common set `1:a` of the preferences): the common set
  itself is acceptable to most agents at high correlation and so cannot be
  used for links outside the acceptable set. At `corr=0` this is the
  uniform design.

The fixed links are drawn from a private random stream (seed `mc+1e6`) and
nested in `n_init` (the links for `n_init` contain those for any smaller
`n_init`), so for a given replication the preferences and the dynamics'
random numbers are the same across `n_init` and across the two designs, and
`n_init=0` reproduces `simu_ferrara.m` bit for bit. The script sweeps
`n_init = [0 1 2 4 6 8]` (no longer limited by the capacity; at most
`m-a-1`) crossed with `corrs = [0 0.5]`, for every algorithm.

`run_recommendation_dynamics.m` reports two versions of the degree profile:

- `ave_degs`: total time-averaged in-degree, including the fixed
  contribution — use this to look at overall network characteristics.
- `ave_degs_free`: with the (constant) fixed contribution subtracted out —
  this is what is compared to the fairness benchmark.

Convergence time is the first time every agent's free slots are full.
Postprocess with `postprocess_simu_ferrara_fixed_init.m` (one set of figures
per design and correlation: convergence time and unfairness, the latter also
without the PA family and without PA and Two-hops).

## Configuration: real-network acceptable structure (`simu_ferrara_real_network.m`)

The acceptable links are read off a real network: SNAP soc-Slashdot0811
(77k nodes, 828k directed links) or soc-Pokec (1.6M nodes, 30.6M directed
links), selected with `dataset` at the top of the script. Download the raw
files with `download_snap_data('slashdot')` or `download_snap_data('pokec')`
(about 3 MB and 130 MB compressed); they live in `data/slashdot/` and
`data/pokec/`, and `load_snap_graph.m` parses them once
into a cached sparse matrix (`<dataset>_graph.mat`, later loads take under a
second). Each Monte Carlo replication is one real sample, not a draw from a
synthetic generator:

- a seed node is drawn reproducibly (`sample_seed`) among nodes of degree
  `>= seed_min_degree`, never from inside an earlier sample, so samples do
  not overlap;
- `snowball_sample.m` grows a connected sample of exactly `n_target` nodes by
  plain BFS/snowball sampling on the undirected graph, visiting each node's
  neighbours in random order (the last BFS layer is truncated at random);
- the observed directed links among the sampled nodes are the acceptable
  links (i finds j acceptable iff i links to j), so agents and objects are
  the same nodes, as Ferrara's algorithms need;
- the dynamics start from the empty network and are those of
  `simu_ferrara.m`, for every algorithm on every sample (same dynamics seed
  across algorithms).

`dataset`, `n_target` (sample size), `MC` (number of samples), `Tmax`,
`cap_frac`, `cap_max`, `seed_min_degree` and `sample_seed` are set at the top
of the script. Capacities are heterogeneous, from
`capacities_from_acceptables.m`: agent i keeps `cap_frac*|E_i|` links (at
least one, at most `cap_max`), so every agent with two or more acceptable
objects genuinely chooses among them (the paper's `a>cap` regime). A fixed
capacity of 3 would leave most agents with no choice, because BFS samples of
sparse social graphs are sparse. The fairness benchmark is the general
`sum_i 1{j in E_i} caps(i)/|E_i|`.

Postprocess with `postprocess_simu_ferrara_real_network.m` (set
`dataset_to_plot`, or leave it empty for the latest run). It plots
convergence time, convergence time relative to Uniform on the same sample
(samples differ a lot in size of the capacity to fill), and unfairness, and
prints sample descriptors, including the share of agents with a choice.

Caveats: plain BFS samples are sparse (density 0.03–0.05, mean `|E_i|` of
about 2–6 at `n_target=100`), so 30–70% of agents have a real choice, and
this varies a lot across samples. Larger `n_target` gives more choice but
slows PPR/WTF/N2V. Runtime is about 100 s per sample at `n_target=100` for
all ten algorithms. Convergence is slow relative to the synthetic runs
(up to ~65,000 steps in the tests), hence `Tmax=150000`. Other SNAP graphs
only need a new entry in `load_snap_graph.m` returning the same sparse
adjacency matrix.
