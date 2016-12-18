function [perEdgeFrustVec, perEdgeFrustMat] = getPerEdgeFrustFromEdgePot(wAdjMat, edgePot, vertPot)
%GETPEREDGEFRUSTRATIONFROMEDGEPOT collection frustration on each edge of graph G
%
% INPUTS:
%   wAdjMat -------------------- weighed adjacency matrix
%   edgePot -------------------- prescribed edge potential
%   vertPot -------------------- vertex potential of which the per edge
%                                frustration is to be collected, stored in
%                                cell array format
%
% OUTPUTS:
%   perEdgeFrustVec ------------ vector of length nnz(perEdgeFrustMat)/2
%                                storing per edge frustration
%   perEdgeFrustMat ------------ matrix of the same size as G.adjMat
%                                encoding edge frustration at the
%                                corresponding edge in G.adjMat
%   
% Tingran Gao (trgao10@math.duke.edu)
% last modified: Oct 14, 2016
%

[rIdx, cIdx] = find(triu(wAdjMat));
perEdgeFrustVec = zeros(length(rIdx),1);
for j=1:length(rIdx)
    perEdgeFrustVec(j) = ...
      wAdjMat(rIdx(j),cIdx(j))*norm(vertPot{rIdx(j)}-edgePot{rIdx(j),cIdx(j)}*vertPot{cIdx(j)},'fro')^2;
end

perEdgeFrustMat = sparse(rIdx,cIdx,perEdgeFrustVec,size(wAdjMat,1),size(wAdjMat,2));
perEdgeFrustMat = perEdgeFrustMat + perEdgeFrustMat';

end

