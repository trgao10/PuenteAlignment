%% set path and preparation
jadd_path;

disp(['Loading saved workspace from ' outputPath 'session_high.mat...']);
load(fullfile(outputPath, 'session_high.mat'));   %%% for Windows
disp('Loaded!');

jadd_path;

ds.msc.output_dir   = outputPath;
ds.msc.mesh_aligned_dir = [outputPath, 'aligned' , filesep];   %%%% for Windows
pa.pfj        = [ds.msc.output_dir, 'jobs/', 'high', filesep];   %%%% for Windows

pa = reduce( ds, pa, n_jobs );

%% Globalization
% try using name mst?
mst     = graphminspantree(sparse(pa.d + pa.d'));
ga     = globalize(pa, mst, 1, type);
ga.k   = k; %%% here k=2 (set in clusterMapHighRes.m)

%% Output higher resolution
write_obj_aligned_shapes(ds, ga);    %%%% from Gorgon
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

if ds.n > 2  %%%  from Gorgon
	plot_tree( proc_d , mst_proc_d , ds.names , 'mds', ones(1,ds.n) , 'MDS procrustes distances' );
	coords = mdscale(proc_d,3)';
	if size(coords,1) == 3
		write_off_placed_shapes( fullfile(ds.msc.output_dir,'map.off'), coords, ds, ga, eye(3), mst_proc_d);
	end
end



save([outputPath 'GPDMat_high.mat'], 'proc_d');
% plot_tree( proc_d+proc_d' , mst_proc_d , ds.names , 'mds', ones(1,ds.n) , 'MDS procrustes distances' );

%% Update final GPD on cluster
pa_tmp = localize(ga);
pa.R = pa_tmp.R;

k         = 2; % Which level to run next
pa.A      = upper_triangle( ds.n );
pa.pfj    = [ds.msc.output_dir, 'jobs', 'post', filesep]; % 'pfj' stands for path for jobs   %%%% for Windows
tmpR  = pa.R;
tmpP  = pa.P;
f = @(ii, jj) loclinassign(ds.shape{ii}.X{k}, ds.shape{jj}.X{k}, pa.R{ii,jj}, ones(ds.N(k)));

% Remember to remove all previous jobs in the output/jobs folder!
% system(['rm -rf ' pa.pfj '/*']);
touch(pa.pfj);
pa = compute_alignment(pa, f, n_jobs, use_cluster);


%%%%%%%%%%%%% from Gorgon %%%%%%%%%%%%%%%

%% Optional outputting of procrustes distance matrix of rotated meshes
if do_procrustes_dist_output == 1
	names = matlab.lang.makeValidName(ds.names, 'ReplacementStyle', 'hex');
	d_table = array2table(proc_d, 'RowNames', names, 'VariableNames', names);
	writetable(d_table, fullfile(ds.msc.output_dir, 'proc_d.csv'));
end

%% Optional principal components analysis of partial procrustes tangent coordinates
if do_tangent_pca == 1
	tangent_pca(ds, ga, k);
end


disp(['Saving current workspace at ' outputPath 'session_high.mat....']);
system(['rm -rf ' outputPath 'session_high.mat']);
save([outputPath 'session_high.mat'], '-v7.3');
disp('Saved!');

disp('High-Resolution Alignment Completed');
