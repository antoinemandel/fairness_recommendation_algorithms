% given the values of n: number of agents, m: number of potential choices (m=n for a social network),
% a: number of acceptable choices per agent, c in [0,1]: level of correlation, the
% script generates and n x m matrix "acceptables" with coeff  (i,j) =1 if and only if j is acceptable for i
% such that for a=0 choices are independent and for a=1 choices are fully
% correlated.
tic;
clear all;

% nb agents
n=20;
%nb objects
m=20;
%computation of shapley_value (impossible for large m)
is_shapley=0;
is_macrobank=0;
is_microbank=1;

%nb of admissible objects per agent
a=4;

%nb of MCS
MC=25;

file_name='simus_n20_m20_mc25_a4_allhops_v2.mat';


%link capacity
cap=3;
assert(a>cap);
caps=cap*ones(n,1);

% parameter to make the recommendation algorithm ergodic. 
epsilon=1;

%maximum time horizon 
Tmax=500000;

corrs=0.1*(0:10);
%corrs= 0.2*(0:5);
%corrs= 0.2;
n_corrs=length(corrs);

%alpha=2 is for 2 hops, 3 for 3 hops....  
alphas=[0 1 2 3 5];
n_alphas=length(alphas);



dist_shapley=zeros(n_corrs,n_alphas,MC,1);
dist_talmud=zeros(n_corrs,n_alphas,MC,1);
dist_prop=zeros(n_corrs,n_alphas,MC,1);
stat_degrees=zeros(n_corrs,n_alphas,MC,m);
stat_talmud=zeros(n_corrs,n_alphas,MC,m);
stat_corr=zeros(n_corrs,n_alphas,MC,1);
stat_alpha=zeros(n_corrs,n_alphas,MC,1);
stat_seed=zeros(n_corrs,n_alphas,MC,1);
stat_time=zeros(n_corrs,n_alphas,MC,1);
stat_progress=zeros(n_corrs,n_alphas,MC,1);
stat_fairness_norm=zeros(n_corrs,n_alphas,MC,1);
stat_fairness_div=zeros(n_corrs,n_alphas,MC,1);

if is_shapley
    stat_shapley=zeros(n_corrs,n_alphas,MC,m);
end


for ix=1:n_corrs
    corr=corrs(ix);
    for jx=1:n_alphas
        disp(ix);
        disp(jx);
        alpha=alphas(jx);
        for mc=1:MC
                % set random seed for reproducibility;
                seed=mc;
                rng(seed) 
                %generate preference profile
                % if choices are fully correlated, each agent only accepts 1,2,3,...a.
                % otherwise agents mix between random draw with probability c and a choice
                % among  1,2,3,...a with probability (1-c)
                
                % acceptables(i,j)=1 if and only if j is acceptable for i
                acceptables=zeros(n,m);
                
                for i=1:n
                    rand_urn=(1:m);
                    corr_urn=(1:a);
                    for j=1:a
                        if rand <corr % with probability c, draw from the fixed set of potential choices in (1:a) 
                            %draw a random link in the correlated urn 
                            aux_draw=corr_urn(randi(length(corr_urn)));
                            %remove the link drawn from the urn
                            corr_urn=corr_urn(corr_urn~=aux_draw);
                            %also remove from the rand_urn because object can't be selected twice
                            rand_urn=rand_urn(rand_urn~=aux_draw);
                            acceptables(i,aux_draw)=1;
                            
                        else % with probability 1-c, draw from the whole set of potential choices in (1:m) 
                            aux_draw=rand_urn(randi(length(rand_urn)));
                            %remove the link drawn from the urn
                            rand_urn=rand_urn(rand_urn~=aux_draw);
                            %also remove from the corr_urn because object can't be selected twice
                            corr_urn=corr_urn(corr_urn~=aux_draw);
                            acceptables(i,aux_draw)=1;
                        end
                    end
                end
                
                %game-theoretic solutions
                % Only needed for is_shapley=1 or is_macrobank=1 (both off for the paper's
                % results): add the MatTuGames toolbox (mat_tugames folder) to the MATLAB path.
                debts=sum(acceptables,1);
                estate=sum(caps);
                if is_microbank
                    micro_alloc=(cap/a)*debts;
                elseif is_macrobank
                    talmud_alloc=Talmudic_Rule(estate,debts);
                    prop_alloc=(sum(debts)/estate)*debts; 
                elseif is_shapley
                    game=bankruptcy_game(estate,debts);
                    shapley_alloc=ShapleyValue(game);
                end
                    
                
                %initialization convergence time
                Tconv=0;
                %initialization of the network
                %net=zeros(n,m);         
                %use sparse for hops type algorithm is faster
                net=sparse(n,m);
                
                %average degree of each object in the stationary distribution 
                ave_degs=zeros(1,m);
                progress=zeros(Tmax,1);
                for t=1:Tmax
                    progress(t)=sum(net,'all')/sum(caps,'all');
                %     if mod(t,1000)==0
                %         disp(t);
                %         disp(progress(t));
                %     end
                    %agent who receives a recommendation that period
                    ag=randi(n,1);
                    % determine recommended object according to preferential attachment with parameter
                    if alpha<2 
                        degs=sum(net,1);
                        vals=epsilon+degs.^alpha;
                        dist=cumsum(vals)/sum(vals);
                        obj=find(rand(1)<=dist,1);
                    else  %relevant only if m=n
                        mat=net^alpha;
                        vals=epsilon+mat(ag,:);
                        dist=cumsum(vals)/sum(vals);
                        obj=find(rand(1)<=dist,1);
                    end
                    %network evolution
                    if acceptables(ag,obj) 
                        net(ag,obj)=1;
                        %remove one link if capacity is reached    
                        if sum(net(ag,:))>caps(ag)
                            unobj=randsample(find(net(ag,:)>0),1);
                            net(ag,unobj)=0;
                        end
                    end
                    if Tconv==0 && sum(net,'all')>=sum(caps,'all')
                        Tconv=t; 
                        disp(t);
                        disp('convergence occured');
                    end
                    %if convergence has occurred, compute statistics 
                    if Tconv >0
                        degs=sum(net,1);
                        ave_degs=((t-Tconv)*ave_degs+ degs)*(1/(t+1-Tconv));
                    end
                end
                %progress at the last date.
                stat_progress(ix,jx,mc)=progress(t);
                stat_time(ix,jx,mc)=Tconv;
                stat_degrees(ix,jx,mc,:)=ave_degs;

                if is_microbank
                    stat_fairness_norm(ix,jx,mc)=norm(ave_degs-micro_alloc);
                    aux_ixs= (ave_degs>0) & (micro_alloc>0);
                    stat_fairness_div(ix,jx,mc)=sum(ave_degs(aux_ixs).*log(ave_degs(aux_ixs)./micro_alloc(aux_ixs)));
                    assert(stat_fairness_div(ix,jx,mc)>=0);     
                elseif is_macrobank
                dist_talmud(ix,jx,mc)=norm(ave_degs-talmud_alloc);
                dist_prop(ix,jx,mc)=norm(ave_degs-prop_alloc);
                stat_talmud(ix,jx,mc,:)=talmud_alloc;
                elseif is_shapley
                    dist_shapley(ix,jx,mc)=norm(ave_degs-shapley_alloc);
                    stat_shapley(ix,jx,mc,:)=shapley_alloc;
                end
        end
    end
