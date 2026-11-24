close all;
load('simus_n20_m20_mc25_a4_2hops_v2.mat');

%evolution of correlation as a function of preferential attachment 
figure(1)
hold on
plot(0.1*(0:10),squeeze(mean_time(:,1)),'LineWidth',2)
plot(0.1*(0:10),squeeze(mean_time(:,2)),'LineWidth',2)
plot(0.1*(0:10),squeeze(mean_time(:,3)),'LineWidth',2)
plot(0.1*(0:10),squeeze(mean_time(:,4)),'LineWidth',2)
plot(0.1*(0:10),squeeze(mean_time(:,5)),'LineWidth',2)
plot(0.1*(0:10),squeeze(mean_time(:,6)),'LineWidth',2)
xlabel('correlation of preferences')
ylabel('convergence time')
legend("alpha 0", "alpha 0.25", "alpha 0.5","alpha 0.75","alpha 1.0", "2 hops");
title("n=20, m=20, a=4")

% Set font size for labels and legend
xlabel('correlation of preferences', 'FontSize', 14)  % Increase font size of x label
ylabel('convergence time', 'FontSize', 14)  % Increase font size of y label
legend("alpha 0", "alpha 0.25", "alpha 0.5","alpha 0.75","alpha 1.0", "2 hops", 'FontSize', 12);  % Increase font size of legend
title("n=20, m=20, a=4", 'FontSize', 16)  % Increase font size of the title

% Optionally adjust the font size of ticks
ax = gca;
ax.FontSize = 12;  % Set font size for tick labels

print('-depsc', 'n20m20a4.eps')

figure(11)
hold on
plot(0.1*(0:10),squeeze(mean_fairness_div(:,1)),'LineWidth',2)
plot(0.1*(0:10),squeeze(mean_fairness_div(:,2)),'LineWidth',2)
plot(0.1*(0:10),squeeze(mean_fairness_div(:,3)),'LineWidth',2)
plot(0.1*(0:10),squeeze(mean_fairness_div(:,4)),'LineWidth',2)
plot(0.1*(0:10),squeeze(mean_fairness_div(:,5)),'LineWidth',2)
plot(0.1*(0:10),squeeze(mean_fairness_div(:,6)),'LineWidth',2)
xlabel('correlation of preferences')
ylabel('Unfairness (divergence wrt benchmark)')
legend("alpha 0", "alpha 0.25", "alpha 0.5","alpha 0.75","alpha 1.0", "2 hops");
title("n=20, m=20, a=4")

% Set font size for labels and legend
xlabel('correlation of preferences', 'FontSize', 14)  % Increase font size of x label
ylabel('Unfairness (divergence wrt benchmark)', 'FontSize', 14)  % Increase font size of y label
legend("alpha 0", "alpha 0.25", "alpha 0.5","alpha 0.75","alpha 1.0", "2 hops", 'FontSize', 12);  % Increase font size of legend
title("n=20, m=20, a=4", 'FontSize', 16)  % Increase font size of the title

% Optionally adjust the font size of ticks
ax = gca;
ax.FontSize = 12;  % Set font size for tick labels

print('-depsc', 'n20m20a4_div.eps')

figure(111)
hold on
plot(0.1*(0:10),squeeze(mean_fairness_norm(:,1)),'LineWidth',2)
plot(0.1*(0:10),squeeze(mean_fairness_norm(:,2)),'LineWidth',2)
plot(0.1*(0:10),squeeze(mean_fairness_norm(:,3)),'LineWidth',2)
plot(0.1*(0:10),squeeze(mean_fairness_norm(:,4)),'LineWidth',2)
plot(0.1*(0:10),squeeze(mean_fairness_norm(:,5)),'LineWidth',2)
plot(0.1*(0:10),squeeze(mean_fairness_norm(:,6)),'LineWidth',2)
xlabel('correlation of preferences')
ylabel('distance wrt benchmark')
legend("alpha 0", "alpha 0.25", "alpha 0.5","alpha 0.75","alpha 1.0", "2 hops");
title("n=20, m=20, a=4")

