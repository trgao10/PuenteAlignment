function d = ltwoinf( X )
% l2-inf norm of X, i.e.
% the maximum l2 norm of the columns of x
d = sqrt( max( sum(X.*X,1) ) ); 