end

toc;
%post-process

mean_time=mean(stat_time,3);
mean_fairness_div=mean(stat_fairness_div,3);
mean_fairness_norm=mean(stat_fairness_norm,3);

nzmean_time=zeros(n_corrs,n_alphas);

for ix=1:n_corrs
    for jx=1:n_alphas
        times=squeeze(stat_time(ix,jx,:));
        nzmean_time(ix,jx)=mean(times(times>0));
    end
end

mean_progress=mean(stat_progress,3);
mean_talmud=mean(dist_talmud,3);

% 
% figure(11)
% hold on
% plot(squeeze(mean_time(1,:)),'LineWidth',2)
% plot(squeeze(mean_time(2,:)),'LineWidth',2)
% plot(squeeze(mean_time(3,:)),'LineWidth',2)
% plot(squeeze(mean_time(4,:)),'LineWidth',2)
% legend;
% 
% 
% %evolution of correlation as a function of preferential attachment 
% figure(12)
% hold on
% plot(squeeze(mean_time(:,1)),'LineWidth',2)
% plot(squeeze(mean_time(:,2)),'LineWidth',2)
% plot(squeeze(mean_time(:,3)),'LineWidth',2)
% plot(squeeze(mean_time(:,4)),'LineWidth',2)
% plot(squeeze(mean_time(:,5)),'LineWidth',2)
% xlabel('correlation of preferences')
% ylabel('convergence time')
% legend("alpha 0", "alpha 1","2 hops","3 hops","5 hops");
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
% figure(13)
% hold on
% plot(squeeze(mean_time2(:,1)),'LineWidth',2)
% plot(squeeze(mean_time2(:,2)),'LineWidth',2)
% plot(squeeze(mean_time2(:,3)),'LineWidth',2)
% plot(squeeze(mean_time2(:,4)),'LineWidth',2)
% plot(squeeze(mean_time2(:,5)),'LineWidth',2)
% plot(squeeze(mean_time2(:,6)),'LineWidth',2)
% xlabel('correlation of preferences')
% ylabel('convergence time')
% legend("alpha 0", "alpha 0.25", "alpha 0.5","alpha 0.75","alpha 1.0");
% legend("alpha 0", "alpha 0.25", "alpha 0.5","alpha 0.75","alpha 1.0", "2 hops");
% 
% 
% 
% if is_shapley
%     mean_shapley=mean(dist_shapley,3);
%     figure(11)
%     surf(mean_shapley)
% end
% 
% mean_talmud=mean(dist_talmud,3);
% figure(2)
% surf(mean_talmud)
% xlabel('correlation');
% ylabel('attachment');
% zlabel('distance to talmud solution');
% 
% mean_shapley=mean(dist_shapley,3);
% figure(4)
% surf(mean_shapley)
% xlabel('correlation');
% ylabel('attachment');
% zlabel('distance to talmud solution');



save(file_name);

% mean_time2=mean(stat_time(:,1:4,:),3);
% figure(2);
% surf(mean_time2);
% 
% tcorr=mean(stat_time(6,:,:),3);


