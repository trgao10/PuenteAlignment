function map( pa, f, n_jobs )
% Create .mat files for n_jobs number of jobs from variable pa

n           = size( pa.A , 1 );
[ r, c, v ] = find( pa.A );
size_job    = ceil( nnz(pa.A) / n_jobs );

pa_tmp = pa;

% Save pa's
for kk = 0 : n_jobs-1
    if ~exist([ pa.pfj 'job_' num2str( kk , '%.4d' ) '.mat' ],'file')
        inds       = [ size_job * kk + 1 : min( size_job * ( kk + 1 ) , nnz( pa.A )  ) ];
        pa_tmp.A   = sparse( r(inds) , c(inds), v(inds), n, n );
        save( [ pa.pfj 'job_' num2str( kk , '%.4d' ) ] , 'pa_tmp' );
    else
        display(['File ' [ pa.pfj 'job_' num2str( kk , '%.4d' ) ] '.mat already existed, skipping...']);
    end
end

% Save f (always)
save([pa.pfj 'f.mat'], 'f', '-v7.3');