% Set font size for labels and legend
xlabel('correlation of preferences', 'FontSize', 14)  % Increase font size of x label
ylabel('distance wrt benchmark', 'FontSize', 14)  % Increase font size of y label
legend("alpha 0", "alpha 0.25", "alpha 0.5","alpha 0.75","alpha 1.0", "2 hops", 'FontSize', 12);  % Increase font size of legend
title("n=20, m=20, a=4", 'FontSize', 16)  % Increase font size of the title

% Optionally adjust the font size of ticks
ax = gca;
ax.FontSize = 12;  % Set font size for tick labels

print('-depsc', 'n20m20a4_dist.eps')




% 
% figure(11)
% hold on
% plot(0.1*(0:10),squeeze(mean_time(:,1)),'LineWidth',2)
% plot(0.1*(0:10),squeeze(mean_time(:,2)),'LineWidth',2)
% plot(0.1*(0:10),squeeze(mean_time(:,3)),'LineWidth',2)
% plot(0.1*(0:10),squeeze(mean_time(:,4)),'LineWidth',2)
% plot(0.1*(0:10),squeeze(mean_time(:,5)),'LineWidth',2)
% plot(0.1*(0:10),squeeze(mean_time(:,6)),'LineWidth',2)
% xlabel('correlation of preferences')
% ylabel('convergence time')
% legend("alpha 0", "alpha 0.25", "alpha 0.5","alpha 0.75","alpha 1.0", "2 hops");
% title("n=20, m=20, a=4")
% 
% % Set font size for labels and legend
% xlabel('correlation of preferences', 'FontSize', 14)  % Increase font size of x label
% ylabel('convergence time', 'FontSize', 14)  % Increase font size of y label
% legend("alpha 0", "alpha 0.25", "alpha 0.5","alpha 0.75","alpha 1.0", "2 hops", 'FontSize', 12);  % Increase font size of legend
% title("n=20, m=20, a=4", 'FontSize', 16)  % Increase font size of the title
% 
% % Optionally adjust the font size of ticks
% ax = gca;
% ax.FontSize = 12;  % Set font size for tick labels
% 
% print('-depsc', 'n20m20a4.eps')




load('simus_n20_m20_mc25_a10_2hops_v2.mat');

%evolution of correlation as a function of preferential attachment 
figure(2)
hold on
plot(0.1*(0:10),squeeze(mean_time(:,1)),'LineWidth',2)
plot(0.1*(0:10),squeeze(mean_time(:,2)),'LineWidth',2)
plot(0.1*(0:10),squeeze(mean_time(:,3)),'LineWidth',2)
plot(0.1*(0:10),squeeze(mean_time(:,4)),'LineWidth',2)
plot(0.1*(0:10),squeeze(mean_time(:,5)),'LineWidth',2)
plot(0.1*(0:10),squeeze(mean_time(:,6)),'LineWidth',2)

% Set font size for labels and legend
xlabel('correlation of preferences', 'FontSize', 14)  % Increase font size of x label
ylabel('convergence time', 'FontSize', 14)  % Increase font size of y label
legend("alpha 0", "alpha 0.25", "alpha 0.5","alpha 0.75","alpha 1.0", "2 hops", 'FontSize', 12);  % Increase font size of legend
title("n=20, m=20, a=10", 'FontSize', 16)  % Increase font size of the title

% Optionally adjust the font size of ticks
ax = gca;
ax.FontSize = 12;  % Set font size for tick labelsprint('-depsc', 'n20m20a10.eps')
print('-depsc', 'n20m20a10.eps')

figure(21)
hold on
plot(0.1*(0:10),squeeze(mean_fairness_div(:,1)),'LineWidth',2)
plot(0.1*(0:10),squeeze(mean_fairness_div(:,2)),'LineWidth',2)
plot(0.1*(0:10),squeeze(mean_fairness_div(:,3)),'LineWidth',2)
plot(0.1*(0:10),squeeze(mean_fairness_div(:,4)),'LineWidth',2)
plot(0.1*(0:10),squeeze(mean_fairness_div(:,5)),'LineWidth',2)
plot(0.1*(0:10),squeeze(mean_fairness_div(:,6)),'LineWidth',2)
xlabel('correlation of preferences')
ylabel('Unfairness (divergence wrt benchmark)')
legend("alpha 0", "alpha 0.25", "alpha 0.5","alpha 0.75","alpha 1.0", "2 hops");
title("n=20, m=20, a=10")

