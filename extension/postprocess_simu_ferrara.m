% POSTPROCESS_SIMU_FERRARA Plot convergence and unfairness for all methods,
% one pair of figures per configuration file produced by simu_ferrara.m.
% Styled like the figures of postprocess_simu.m (no grid, legend inside the
% axes, same labels and font sizes, written with print -depsc).
close all;

% Only files with this number of Monte Carlo replications are plotted, so
% that older preliminary runs (e.g. MC=10) in the folder are ignored.
mc_to_plot = 25;

files = dir(sprintf('simus_ferrara_n*_m*_mc%d_a*.mat',mc_to_plot));
assert(~isempty(files),'No simus_ferrara_n*_m*_mc%d_a*.mat file found in the current folder.',mc_to_plot);

for f = 1:numel(files)
    fprintf('Loading %s\n',files(f).name);
    S = load(files(f).name);
    % 10 distinct colours (lines() only has 7 before it repeats)
    colors = [lines(7); 0.5 0.5 0.5; 0 0 0; 0.85 0.4 0.7];
    tag = sprintf('n%d_a%d',S.n,S.a);

    figure(2*f-1);
    hold on;
    for jx = 1:S.n_algorithms
        plot(S.corrs,S.nzmean_time(:,jx),'LineWidth',2,'Color',colors(jx,:));
    end
    xlabel('correlation of preferences','FontSize',14);
    ylabel('convergence time','FontSize',14);
    yl = ylim; ylim([yl(1) yl(1)+1.45*(yl(2)-yl(1))]);   % headroom for the legend
    legend(S.algorithm_labels,'FontSize',10,'Location','north','NumColumns',2);
    title(sprintf('n=%d, m=%d, a=%d',S.n,S.m,S.a),'FontSize',16);
    set(gca,'FontSize',12);
    print(gcf,'-depsc',sprintf('ferrara_convergence_time_%s.eps',tag));

    figure(2*f);
    hold on;
    for jx = 1:S.n_algorithms
        plot(S.corrs,S.mean_fairness_div(:,jx),'LineWidth',2,'Color',colors(jx,:));
    end
    xlabel('correlation of preferences','FontSize',14);
    ylabel('Unfairness (divergence wrt benchmark)','FontSize',14);
    yl = ylim; ylim([yl(1) yl(1)+1.45*(yl(2)-yl(1))]);   % headroom for the legend
    legend(S.algorithm_labels,'FontSize',10,'Location','north','NumColumns',2);
    title(sprintf('n=%d, m=%d, a=%d',S.n,S.m,S.a),'FontSize',16);
    set(gca,'FontSize',12);
    print(gcf,'-depsc',sprintf('ferrara_unfairness_%s.eps',tag));

    % Same unfairness plot without the PA family (whose values are so large
    % that they flatten the differences among the other algorithms), and
    % without the PA family and Two-hops.
    for v = 1:2
        if v == 1
            keep = ~startsWith(S.algorithms,'PA');  vtag = 'noPA';
        else
            keep = ~startsWith(S.algorithms,'PA') & ~strcmp(S.algorithms,'2H');  vtag = 'noPA_no2H';
        end
        figure(100*v+f);
        hold on;
        for jx = find(keep)
            plot(S.corrs,S.mean_fairness_div(:,jx),'LineWidth',2,'Color',colors(jx,:));
        end
        xlabel('correlation of preferences','FontSize',14);
        ylabel('Unfairness (divergence wrt benchmark)','FontSize',14);
        yl = ylim; ylim([yl(1) yl(1)+1.35*(yl(2)-yl(1))]);   % headroom for the legend
        legend(S.algorithm_labels(keep),'FontSize',10,'Location','north','NumColumns',2);
        title(sprintf('n=%d, m=%d, a=%d',S.n,S.m,S.a),'FontSize',16);
        set(gca,'FontSize',12);
        print(gcf,'-depsc',sprintf('ferrara_unfairness_%s_%s.eps',vtag,tag));
    end

    fprintf('  non-converged runs: %d of %d\n',sum(S.stat_time(:) == 0),numel(S.stat_time));
end
