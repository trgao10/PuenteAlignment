function [ M, MD2 ] = jrangesearch ( X, Y, epsilon )
% Output:
%    M   - Sparse matrix whose (i,j) entry is 1 if the distance between
%          X(:,i) and Y(:,j) is smaller than epsilon
%    MD2 - Sparse matrix whose (i,j) entry is the SQUARED distance between
%          X(:,i) and Y(:,j).
%
%    Notice it returns the squares of the distances

[tmpM, tmpMD]  = rangesearch( X', Y', epsilon);
tmpind=tmpM;
for kk = 1 : size(Y, 2)
    tmpind{ kk } = kk * ones( 1, length( tmpind{kk} ) );
end
M                = sparse( [tmpM{:}] , [tmpind{:}] , ones(1,length([tmpM{:}])), size(X,2), size(Y,2) );
MD2              = sparse( [tmpM{:}] , [tmpind{:}] , [tmpMD{:}].^2 , size(X,2) , size(Y,2) );
end