function ind = subsample( V, N, seed )
% Subsample N points from V, using points in seed as starting seed
% Arguments:
%   seed - 3 x M matrix with points to be respected in V, i.e. points that
%   belong to V and that should be the first M points in the resulting X.
%   E.g. when you had a previously subsampled set and you want to just
%   increase the number of sampled points

if isempty( seed )
    tmp               = V(:, size(V,2));
    D                 = pdist2( V', tmp');
    [ tmpD, tmpind ] = max( D );
    seed              = V(:, tmpind(1) ) ;
end

% Find indices corresponding to seed
ind_seed = knnsearch( V', seed' );
if( norm( seed - V(:,ind_seed) , 'fro' ) > 1e-10 )
    error('Some seed point did not belong to the set of points to subsample from');
end
n_seed = length( ind_seed );
ind = [ reshape( ind_seed, 1, n_seed )  zeros( 1, N - n_seed ) ];

[ tmpIDX, D] = knnsearch( V(:,ind(1:n_seed))', V' );
for ii = n_seed + 1 : N
    [tmp, ind(ii)] = max(D);
    new_dist       = pdist2( V', V(:,ind(ii))');
    D              = min( D, new_dist );
end

end