% Set font size for labels and legend
xlabel('correlation of preferences', 'FontSize', 14)  % Increase font size of x label
ylabel('Unfairness (divergence wrt benchmark)', 'FontSize', 14)  % Increase font size of y label
legend("alpha 0", "alpha 0.25", "alpha 0.5","alpha 0.75","alpha 1.0", "2 hops", 'FontSize', 12);  % Increase font size of legend
title("n=20, m=20, a=10", 'FontSize', 16)  % Increase font size of the title

% Optionally adjust the font size of ticks
ax = gca;
ax.FontSize = 12;  % Set font size for tick labels

print('-depsc', 'n20m20a10_div.eps')

load('simus_n200_m200_mc25_a4_2hops_v2.mat');

%evolution of correlation as a function of preferential attachment 
figure(3)
hold on
plot(0.1*(0:10),squeeze(mean_time(:,1)),'LineWidth',2)
plot(0.1*(0:10),squeeze(mean_time(:,2)),'LineWidth',2)
plot(0.1*(0:10),squeeze(mean_time(:,3)),'LineWidth',2)
plot(0.1*(0:10),squeeze(mean_time(:,4)),'LineWidth',2)
plot(0.1*(0:10),squeeze(mean_time(:,5)),'LineWidth',2)
plot(0.1*(0:10),squeeze(mean_time(:,6)),'LineWidth',2)

% Set font size for labels and legend
xlabel('correlation of preferences', 'FontSize', 14)  % Increase font size of x label
ylabel('convergence time', 'FontSize', 14)  % Increase font size of y label
legend("alpha 0", "alpha 0.25", "alpha 0.5","alpha 0.75","alpha 1.0", "2 hops", 'FontSize', 12);  % Increase font size of legend
title("n=200, m=200, a=4", 'FontSize', 16)  % Increase font size of the title

% Optionally adjust the font size of ticks
ax = gca;
ax.FontSize = 12;  % Set font size for tick labelsprint('-depsc', 'n20m20a10.eps')
print('-depsc', 'n200m200a4.eps')

figure(31)
hold on
plot(0.1*(0:10),squeeze(mean_fairness_div(:,1)),'LineWidth',2)
plot(0.1*(0:10),squeeze(mean_fairness_div(:,2)),'LineWidth',2)
plot(0.1*(0:10),squeeze(mean_fairness_div(:,3)),'LineWidth',2)
plot(0.1*(0:10),squeeze(mean_fairness_div(:,4)),'LineWidth',2)
plot(0.1*(0:10),squeeze(mean_fairness_div(:,5)),'LineWidth',2)
plot(0.1*(0:10),squeeze(mean_fairness_div(:,6)),'LineWidth',2)
xlabel('correlation of preferences')
ylabel('Unfairness (divergence wrt benchmark)')
legend("alpha 0", "alpha 0.25", "alpha 0.5","alpha 0.75","alpha 1.0", "2 hops");
title("n=200, m=200, a=4")

% Set font size for labels and legend
xlabel('correlation of preferences', 'FontSize', 14)  % Increase font size of x label
ylabel('Unfairness (divergence wrt benchmark)', 'FontSize', 14)  % Increase font size of y label
legend("alpha 0", "alpha 0.25", "alpha 0.5","alpha 0.75","alpha 1.0", "2 hops", 'FontSize', 12);  % Increase font size of legend
title("n=200, m=200, a=4", 'FontSize', 16)  % Increase font size of the title

% Optionally adjust the font size of ticks
ax = gca;
ax.FontSize = 12;  % Set font size for tick labels

print('-depsc', 'n200m200a4_div.eps')


load('simus_n200_m200_mc25_a10_2hops_v2.mat');

%evolution of correlation as a function of preferential attachment 
figure(4)
hold on
plot(0.1*(0:10),squeeze(mean_time(:,1)),'LineWidth',2)
plot(0.1*(0:10),squeeze(mean_time(:,2)),'LineWidth',2)
plot(0.1*(0:10),squeeze(mean_time(:,3)),'LineWidth',2)
plot(0.1*(0:10),squeeze(mean_time(:,4)),'LineWidth',2)
plot(0.1*(0:10),squeeze(mean_time(:,5)),'LineWidth',2)
plot(0.1*(0:10),squeeze(mean_time(:,6)),'LineWidth',2)

