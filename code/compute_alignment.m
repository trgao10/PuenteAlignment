function pa = compute_alignment( pa, f, n_jobs, use_cluster )
% Computes optimal rotation and permutation for true entries of A
% al must contain a sparse matrix A indicating which entries are to be
% computed
% al must also implement a function save()
% f must take two integers and return [d,R,P,gamma]

n          = size( pa.A , 2 );

map( pa, f, n_jobs ); % Save n_jobs files to be processed

if( use_cluster == 0 )
   for kk = 0 : n_jobs - 1
      process_job([pa.pfj 'job_' num2str(kk,'%.4d') '.mat'], [ pa.pfj 'ans_' num2str(kk,'%.4d') '.mat'], [pa.pfj 'f.mat']);
   end
else
    %Write script files and submit them
    submit_jobs( pa , n_jobs );
end
    
% 
% if( exist( pa.savefn , 'file' ) )
%     load( pa.savefn , 'pa' ); % load progress
% else
%     pa.d          = zeros( ds.n );
%     pa.R          = cell( ds.n, ds.n );
%     pa.P          = cell( ds.n, ds.n );
%     pa.gamma      = zeros( ds.n );
%     %Below is attempt to run in cluster, it is for functions map,
%     %submit_jobs and reduce
%     %     pa.pfj        = [ds.msc.output_dir 'jobs/'];
%     %     pa.id         = randi(10000000000);
%     %     pa.nnz        = nnz( pa.A );
%     %     pa.n_jobs     = 2;
% end
% 
% 


