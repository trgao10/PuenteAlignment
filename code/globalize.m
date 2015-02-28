function ga = globalize( pa , tree , base)
% Takes a pairwise alignment (pa) and a tree and returns
% the global alignment (ga) obtained by propagating through the tree
% Base is the index of the element whose ga is the identity

n     = size( tree   , 1);
[r,c] = find(tree); mm = min(r(1),c(1)); MM = max(r(1),c(1));
N     = size( pa.P{mm,MM}, 2);

ga.R = cell( 1 , n );
ga.P = cell( 1 , n );
for ii = 1 : n
    [dist, pat] = graphshortestpath(tree+tree', ii , base );
    P = speye( N );
    R = eye(3);
    for jj = 2 : length( pat )
        if( pat(jj-1) > pat( jj ) )
            P = P * pa.P{ pat(jj), pat(jj-1) };
            R = pa.R{ pat(jj) , pat(jj-1) } * R;
        else
            P = P * pa.P{ pat(jj-1), pat(jj) }';
            R = pa.R{ pat(jj-1) , pat(jj) }' * R;
        end
        
    end
    ga.R{ ii } = R;
    ga.P{ ii } = P;
end



