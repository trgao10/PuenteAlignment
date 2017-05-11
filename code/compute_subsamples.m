function pa = compute_subsamples( pa, f, n_jobs, use_cluster )
% al must contain a sparse matrix A indicating which entries are to be
% computed
% al must also implement a function save()
% f must take two integers and return [d,R,P,gamma]

if( use_cluster == 0 )
   for kk = 0 : n_jobs - 1
      process_job([pa.pfj 'job_' num2str(kk,'%.4d') '.mat'], [ pa.pfj 'ans_' num2str(kk,'%.4d') '.mat'], [pa.pfj 'f.mat']);
   end
else
    %Write script files and submit them
    submit_jobs( pa , n_jobs );
end

end