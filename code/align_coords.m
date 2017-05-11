function coords = align_coords(ds, ga, k)
% ALIGN_COORDS - Calculate scaled/centered procrustes-aligned coordinates   
%
% Syntax: coords = align_coords(ds, ga, k)
%
% Inputs:
%	ds - Structure array of surface shape data (see clusterMapLowRes.m)
%   ga - Structure array of alignment data (see clusterMapLowRes.m, globalize.m)
%	k  - Integer, indicates set of subsampled points to analyze (usually 2)
% 			   	
% Outputs:
% 	coords - Stacked row vector matrix (individuals x landmarks*dimensions) 
%			 of Procrustes-aligned mesh coordinates

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
	meshMat(:,:,i) = scaleMesh(meshMat(:,:,i));
end

% Stacked shape data row vector matrix, n x (landmark * dimension)
coords = reshape(meshMat,[],size(meshMat,3))';

% % Row vector of mean shape scaled to unit size, n x (landmark * dimension)
% meanShape = scaleMesh(mean(meshMat, 3));
% meanShapeRow = meanShape(:)';

% % Optional beta scaling for full procrustes tangent projection. results are 
% % closer to morphologika without this
% %
% % for i = 1:length(ds.names)
% % 	dp = sqrt(sum(sum((meanShape - meshMat(:,:,i)).^2)));
% % 	p = 2*asin((dp/2));
% % 	betaScale = cos(p);
% % 	meshMat(:,:,i) = meshMat(:,:,i) * betaScale;
% % end

% % Projection coordinates Xstar = X * (I_kp - X_c'*X_c), Rohlf (1999)
% proj = meshRowMat * (eye(length(meanShapeRow)) - meanShapeRow'*meanShapeRow);

% % Differences between projected coordinates and reference
% coords = proj - (ones(size(meshRowMat, 1), 1) * meanShapeRow);

end
