function [bestFoundG,bestActions]= multiagent_opt(funchandle, varchoices)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% OPTIONS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%experiment options
numKs=50;
numRuns = 1; 
stopEpoch=50; %If it hasn't improved after this many Epochs, stop
maxEpochs=250;
%agent options
alpha = 0.1;    % Learning rate
Qinit= -10000;   %Q-table initialization
exploration.biasMin=0.1;
exploration.biasMax=1.0;
%plotting and workspace options
saveWorkspace = 1;
showConstraintViolation             = 0;
altplots                            =1;
%addpath('C:\Projects\GitHub\QuadrotorModel')
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

numAgents = numel(varchoices);
bestActions = uint8(zeros(numRuns,numAgents)); % The discrete action choices of the agents that give best performance

maxG = -10000*zeros(numRuns, 1);
exploration.completion = 0;

for r = 1:numRuns
    % Create the agents and feasels
    [agents] = create_agents(varchoices,Qinit);
    
    % initializing best performance obtained
    bestG(1)= -10000;
    G=-10000;
    epochOfMax(r) = 0;
    e=1;
    converged=false;
    bestGc=nan(1,maxEpochs);
    avgGk=nan(1,maxEpochs);
    
    while converged==false
        e=e+1;
        
        bestG(e)=bestG(e-1);
        k=0;
        for k=1:numKs
            
            exploration.completion = k/numKs;

            % Have agents choose actions
            actions = choose_actions(agents, exploration);
            actions_hist(:, r, e) = actions;

            % Get rewards for agents and system performance
            [rewards, G] = compute_rewards(actions, funchandle);
            
            G_hist(r,e,k)=G;
            G_khist(k)=G;
            avgGk(e)=mean(G_khist);
                        
            [agents, learned] = update_values(agents, rewards, alpha, actions, 'best');
            agents_hist{r, e} = agents;
            
            if learned
            learndisp=' learned';
            else
                learndisp='.';
            end 
            disp([num2str(r,'%03.0f') ', ' num2str(e,'%03.0f') ', ' num2str(k,'%03.0f') ', G=' num2str(G, '%+10.2e\n') ', maxG=' num2str(bestG(e), '%+10.2e\n') ' , avgG=' num2str(avgGk(e), '%+10.2e\n') learndisp])
            if G > bestG(e) %&& all(constraints <= 0.01)
                bestG(e) = G;
                % Update record of best actions generated by the system
                bestActions(r,:) = actions;
                bestFoundG(r)=G;
            end
            
        end

       if e>stopEpoch+1
            if bestG(e)==bestG(e-stopEpoch)
                converged=true;
            end
       end
       if e>maxEpochs
           converged=true;
       end
       
    end
    bestGc(1:length(bestG))=bestG;
    bestGhist(r,:)=bestGc;
    avgGhist(r,:)=avgGk;
    clear bestG
end

if ~exist('Saved Workspaces', 'dir')
    mkdir('Saved Workspaces');
end

generate_plots

end


