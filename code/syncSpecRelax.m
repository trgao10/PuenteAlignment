function [solCell, solMat] = syncSpecRelax(GCL, d, GCL_Dvec)
%SYNCSPECRELAX Solve synchronization problem using spectral relaxation
%
% Based on the work [BSS2013]:
% =========================================================================
%   Bandeira, Afonso S., Amit Singer, and Daniel A. Spielman.
%   "A Cheeger Inequality for the Graph Connection Laplacian."
%   SIAM Journal on Matrix Analysis and Applications 34.4 (2013):1611-1630.
% =========================================================================
%
% INPUTS:
%   GCL ----------------------- Graph Connection Laplacian
%   d   ----------------------- (fixed) dimension of each block
%   GCL_Dvec ------------------ vector encoding the D matrix in the formula
%                               GCL=I-D^{-1/2}*W*D^{-1/2}
%
% OUTPUTS:
%   solCell ------------------- solution in cell format (cell array of
%                               length n)
%   solMat -------------------- solution in matrix format (matrix of size
%                               (n x numClusters)-by-n
%
% Tingran Gao (trgao10@math.duke.edu)
% last modified: Oct 18, 2016
%

[evecs,evals] = eig(GCL);
evals = diag(evals);
[~,idx] = sort(evals);
evecs = evecs(:,idx);
relaxSol = evecs(:,1:d);
rescaled_relaxSol = diag(1./sqrt(GCL_Dvec))*relaxSol;

solCell = cell(1,length(GCL_Dvec)/d);
solMat = zeros(size(rescaled_relaxSol));
for j=1:length(GCL_Dvec)/d
    tmpIdx = ((j-1)*d+1):(j*d);
    tmpBlock = rescaled_relaxSol(tmpIdx,:);
    [U,~,V] = svd(tmpBlock);
    solCell{j} = U*V';
    solMat(tmpIdx,:) = solCell{j};
end

end

