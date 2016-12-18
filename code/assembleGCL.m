function [GCL, GCL_Dvec, GCL_W] = assembleGCL(wAdjMat, edgePotCell, d)
%ASSEMBLEGCL assemble Graph Connection Laplacian (GCL) from a weighted
%            adjacency matrix of the base graph and an edge potential
% INPUTS:
%   wAdjMat ------------------------------ weighted adjacency matrix of the
%                                          base graph
%   edgePotCell -------------------------- edge potential in cell format
%   d ------------------------------------ dimension of each block
%
% OUTPUTS:
%   GCL ---------------------------------- graph connection Laplacian
%   GCL_Dvec ----------------------------- D matrix in GCL = I-D^{-1/2}*W*D^{-1/2}
%   GCL_W -------------------------------- W matrix in GCL = I-D^{-1/2}*W*D^{-1/2}
%   
% Tingran Gao (trgao10@math.duke.edu)
% last modified: Oct 14, 2016
% 

GCL_Dvec = kron(sum(wAdjMat), ones(1,d));
GCL_W = zeros(size(wAdjMat,1)*d);
[rIdx, cIdx, wVal] = find(wAdjMat);
for j=1:length(rIdx)
    rIdx_j = rIdx(j);
    cIdx_j = cIdx(j);
    rowIdx = ((rIdx_j-1)*d+1):(rIdx_j*d);
    colIdx = ((cIdx_j-1)*d+1):(cIdx_j*d);
    
    GCL_W(rowIdx, colIdx) = wVal(j)*edgePotCell{rIdx_j, cIdx_j};
end

GCL = eye(size(GCL_W)) - ...
                     diag(1./sqrt(GCL_Dvec))*GCL_W*diag(1./sqrt(GCL_Dvec));

end

