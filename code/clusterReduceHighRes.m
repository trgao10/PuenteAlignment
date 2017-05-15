%% set path and preparation
jadd_path;

disp(['Loading saved workspace from ' outputPath 'session_high.mat...']);
load([outputPath 'session_high.mat']);
disp('Loaded!');

jadd_path;

ds.msc.output_dir   = outputPath;
ds.msc.mesh_aligned_dir = [outputPath 'aligned/'];
pa.pfj        = [ds.msc.output_dir 'jobs/high/'];

pa = reduce( ds, pa, n_jobs );

%% Globalization
% try using name mst?
mst     = graphminspantree(sparse(pa.d + pa.d'));
ga     = globalize(pa, mst, 1, type);
ga.k   = k; %%% here k=2 (set in clusterMapHighRes.m)

%% Output higher resolution
write_off_global_alignment( [ds.msc.output_dir 'alignment_high.off' ], ds , ga, [1:ds.n], 10, [cos(theta) -sin(theta) 0 ; sin(theta) cos(theta) 0; 0 0 1]*[ 0 0 1; 0 -1 0; 1 0 0]*ds.shape{1}.U_X{k}',3.0,1);
write_morphologika( [ds.msc.output_dir 'morphologika_unscaled_high.txt' ], ds, ga );

%% Compute all pairwise Procrustes distances
proc_d     = zeros( ds.n , ds.n );
for ii = 1 : ds.n
    for jj = ii : ds.n
        if( ii == jj )
            continue;
        end
        [tmpR, proc_d( ii, jj)] = jprocrustes( ds.shape{ii}.X{k}*ga.P{ii} , ds.shape{jj}.X{k}*ga.P{jj} );
    end
end
mst_proc_d = graphminspantree( sparse( proc_d + proc_d' ) );
proc_d = (proc_d+proc_d')/2;
save([outputPath 'GPDMat_high.mat'], 'proc_d');
% plot_tree( proc_d+proc_d' , mst_proc_d , ds.names , 'mds', ones(1,ds.n) , 'MDS procrustes distances' );

%% Update final GPD on cluster
pa_tmp = localize(ga);
pa.R = pa_tmp.R;

k         = 2; % Which level to run next
pa.A      = upper_triangle( ds.n );
pa.pfj    = [ds.msc.output_dir 'jobs/post/']; % 'pfj' stands for path for jobs
tmpR  = pa.R;
tmpP  = pa.P;
f = @(ii, jj) loclinassign(ds.shape{ii}.X{k}, ds.shape{jj}.X{k}, pa.R{ii,jj}, ones(ds.N(k)));

% Remember to remove all previous jobs in the output/jobs folder!
% system(['rm -rf ' pa.pfj '/*']);
touch(pa.pfj);
pa = compute_alignment(pa, f, n_jobs, use_cluster);

disp(['Saving current workspace at ' outputPath 'session_high.mat....']);
system(['rm -rf ' outputPath 'session_high.mat']);
save([outputPath 'session_high.mat'], '-v7.3');
disp('Saved!');

disp('High-Resolution Alignment Completed');
