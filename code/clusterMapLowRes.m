jadd_path;

disp(['Loading saved workspace from ' outputPath 'session_low.mat...']);
load([outputPath 'session_low.mat']);
disp('Loaded!');

jadd_path;

ds.msc.output_dir = outputPath;
ds.msc.mesh_aligned_dir = [outputPath 'aligned/'];

%% Alignment
% 'pa' stands for pairwise alignment
% 1. Compute a pairwise alignment of all pairs, then compute minimum
%    spanning tree
k = 1;
pa.A          = upper_triangle( ds.n ); % a 1 entry in this matrix indicates the pairwise distance should be computed
% pa.L          = 8; % Number of positions to test, the first 8 are the 8 possibilities for aligning the principal axes
pa.max_iter   = max_iter;
pa.allow_reflection = allow_reflection;
f             = @( ii , jj ) gpd( ds.shape{ii}.X{k}, ds.shape{jj}.X{k}, pa.max_iter, pa.allow_reflection );
pa.pfj        = [ds.msc.output_dir 'jobs/low/'];
pa.codePath   = codePath;
pa.email_notification = email_notification;

% Break up all the pairwise distances into a a bunch of parallel tasks,
% to be computed either in the same machine or in different ones
% Remember to remove all previous jobs in the output/jobs folder!
touch(pa.pfj);
pa = compute_alignment( pa, f, n_jobs, use_cluster );

disp(['Saving current workspace at ' outputPath 'session_low.mat...']);
save([outputPath 'session_low.mat'], '-v7.3');
disp('Saved!');