% Set font size for labels and legend
xlabel('correlation of preferences', 'FontSize', 14)  % Increase font size of x label
ylabel('convergence time', 'FontSize', 14)  % Increase font size of y label
legend("alpha 0", "alpha 0.25", "alpha 0.5","alpha 0.75","alpha 1.0", "2 hops", 'FontSize', 12);  % Increase font size of legend
title("n=200, m=200, a=10", 'FontSize', 16)  % Increase font size of the title

% Optionally adjust the font size of ticks
ax = gca;
ax.FontSize = 12;  % Set font size for tick labelsprint('-depsc', 'n20m20a10.eps')
print('-depsc', 'n200m200a10.eps')


figure(41)
hold on
plot(0.1*(0:10),squeeze(mean_fairness_div(:,1)),'LineWidth',2)
plot(0.1*(0:10),squeeze(mean_fairness_div(:,2)),'LineWidth',2)
plot(0.1*(0:10),squeeze(mean_fairness_div(:,3)),'LineWidth',2)
plot(0.1*(0:10),squeeze(mean_fairness_div(:,4)),'LineWidth',2)
plot(0.1*(0:10),squeeze(mean_fairness_div(:,5)),'LineWidth',2)
plot(0.1*(0:10),squeeze(mean_fairness_div(:,6)),'LineWidth',2)
xlabel('correlation of preferences')
ylabel('Unfairness (divergence wrt benchmark)')
legend("alpha 0", "alpha 0.25", "alpha 0.5","alpha 0.75","alpha 1.0", "2 hops");
title("n=200, m=200, a=10")

% Set font size for labels and legend
xlabel('correlation of preferences', 'FontSize', 14)  % Increase font size of x label
ylabel('Unfairness (divergence wrt benchmark)', 'FontSize', 14)  % Increase font size of y label
legend("alpha 0", "alpha 0.25", "alpha 0.5","alpha 0.75","alpha 1.0", "2 hops", 'FontSize', 12);  % Increase font size of legend
title("n=200, m=200, a=10", 'FontSize', 16)  % Increase font size of the title

% Optionally adjust the font size of ticks
ax = gca;
ax.FontSize = 12;  % Set font size for tick labels

print('-depsc', 'n200m200a10_div.eps')

load('simus_n200_m400_mc25_a10_v2.mat');

%evolution of correlation as a function of preferential attachment 
figure(6)
hold on
plot(0.1*(0:10),squeeze(mean_time(:,1)),'LineWidth',2)
plot(0.1*(0:10),squeeze(mean_time(:,2)),'LineWidth',2)
plot(0.1*(0:10),squeeze(mean_time(:,3)),'LineWidth',2)
plot(0.1*(0:10),squeeze(mean_time(:,4)),'LineWidth',2)
plot(0.1*(0:10),squeeze(mean_time(:,5)),'LineWidth',2)

% Set font size for labels and legend
xlabel('correlation of preferences', 'FontSize', 14)  % Increase font size of x label
ylabel('convergence time', 'FontSize', 14)  % Increase font size of y label
legend("alpha 0", "alpha 0.25", "alpha 0.5","alpha 0.75","alpha 1.0", "2 hops", 'FontSize', 12);  % Increase font size of legend
title("n=200, m=400, a=10", 'FontSize', 16)  % Increase font size of the title

% Optionally adjust the font size of ticks
ax = gca;
ax.FontSize = 12;  % Set font size for tick labelsprint('-depsc', 'n20m20a10.eps')
print('-depsc', 'n200m400a10.eps')

load('simus_n200_m200_mc25_a10_allhops_v2.mat');


figure(7)
hold on

plot(0.1*(0:10),squeeze(mean_time(:,1)),'LineWidth',2)
plot(0.1*(0:10),squeeze(mean_time(:,2)),'LineWidth',2)
plot(0.1*(0:10),squeeze(mean_time(:,3)),'LineWidth',2)
plot(0.1*(0:10),squeeze(mean_time(:,4)),'LineWidth',2)
plot(0.1*(0:10),squeeze(mean_time(:,5)),'LineWidth',2)
xlabel('correlation of preferences')
ylabel('convergence time')

