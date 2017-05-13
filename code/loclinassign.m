function [ d, R, P, gamma ] = loclinassign( X, Y, R_0, M_0 )
% Local Generalized Procrustes Distance function

N = size( X, 2 );

% How many different entries do these permutations have ?
diff_perms = @( P1, P2 ) sum(sum(abs(P1-P2)));

% Compute the required distances
MD2_0 = D2_sparse( X , R_0*Y , M_0 );

[P_0, d2, n_vars] = linassign( M_0 , MD2_0 );
%%% uncomment the following line to get debug information printed to screen
% display(['Initial linear assignment, nvars/tot = ' num2str( 100*nnz(M_0)/(size(X,2).^2), '%.2f' ) '%' ]);

% Not very elegant since MATLAB doesn't have repeat-until loops
P = P_0; R = R_0; d = sqrt( d2 );
gamma = 0;

end

function D2 = D2_sparse(X,Y,A)
%The (i,j) column of D2 contains the distance between X(:,i) and Y(:,j) if
%A(i,j)=1, otherwise it is zero
[ r , c ] = find( A );
tmpD2     = sum( ( X(:,r) - Y(:,c) ).^2 , 1 );
D2        = sparse( r , c , tmpD2 );
end







