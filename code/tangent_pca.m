function tangent_pca(ds, ga, k)
% TANGENT_PCA - Runs and saves PCA on partial procrustes tangent coordinates
% This function saves a collection of .obj files representing aligned surface 
% meshes.
%
% Syntax: tangent_pca(ds, ga, k)
%
% Inputs:
%	ds - Structure array of surface shape data (see clusterMapLowRes.m)
%   ga - Structure array of alignment data (see clusterMapLowRes.m, globalize.m)
%	k  - Integer, indicates set of subsampled points to analyze (usually 2)
% 			   	
% Outputs:
% 	None

% Author: Julie Winchester, Ph.D.
% Department of Evolutionary Anthropology, Duke University
% Email: jmw110@duke.edu
% Website: http://www.apotropa.com
% January 17, 2017

disp('Running partial procrustes tangent coordinate PCA...')
c = tangent_coords(ds, ga, k);
[eivect, score, eival, ~, explain] = pca(c);
write_pca_files(ds.msc.output_dir, ds.names, eivect, score, eival, explain);
disp('PCA done.')