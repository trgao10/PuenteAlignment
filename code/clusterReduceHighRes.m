%% set path and preparation
jadd_path;

disp('Loading saved workspace...');
load([outputPath 'session_high.mat']);
disp('Loaded!');

pa = reduce( ds, pa, n_jobs );

%% Globalization
% mst is the same as before
ga     = globalize( pa, mst , 1 );
ga.k   = k;

%% Output higher resolution
write_off_global_alignment( [ds.msc.output_dir 'alignment_high.off' ], ds , ga, [1:ds.n], 10, [cos(theta) -sin(theta) 0 ; sin(theta) cos(theta) 0; 0 0 1]*[ 0 0 1; 0 -1 0; 1 0 0]*ds.shape{1}.U_X{k}',3.0,1);
write_morphologika( [ds.msc.output_dir 'morphologika_unscaled_high.txt' ], ds, ga );

disp('Saving current workspace....');
system(['rm -rf ' outputPath 'session_high.mat']);
save([outputPath 'session_high.mat']);
disp('Saved!');

%% Compute all pairwise Procrustes distances
%k          = 3;
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
plot_tree( proc_d+proc_d' , mst_proc_d , ds.names , 'mds', ones(1,ds.n) , 'MDS procrustes distances' );

proc_d = (proc_d+proc_d')/2;
coords = mdscale(proc_d,3)';
write_off_placed_shapes( [ds.msc.output_dir 'map.off' ], coords, ds, ga, eye(3), mst_proc_d);

disp('Alignment Completed');
