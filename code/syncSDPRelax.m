function [solCell, solMat] = syncSDPRelax(C, d, GCL_Dvec)
%SYNCSDPRELAX Solve synchronization problem using SDP relaxation
%
% Based on the work [CKS2015]:
% =========================================================================
%   Kunal N. Chaudhury, Yuehaw Khoo, and Amit Singer.
%   "Global Registration of Multiple Point Clouds using Semidefinite Programming."
%   SIAM Journal on Optimization, 25(1):468–501, 2015.
% =========================================================================
%
% INPUTS:
%   C: square matrix of dimension nd-by-nd (i.e. GCL)
%   d: dimension of each squre block
%   n: number of blocks
%
% OUTPUTS:
%   solCell ------------------- solution in cell format (cell array of
%                               length n)
%   solMat -------------------- solution in matrix format (matrix of size
%                               (n x numClusters)-by-n
% Tingran Gao (trgao10@math.duke.edu)
% last modfied: Nov 8, 2016
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%% C is of dimension nd-by-nd
%%%%%
%%%%% SDP relaxation for the following optimization problem (simply drop
%%%%% the rank constraint)
%%%%% 
%%%%%             max  trace(CG)
%%%%%             s.t. G\in\mathbb{R}^{nd\times nd}
%%%%%                  G_{ii} = I_{d\times d}                  
%%%%%                  G >= 0
%%%%%                  rank(G) <= d
%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

nd = size(C, 1);
n = nd/d;

if rem(n,1) ~= 0
    error('dimenison of input matrix does not equal d\times n');
end

cvx_begin sdp
    variable G(nd,nd) symmetric
    minimize( trace( C * G ) )
    subject to
        for j=1:n
            G(((j-1)*d+1):(j*d), ((j-1)*d+1):(j*d)) == eye(d)
        end
        G >= 0
cvx_end

[evecs,evals] = eig(G);
evals = diag(evals);
[~,idx] = sort(evals,'descend');
evecs = evecs(:,idx);
relaxSol = evecs(:,1:d);
rescaled_relaxSol = relaxSol*diag(sqrt(evals(1:d)));
% rescaled_relaxSol = diag(1./sqrt(GCL_Dvec))*relaxSol;

solCell = cell(1,n);
solMat = zeros(size(rescaled_relaxSol));
for j=1:length(GCL_Dvec)/d
    tmpIdx = ((j-1)*d+1):(j*d);
    tmpBlock = rescaled_relaxSol(tmpIdx,:);
    [U,~,V] = svd(tmpBlock);
    solCell{j} = U*V';
    solMat(tmpIdx,:) = solCell{j};
end
    
end
