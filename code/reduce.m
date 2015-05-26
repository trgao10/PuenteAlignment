function pa = reduce(ds, pa, n_jobs )
% Rebuild the original pa based on the answers of the n_jobs

pa.d          = zeros( ds.n );
pa.R          = cell( ds.n, ds.n );
pa.P          = cell( ds.n, ds.n );
pa.gamma      = zeros( ds.n );

for kk = 0 : n_jobs-1
    if ~exist( [ pa.pfj 'ans_' num2str( kk , '%.4d' ) '.mat'], 'file')
        error(['Answer for job ' num2str( kk ) ' does not exist']);
    end
    load( [ pa.pfj 'ans_' num2str( kk , '%.4d' ) ] , 'pa_tmp' );
%     if( pa_tmp.id ~= pa.id )
%         error(['Job number ' num2str( kk ) ' did not have the same identifier as pa']);
%     end
    [ r, c, v ]    = find( pa_tmp.A );
    for ll = 1 : length( r )
        pa.d( r(ll), c(ll) )  = pa_tmp.d( r(ll), c(ll) );
        pa.R{ r(ll), c(ll) }  = pa_tmp.R{ r(ll), c(ll) };
        pa.P{ r(ll), c(ll) }  = pa_tmp.P{ r(ll), c(ll) };
        pa.gamma(r(ll),c(ll)) = pa_tmp.gamma(r(ll),c(ll));
    end
end


