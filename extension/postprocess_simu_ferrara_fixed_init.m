% POSTPROCESS_SIMU_FERRARA_FIXED_INIT
% For each design of the fixed links ('uniform', 'correlated') and each
% correlation level, separate figures with the number of fixed links per
% agent (n_init) on the x-axis and one line per algorithm:
%   - mean convergence time (average over the Monte Carlo samples that
%     converged), and
%   - unfairness of the free links against the free-capacity benchmark
%     (mean over samples of the divergence between the time-averaged
%     in-degrees of the free links and the proportional benchmark), for all
%     algorithms, without the PA family, and without the PA family and
%     Two-hops.
% Files: ferrara_fixed_init_<mode>_{convergence_time,unfairness,
%        unfairness_noPA,unfairness_noPA_no2H}_corr<c>.eps
% Uses the latest simus_ferrara_fixed_init_<mode>_*.mat of each design.
% Styled like the figures of postprocess_simu.m (no grid, legend inside).
close all;

modes_to_plot = {'uniform','correlated'};

% 10 distinct colours (lines() only has 7 before it repeats)
colors = [lines(7); 0.5 0.5 0.5; 0 0 0; 0.85 0.4 0.7];

for pm = 1:numel(modes_to_plot)
    mode_name = modes_to_plot{pm};
    files = dir(sprintf('simus_ferrara_fixed_init_%s_*.mat',mode_name));
    assert(~isempty(files),'No simus_ferrara_fixed_init_%s_*.mat file found in the current folder.',mode_name);
    [~,latest] = max([files.datenum]);
    fprintf('Loading %s\n',files(latest).name);
    load(files(latest).name);

    for ix = 1:n_corrs
        ctag = sprintf('corr%g',corrs(ix));
        ttl = {sprintf('n=%d, m=%d, a=%d, correlation=%g',n,m,a,corrs(ix)), ...
            sprintf('%s fixed links',mode_name)};

        figure; hold on;
        for jx = 1:n_algorithms
            plot(n_inits,squeeze(nzmean_time(:,ix,jx)),'-o','LineWidth',2, ...
                'MarkerSize',5,'Color',colors(jx,:));
        end
        xlabel('fixed links per agent','FontSize',14);
        ylabel('convergence time','FontSize',14);
        title(ttl,'FontSize',16);
        set(gca,'XTick',n_inits,'FontSize',12);
        yl = ylim; ylim([yl(1) yl(1)+1.45*(yl(2)-yl(1))]);   % headroom for the legend
        legend(algorithm_labels,'FontSize',10,'Location','north','NumColumns',2);
        print(gcf,'-depsc',sprintf('ferrara_fixed_init_%s_convergence_time_%s.eps',mode_name,ctag));

        % Unfairness: all algorithms, then without the PA family, then without
        % the PA family and Two-hops (see postprocess_simu_ferrara.m).
        for v = 1:3
            if v == 1
                keep = true(1,n_algorithms);  vtag = 'unfairness';  headroom = 1.45;
            elseif v == 2
                keep = ~startsWith(algorithms,'PA');  vtag = 'unfairness_noPA';  headroom = 1.35;
            else
                keep = ~startsWith(algorithms,'PA') & ~strcmp(algorithms,'2H');
                vtag = 'unfairness_noPA_no2H';  headroom = 1.35;
            end
            figure; hold on;
            for jx = find(keep)
                plot(n_inits,squeeze(mean_fairness_div(:,ix,jx)),'-o','LineWidth',2, ...
                    'MarkerSize',5,'Color',colors(jx,:));
            end
            xlabel('fixed links per agent','FontSize',14);
            ylabel('Unfairness (divergence wrt benchmark)','FontSize',14);
            title(ttl,'FontSize',16);
            set(gca,'XTick',n_inits,'FontSize',12);
            yl = ylim; ylim([yl(1) yl(1)+headroom*(yl(2)-yl(1))]);   % headroom for the legend
            legend(algorithm_labels(keep),'FontSize',10,'Location','north','NumColumns',2);
            print(gcf,'-depsc',sprintf('ferrara_fixed_init_%s_%s_%s.eps',mode_name,vtag,ctag));
        end
        close all;
    end
    fprintf('  non-converged runs: %d of %d\n',sum(stat_time(:) == 0),numel(stat_time));
end
