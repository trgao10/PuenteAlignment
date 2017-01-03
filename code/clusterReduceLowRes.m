%% set path and preparation
jadd_path;

disp(['Loading saved workspace from ' outputPath 'session_low.mat...']);
load([outputPath 'session_low.mat']);
disp('Loaded!');

jadd_path; %%% flush out old jadd_path.m variables stored in
           %%% session_low.mat for testing MST/SPC/SDP

ds.msc.output_dir   = outputPath;
ds.msc.mesh_aligned_dir = [outputPath 'aligned/'];           
pa.pfj        = [ds.msc.output_dir 'jobs/low/'];

pa = reduce(ds, pa, n_jobs);
%% Globalization
% 'ga' stands for global alignment
mst     = graphminspantree(sparse(pa.d + pa.d'));
ga      = globalize(pa, mst+mst', 2, type); 
ga.k    = k;

plot_tree(pa.d+pa.d', mst, ds.names, 'mds', ones(1,ds.n),'');

%% Output low resolution
theta = pi/2; % Useful for rotating files to look nicer
write_off_global_alignment([ds.msc.output_dir 'alignment_low.off' ], ds, ga, 1:ds.n, 10, [cos(theta) -sin(theta) 0 ; sin(theta) cos(theta) 0; 0 0 1]*[ 0 0 1; 0 -1 0; 1 0 0]*ds.shape{1}.U_X{k}', 3.0, 1);
write_morphologika([ds.msc.output_dir 'morphologika_unscaled_low.txt'], ds, ga);

disp(['Saving current workspace at ' outputPath 'session_low.mat....']);
system(['rm -rf ' outputPath 'session_low.mat']);
save([outputPath 'session_low.mat'], '-v7.3');
disp('Saved!');
