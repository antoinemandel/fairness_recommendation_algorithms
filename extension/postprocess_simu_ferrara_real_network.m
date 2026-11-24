% POSTPROCESS_SIMU_FERRARA_REAL_NETWORK
% Compares algorithms across the real samples. Samples differ a lot in
% density and size of the capacity to fill, so besides raw means we also show
% each algorithm's convergence time relative to Uniform on the same sample.
close all;

% Set dataset_to_plot to 'slashdot' or 'pokec' to pick a dataset; the default
% (empty) plots the most recently generated real-network simulation.
if ~exist('dataset_to_plot','var'), dataset_to_plot = ''; end

pattern = 'simus_ferrara_real_*.mat';
if ~isempty(dataset_to_plot)
    pattern = sprintf('simus_ferrara_real_%s_*.mat',dataset_to_plot);
end
files = dir(pattern);
assert(~isempty(files),'No %s file found in the current folder.',pattern);
[~,latest] = max([files.datenum]);
fprintf('Loading %s\n',files(latest).name);
load(files(latest).name);

% 10 distinct colours (lines() only has 7 before it repeats)
colors = [lines(7); 0.5 0.5 0.5; 0 0 0; 0.85 0.4 0.7];
x = 1:n_algorithms;
un = find(strcmp(algorithms,'UN'));
conv = stat_time > 0;

% Raw convergence time (mean over converged samples, +/- s.e.m.)
figure(1); hold on;
for jx = 1:n_algorithms
    t = stat_time(jx,conv(jx,:));
    bar(jx,mean(t),'FaceColor',colors(jx,:));
    errorbar(jx,mean(t),std(t)/sqrt(numel(t)),'k','LineWidth',1.2);
    plot(jx*ones(size(t)),t,'k.','MarkerSize',10);
end
set(gca,'XTick',x,'XTickLabel',algorithm_labels,'XTickLabelRotation',35,'FontSize',12);
ylabel('Convergence time','FontSize',14);
title(sprintf('%s BFS samples: n=%d, %d samples',dataset,n_target,MC),'FontSize',16);
print(gcf,'-depsc',sprintf('ferrara_real_%s_convergence_time.eps',dataset));

% Convergence time relative to Uniform on the same sample
figure(2); hold on;
for jx = 1:n_algorithms
    ok = conv(jx,:) & conv(un,:);
    r = stat_time(jx,ok)./stat_time(un,ok);
    bar(jx,mean(r),'FaceColor',colors(jx,:));
    errorbar(jx,mean(r),std(r)/sqrt(numel(r)),'k','LineWidth',1.2);
    plot(jx*ones(size(r)),r,'k.','MarkerSize',10);
end
yline(1,'k--');
set(gca,'XTick',x,'XTickLabel',algorithm_labels,'XTickLabelRotation',35,'FontSize',12);
ylabel('Convergence time / Uniform (same sample)','FontSize',14);
title('Relative speed (below 1 = faster than Uniform)','FontSize',16);
print(gcf,'-depsc',sprintf('ferrara_real_%s_relative_time.eps',dataset));

% Unfairness
figure(3); hold on;
for jx = 1:n_algorithms
    f = stat_fairness_div(jx,conv(jx,:));
    bar(jx,mean(f),'FaceColor',colors(jx,:));
    errorbar(jx,mean(f),std(f)/sqrt(numel(f)),'k','LineWidth',1.2);
    plot(jx*ones(size(f)),f,'k.','MarkerSize',10);
end
set(gca,'XTick',x,'XTickLabel',algorithm_labels,'XTickLabelRotation',35,'FontSize',12);
ylabel('Unfairness relative to benchmark','FontSize',14);
title(sprintf('Unfairness on %s samples',dataset),'FontSize',16);
print(gcf,'-depsc',sprintf('ferrara_real_%s_unfairness.eps',dataset));

% Unfairness without the PA family, and without the PA family and Two-hops
for v = 1:2
    if v == 1
        keep = find(~startsWith(algorithms,'PA'));  vtag = 'noPA';  vtitle = 'without PA';
    else
        keep = find(~startsWith(algorithms,'PA') & ~strcmp(algorithms,'2H'));
        vtag = 'noPA_no2H';  vtitle = 'without PA and Two-hops';
    end
    figure(3+v); hold on;
    for k = 1:numel(keep)
        jx = keep(k);
        f = stat_fairness_div(jx,conv(jx,:));
        bar(k,mean(f),'FaceColor',colors(jx,:));
        errorbar(k,mean(f),std(f)/sqrt(numel(f)),'k','LineWidth',1.2);
        plot(k*ones(size(f)),f,'k.','MarkerSize',10);
    end
    set(gca,'XTick',1:numel(keep),'XTickLabel',algorithm_labels(keep),'XTickLabelRotation',35,'FontSize',12);
    ylabel('Unfairness relative to benchmark','FontSize',14);
    title(sprintf('Unfairness on %s samples (%s)',dataset,vtitle),'FontSize',16);
    print(gcf,'-depsc',sprintf('ferrara_real_%s_unfairness_%s.eps',dataset,vtag));
end

fprintf(['\nSample descriptors (mean over samples): links %.0f, density %.3f, reciprocity %.2f, ', ...
    'mean |E_i| %.1f, agents with a choice %.0f%%, in-degree Gini %.2f\n'], ...
    mean(sample_n_links),mean(sample_density),mean(sample_reciprocity),mean(sample_mean_E), ...
    100*mean(sample_frac_choice),mean(sample_indeg_gini));
fprintf('Non-converged runs: %d of %d\n',sum(~conv(:)),numel(conv));
