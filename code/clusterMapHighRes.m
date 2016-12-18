%% set path and preparation
jadd_path;

disp('Loading saved workspace...');
load([outputPath 'session_low.mat']);
disp('Loaded!');

%% Compute the edges in the MST with higher number of points
pa_tmp = localize(ga);
pa.R = pa_tmp.R;

k         = 2; % Which level to run next
pa.A      = upper_triangle( ds.n );
pa.pfj    = [ds.msc.output_dir 'jobs/high/']; % 'pfj' stands for path for jobs
tmpR  = pa.R;
tmpP  = pa.P;
f = @(ii, jj) locgpd(ds.shape{ii}.X{k}, ds.shape{jj}.X{k}, pa.R{ii,jj}, ones(ds.N(k)), pa.max_iter);

% Remember to remove all previous jobs in the output/jobs folder!
% system(['rm -rf ' pa.pfj '/*']);
touch(pa.pfj);
pa = compute_alignment(pa, f, n_jobs, use_cluster);

disp('Saving current workspace...');
save([outputPath 'session_high.mat'], '-v7.3');
disp('Saved!');
