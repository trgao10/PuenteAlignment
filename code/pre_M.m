function pre_M = pre_M( X , Y , d , epsilon_X , epsilon_Y )

n       = size( X, 2 );

delta_X = squareform( pdist ( X' ) );
delta_Y = squareform( pdist ( Y' ) );

lhs     = delta_X + delta_Y;
rhs     = repmat( d, n, 1 ) + repmat( d', 1, n ) + 4 * ( epsilon_X + epsilon_Y );

[r,c,v] = find ( lhs <= rhs );

pre_M   = sparse(r,c,v,n,n);
