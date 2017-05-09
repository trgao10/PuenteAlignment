function write_pca_files(filepath, indNames, eigenvector, score, eigenvalue, explained)
% WRITE_PCA_FILES - Save PCA results as files
% Saves results from pca(X) function as a series of files in a subdirectory 
% created in the location defined by path. 
%
% Syntax: write_pca_files(filepath, eigenvector, eigenvalue, explained, score)
%
% Inputs:
%	filepath - String indicating location of subdirectory containing files
%   eigenvector - Matrix (variables x number of PCs) of PC loadings
%	eigenvalue 	- Column vector (number of PCs x 1) of variances by PC
%	explained	- Column vector (num. of PCs x 1) of percent variance by PC
%   scores      - Matrix (individuals x number of PCs) of PCA scores
% 			   	
% Outputs:
% 	None

% Author: Julie Winchester, Ph.D.
% Department of Evolutionary Anthropology, Duke University
% Email: jmw110@duke.edu
% Website: http://www.apotropa.com
% January 17, 2017

if ~exist(fullfile(filepath, 'pca'), 'dir')
	mkdir(fullfile(filepath, 'pca'));
end

nInd = size(score, 1);
nPC = size(score, 2);
vars = size(eigenvector, 1);

% Scores plot
fig = figure();
s = scatter(score(:,1), score(:,2), ...
	'MarkerFaceColor', [0.3020 0.7490 0.9294], ...
	'MarkerEdgeColor', [0 0.4510 0.7412]);
ax = gca;
ax.XAxisLocation = 'origin';
ax.YAxisLocation = 'origin';
title('Tangent coordinate PCA');
xlabel('PC1');
ylabel('PC2');
saveas(fig, fullfile(filepath, 'pca', 'pca_score_plot.png'));
saveas(fig, fullfile(filepath, 'pca', 'pca_score_plot.eps'));

% Data tables
pcNames = arrayfun(@(X) strcat('PC',num2str(X)), 1:nPC, 'UniformOutput', 0);

sTable = array2table([indNames',num2cell(score)], ...
	'VariableNames', ['Individual', pcNames]);
writetable(sTable,fullfile(filepath, 'pca', 'pca_scores.csv'));

eTable = array2table([(1:vars)', eigenvector], ...
	'VariableNames', ['Variable', pcNames]);
writetable(eTable, fullfile(filepath, 'pca', 'pca_eigenvectors.csv'));

vTable = table((1:nPC)', eigenvalue, explained, ...
	'VariableNames',{'PC', 'Eigenvalue', 'Percent_variance_explained'});
writetable(vTable, fullfile(filepath, 'pca', 'pca_variance.csv'));