function coords = tangent_coords(ds, ga, k)
% TANGENT_COORDS - Calculate partial procrustes tangent projection coordinates
% This function takes a collection of shapes scaled to unit centroid size, and 
% using matrices provided in ga, aligns shapes and permutes them to achieve
% landmark correspondece. Aligned unit-scaled
% shapes comprise a multidimensional pre-shape space. Pre-shape variables are
% projected orthogonally onto a plane tangent to a mean shape reference, and
% tangent plane coordinates are calculated for each shape. The method for
% calculation is that of Dryden and Mardia (1993, 1998, 2016) as modified by
% Rohlf (1999).   
%
% Syntax: coords = tangent_coords(ds, ga, k)
%
% Inputs:
%	ds - Structure array of surface shape data (see clusterMapLowRes.m)
%   ga - Structure array of alignment data (see clusterMapLowRes.m, globalize.m)
%	k  - Integer, indicates set of subsampled points to analyze (usually 2)
% 			   	
% Outputs:
% 	coords - Stacked row vector matrix (individuals x landmarks*dimensions) 
%			 of partial Procrustes tangent space coordinates

% Author: Julie Winchester, Ph.D.
% Department of Evolutionary Anthropology, Duke University
% Email: jmw110@duke.edu
% Website: http://www.apotropa.com
% January 17, 2017

centerMesh = @(X) X - repmat(mean(X,2),1,size(X,2));
scaleMesh  = @(X) centerMesh(X) / norm(centerMesh(X),'fro');

% Matrix of shape data, n x landmark x dimension
meshMat = zeros(3, ds.N(ga.k), length(ds.names));
for i = 1:length(ds.names)
	meshMat(:,:,i) = ga.R{i} * ds.shape{i}.X{ga.k} * ga.P{i};
end

% Stacked shape data row vector matrix, n x (landmark * dimension)
meshRowMat = reshape(meshMat,[],size(meshMat,3))';

% Row vector of mean shape scaled to unit size, n x (landmark * dimension)
meanShape = scaleMesh(mean(meshMat, 3));
meanShapeRow = meanShape(:)';

% Optional beta scaling for full procrustes tangent projection. results are 
% closer to morphologika without this
%
% for i = 1:length(ds.names)
% 	dp = sqrt(sum(sum((meanShape - meshMat(:,:,i)).^2)));
% 	p = 2*asin((dp/2));
% 	betaScale = cos(p);
% 	meshMat(:,:,i) = meshMat(:,:,i) * betaScale;
% end

% Projection coordinates Xstar = X * (I_kp - X_c'*X_c), Rohlf (1999)
proj = meshRowMat * (eye(length(meanShapeRow)) - meanShapeRow'*meanShapeRow);

% Differences between projected coordinates and reference
coords = proj - (ones(size(meshRowMat, 1), 1) * meanShapeRow);