% Set font size for labels and legend
xlabel('correlation of preferences', 'FontSize', 14)  % Increase font size of x label
ylabel('convergence time', 'FontSize', 14)  % Increase font size of y label
legend("alpha 0", "alpha 1", "2 hops", "3 hops", "5 hops", 'FontSize', 12);  % Increase font size of legend
title("n=200, m=200, a=10", 'FontSize', 16)  % Increase font size of the title

% Optionally adjust the font size of ticks
ax = gca;
ax.FontSize = 12;  % Set font size for tick labelsprint('-depsc', 'n20m20a10.eps')
print('-depsc', 'n200m200a10_hops.eps')



figure(70)
hold on

plot(0.1*(0:10),squeeze(mean_fairness_div(:,1)),'LineWidth',2)
plot(0.1*(0:10),squeeze(mean_fairness_div(:,2)),'LineWidth',2)
plot(0.1*(0:10),squeeze(mean_fairness_div(:,3)),'LineWidth',2)
plot(0.1*(0:10),squeeze(mean_fairness_div(:,4)),'LineWidth',2)
plot(0.1*(0:10),squeeze(mean_fairness_div(:,5)),'LineWidth',2)
xlabel('correlation of preferences')
ylabel('Unfairness (divergence wrt benchmark)', 'FontSize', 14)  % Increase font size of y label

% Set font size for labels and legend
xlabel('correlation of preferences', 'FontSize', 14)  % Increase font size of x label
ylabel('Unfairness (divergence wrt benchmark)', 'FontSize', 14)  % Increase font size of y label
legend("alpha 0", "alpha 1", "2 hops", "3 hops", "5 hops", 'FontSize', 12);  % Increase font size of legend
title("n=200, m=200, a=10", 'FontSize', 16)  % Increase font size of the title

% Optionally adjust the font size of ticks
ax = gca;
ax.FontSize = 12;  % Set font size for tick labelsprint('-depsc', 'n20m20a10.eps')
print('-depsc', 'n200m200a10_hops_div.eps')



load('simus_n20_m20_mc25_a10_allhops_v2.mat');

figure(8)
hold on

plot(0.1*(0:10),squeeze(mean_time(:,1)),'LineWidth',2)
plot(0.1*(0:10),squeeze(mean_time(:,2)),'LineWidth',2)
plot(0.1*(0:10),squeeze(mean_time(:,3)),'LineWidth',2)
plot(0.1*(0:10),squeeze(mean_time(:,4)),'LineWidth',2)
plot(0.1*(0:10),squeeze(mean_time(:,5)),'LineWidth',2)
xlabel('correlation of preferences')
ylabel('convergence time')

% Set font size for labels and legend
xlabel('correlation of preferences', 'FontSize', 14)  % Increase font size of x label
ylabel('convergence time', 'FontSize', 14)  % Increase font size of y label
legend("alpha 0", "alpha 1", "2 hops", "3 hops", "5 hops", 'FontSize', 12);  % Increase font size of legend
title("n=20, m=20, a=10", 'FontSize', 16)  % Increase font size of the title

% Optionally adjust the font size of ticks
ax = gca;
ax.FontSize = 12;  % Set font size for tick labelsprint('-depsc', 'n20m20a10.eps')
print('-depsc', 'n20m20a10_hops.eps')


load('simus_n20_m20_mc25_a10_allhops_v2.mat');

figure(80)
hold on

plot(0.1*(0:10),squeeze(mean_fairness_div(:,1)),'LineWidth',2)
plot(0.1*(0:10),squeeze(mean_fairness_div(:,2)),'LineWidth',2)
plot(0.1*(0:10),squeeze(mean_fairness_div(:,3)),'LineWidth',2)
plot(0.1*(0:10),squeeze(mean_fairness_div(:,4)),'LineWidth',2)
plot(0.1*(0:10),squeeze(mean_fairness_div(:,5)),'LineWidth',2)
xlabel('correlation of preferences')
ylabel('Unfairness (divergence wrt benchmark)', 'FontSize', 14)  % Increase font size of y label

% Set font size for labels and legend
xlabel('correlation of preferences', 'FontSize', 14)  % Increase font size of x label
ylabel('Unfairness (divergence wrt benchmark)', 'FontSize', 14)  % Increase font size of y label
legend("alpha 0", "alpha 1", "2 hops", "3 hops", "5 hops", 'FontSize', 12);  % Increase font size of legend
title("n=20, m=20, a=10", 'FontSize', 16)  % Increase font size of the title

