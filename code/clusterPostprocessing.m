%% set path and preparation
jadd_path;

disp(['Loading saved workspace from ' outputPath 'session_high.mat...']);
load([outputPath 'session_high.mat']);
disp('Loaded!');

jadd_path;

ds.msc.output_dir   = outputPath;
ds.msc.mesh_aligned_dir = [outputPath 'aligned/'];
pa.pfj        = [ds.msc.output_dir 'jobs/post/'];

pa = reduce( ds, pa, n_jobs );

% proc_d     = zeros( ds.n , ds.n );
% N = ds.N(end);
% for ii = 1 : ds.n
%     for jj = ii : ds.n
%         if( ii == jj )
%             continue;
%         end
%         proc_d( ii, jj) = loclinassign( ga.R{ii}*ds.shape{ii}.X{k}, ga.R{jj}*ds.shape{jj}.X{k}, eye(3), ones(N,N) );
%     end
% end
% proc_d = (proc_d+proc_d')/2;
% coords = mdscale(proc_d,3)';
% write_off_placed_shapes( [ds.msc.output_dir 'map.off' ], coords, ds, ga, eye(3), mst_proc_d);

proc_d = (pa.d + pa.d')/2;
save([outputPath 'GPDMat.mat'], 'proc_d');

taxa_code = ds.names;
save([outputPath 'taxa_code.mat'], 'taxa_code');

tangent_pca(ds, ga, k);
align_coord_pca(ds, ga, k);

disp(['Saving current workspace at ' outputPath 'session_high.mat....']);
system(['rm -rf ' outputPath 'session_high.mat']);
save([outputPath 'session_high.mat'], '-v7.3');
disp('Saved!');