% Optionally adjust the font size of ticks
ax = gca;
ax.FontSize = 12;  % Set font size for tick labelsprint('-depsc', 'n20m20a10.eps')
print('-depsc', 'n20m20a10_hops_div.eps')


load('simus_n200_m200_mc25_a4_allhops_v2.mat');



figure(9)
hold on

plot(0.1*(0:10),squeeze(mean_time(:,1)),'LineWidth',2)
plot(0.1*(0:10),squeeze(mean_time(:,2)),'LineWidth',2)
plot(0.1*(0:10),squeeze(mean_time(:,3)),'LineWidth',2)
plot(0.1*(0:10),squeeze(mean_time(:,4)),'LineWidth',2)
plot(0.1*(0:10),squeeze(mean_time(:,5)),'LineWidth',2)
xlabel('correlation of preferences')
ylabel('convergence time')

% Set font size for labels and legend
xlabel('correlation of preferences', 'FontSize', 14)  % Increase font size of x label
ylabel('convergence time', 'FontSize', 14)  % Increase font size of y label
legend("alpha 0", "alpha 1", "2 hops", "3 hops", "5 hops", 'FontSize', 12);  % Increase font size of legend
title("n=200, m=200, a=4", 'FontSize', 16)  % Increase font size of the title

% Optionally adjust the font size of ticks
ax = gca;
ax.FontSize = 12;  % Set font size for tick labelsprint('-depsc', 'n20m20a10.eps')
print('-depsc', 'n200m200a4_hops.eps')

figure(90)
hold on

plot(0.1*(0:10),squeeze(mean_fairness_div(:,1)),'LineWidth',2)
plot(0.1*(0:10),squeeze(mean_fairness_div(:,2)),'LineWidth',2)
plot(0.1*(0:10),squeeze(mean_fairness_div(:,3)),'LineWidth',2)
plot(0.1*(0:10),squeeze(mean_fairness_div(:,4)),'LineWidth',2)
plot(0.1*(0:10),squeeze(mean_fairness_div(:,5)),'LineWidth',2)
xlabel('correlation of preferences')
ylabel('Unfairness (divergence wrt benchmark)', 'FontSize', 14)  % Increase font size of y label

% Set font size for labels and legend
xlabel('correlation of preferences', 'FontSize', 14)  % Increase font size of x label
ylabel('Unfairness (divergence wrt benchmark)', 'FontSize', 14)  % Increase font size of y label
legend("alpha 0", "alpha 1", "2 hops", "3 hops", "5 hops", 'FontSize', 12);  % Increase font size of legend
title("n=200, m=200, a=4", 'FontSize', 16)  % Increase font size of the title

% Optionally adjust the font size of ticks
ax = gca;
ax.FontSize = 12;  % Set font size for tick labelsprint('-depsc', 'n20m20a10.eps')
print('-depsc', 'n200m200a4_hops_div.eps')




load('simus_n20_m20_mc25_a4_allhops_v2.mat');



figure(10)
hold on

plot(0.1*(0:10),squeeze(mean_time(:,1)),'LineWidth',2)
plot(0.1*(0:10),squeeze(mean_time(:,2)),'LineWidth',2)
plot(0.1*(0:10),squeeze(mean_time(:,3)),'LineWidth',2)
plot(0.1*(0:10),squeeze(mean_time(:,4)),'LineWidth',2)
plot(0.1*(0:10),squeeze(mean_time(:,5)),'LineWidth',2)
xlabel('correlation of preferences')
ylabel('convergence time')

% Set font size for labels and legend
xlabel('correlation of preferences', 'FontSize', 14)  % Increase font size of x label
ylabel('convergence time', 'FontSize', 14)  % Increase font size of y label
legend("alpha 0", "alpha 1", "2 hops", "3 hops", "5 hops", 'FontSize', 12);  % Increase font size of legend
title("n=20, m=20, a=4", 'FontSize', 16)  % Increase font size of the title

% Optionally adjust the font size of ticks
ax = gca;
ax.FontSize = 12;  % Set font size for tick labelsprint('-depsc', 'n20m20a10.eps')
print('-depsc', 'n20m20a4_hops.eps')


figure(110)
hold on

plot(0.1*(0:10),squeeze(mean_fairness_div(:,1)),'LineWidth',2)
plot(0.1*(0:10),squeeze(mean_fairness_div(:,2)),'LineWidth',2)
plot(0.1*(0:10),squeeze(mean_fairness_div(:,3)),'LineWidth',2)
plot(0.1*(0:10),squeeze(mean_fairness_div(:,4)),'LineWidth',2)
plot(0.1*(0:10),squeeze(mean_fairness_div(:,5)),'LineWidth',2)
xlabel('correlation of preferences')
ylabel('Unfairness (divergence wrt benchmark)', 'FontSize', 14)  % Increase font size of y label

% Set font size for labels and legend
xlabel('correlation of preferences', 'FontSize', 14)  % Increase font size of x label
ylabel('Unfairness (divergence wrt benchmark)', 'FontSize', 14)  % Increase font size of y label
legend("alpha 0", "alpha 1", "2 hops", "3 hops", "5 hops", 'FontSize', 12);  % Increase font size of legend
title("n=20, m=20, a=4", 'FontSize', 16)  % Increase font size of the title

% Optionally adjust the font size of ticks
ax = gca;
ax.FontSize = 12;  % Set font size for tick labelsprint('-depsc', 'n20m20a10.eps')
print('-depsc', 'n20m20a4_hops_div.eps')



% load('simus_n200_m400_mc25_a4_v2.mat');
% 
% %evolution of correlation as a function of preferential attachment 
% figure(5)
% hold on
% plot(0.1*(0:10),squeeze(mean_time(:,1)),'LineWidth',2)
% plot(0.1*(0:10),squeeze(mean_time(:,2)),'LineWidth',2)
% plot(0.1*(0:10),squeeze(mean_time(:,3)),'LineWidth',2)
% plot(0.1*(0:10),squeeze(mean_time(:,4)),'LineWidth',2)
% plot(0.1*(0:10),squeeze(mean_time(:,5)),'LineWidth',2)
% xlabel('correlation of preferences')
% ylabel('convergence time')
% legend("alpha 0", "alpha 0.25", "alpha 0.5","alpha 0.75","alpha 1.0");

 


% 
% %evolution of correlation as a function of preferential attachment 
% figure(32)
% hold on
% plot(0.1*(0:10),squeeze(mean_time(:,1)),'LineWidth',2)
% plot(0.1*(0:10),squeeze(mean_time(:,2)),'LineWidth',2)
% plot(0.1*(0:10),squeeze(mean_time(:,3)),'LineWidth',2)
% plot(0.1*(0:10),squeeze(mean_time(:,4)),'LineWidth',2)
% plot(0.1*(0:10),squeeze(mean_time(:,5)),'LineWidth',2)
% xlabel('correlation of preferences')
% ylabel('convergence time')
% legend("alpha 0", "alpha 0.25", "alpha 0.5","alpha 0.75","alpha 1.0");
% 
% 
% % Create a logical array to identify non-zero elements
% non_zero_mask = stat_time ~= 0;
% 
% % Compute the sum of non-zero elements over the third dimension
% sum_nonzero = sum(stat_time .* non_zero_mask, 3);
% 
% % Count the number of non-zero elements over the third dimension
% count_nonzero = sum(non_zero_mask, 3);
% 
% % Calculate the mean of non-zero elements
% mean_nonzero = sum_nonzero ./ count_nonzero;
% 
% % Handle cases where there are no non-zero elements to avoid NaNs
% mean_nonzero(count_nonzero == 0) = 0;
% 
% mean_time2=mean_nonzero;
% 
% %evolution of correlation as a function of preferential attachment 
% figure(33)
% hold on
% plot(0.1*(0:10),squeeze(mean_time2(:,1)),'LineWidth',2)
% plot(0.1*(0:10),squeeze(mean_time2(:,2)),'LineWidth',2)
% plot(0.1*(0:10),squeeze(mean_time2(:,3)),'LineWidth',2)
% plot(0.1*(0:10),squeeze(mean_time2(:,4)),'LineWidth',2)
% plot(0.1*(0:10),squeeze(mean_time2(:,5)),'LineWidth',2)
% xlabel('correlation of preferences')
% ylabel('convergence time')
% legend("alpha 0", "alpha 0.25", "alpha 0.5","alpha 0.75","alpha 1.0");
