%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% PuenteAlignment package, Jesus Puente (jparrubarrena@gmail.com)
%%% Please cite:
%%% 1. Jesus Puente, "Distances and Algorithms to Compare Shapes, with
%%%    Applications to Biological Morphometrics", Ph.D. Thesis, Princeton
%%%    University, September 2013
%%% 2. Boyer, Doug M., et al. "A New Fully Automated Approach for Aligning
%%%    and Comparing Shapes", The Anatomical Record 298.1 (2015): 249-276.
%%%
%%% Currently maintained by Tingran Gao (trgao10@math.duke.edu)
%%% last modified: May 26, 2015
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% INSTRUCTIONS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Step 1: Copy your data set (assuming all meshes are in .off format)
%%%         into the folder 'meshes/dataset/original/'
%%% Step 2: Set parameters in the script "jadd_path.m". You must keep
%%%         iniNumPts < finNumPts; often one sets iniNumPts << finNumPts
%%% Step 3: Click "Run" or press F5
%%% Step 4: After the program terminates, go to folder 'output/run/' for
%%%         results. morphologika.txt aligns the data set with iniNumPts
%%%         pseudolandmakrs on each mesh, while morphologika_2.txt aligns
%%%         the data set with finNumPts pseudolandmarks.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% set path and preparation
jadd_path;

if (restart == 1)
    system(['rm -rf ' outputPath]);
    system(['mkdir ' outputPath]);
end

touch([outputPath 'original/']);
touch([outputPath 'subsampled/']);
touch([outputPath 'aligned/']);
touch([outputPath 'jobs/']);
set(0,'RecursionLimit',1500);

% %% prepare path
% clear_prevrun;
% path(path, genpath([fileparts(pwd) filesep 'software']));
% touch('../meshes/dataset/subsampled/');
% touch('../output/run/aligned/');
% touch('../output/run/jobs/');
% set(0,'RecursionLimit',1500);

%% Information and parameters
ds.N       = [iniNumPts, finNumPts];  % Number of points to spread
ds.dataset = ''; % Used for pulling the files containing the meshes
ds.run     = '';     % Used for writing output and intermediate files
[ds.names, suffix] = getFileNames(meshesPath);
ds.ids     = arrayfun(@(x) sprintf('%03d', x), 1:length(ds.names), 'UniformOutput', 0);
cellfun(@(a,b) copyfile(a,b),...
    cellfun(@(x) [meshesPath x suffix], ds.names, 'UniformOutput', 0),...
    cellfun(@(x) [outputPath 'original/' x suffix], ds.ids, 'UniformOutput', 0));
% ds.N       = [iniNumPts, finNumPts];  % Number of points to spread
% ds.dataset = 'dataset'; % Used for pulling the files containing the meshes
% ds.run     = 'run';     % Used for writing output and intermediate files
% [ds.names, suffix] = getFileNames(meshesPath);
% ds.ids     = arrayfun(@(x) sprintf('%03d', x), 1:length(ds.names), 'UniformOutput', 0);
% cellfun(@(a,b) copyfile(a,b),...
%     cellfun(@(x) ['../meshes/dataset/original/' x suffix], ds.names, 'UniformOutput', 0),...
%     cellfun(@(x) ['../meshes/dataset/' x suffix], ds.ids, 'UniformOutput', 0));

%% paths to be passed as global constants
ds.n                = length( ds.ids ); %Number of shapes
ds.K                = length( ds.N ); %Number of levels
ds.msc.mesh_dir     = meshesPath;
ds.msc.output_dir   = outputPath;
ds.msc.mesh_aligned_dir = [outputPath 'aligned/'];
%%% Useful variables not to be changed
% ds.n                = length( ds.ids ); %Number of shapes
% ds.K                = length( ds.N ); %Number of levels
% ds.msc.general_dir  = [fileparts(pwd) filesep];
% ds.msc.mesh_dir     = [ ds.msc.general_dir 'meshes' filesep ds.dataset filesep ];
% ds.msc.output_dir   = [ ds.msc.general_dir 'output' filesep ds.run filesep ];
% ds.msc.mesh_aligned_dir = [ ds.msc.output_dir 'aligned' filesep ];

%% Useful lambda functions
center = @(X) X-repmat(mean(X,2),1,size(X,2));
scale  = @(X) norm(center(X),'fro') ;

%% Initialization
% 1. Fill in X with subsampled shapes
% 2. Center and standardize them
% 3. Compute Singular Value Decompositions and other useful quantities
ds.shape = cell ( 1, ds.n );
disp('Subsampling meshes...');
for ii = 1 : ds.n
    progressbar(ii, ds.n, 20);
    [ds.shape{ ii }.origV, ds.shape{ ii }.origF] = read_off([meshesPath ds.names{ii} suffix]);
    ds.shape{ ii }.X              = cell( 1, ds.K );
    ds.shape{ ii }.X{ ds.K }      = get_subsampled_shape( outputPath, ds.ids{ii} , ds.N( ds.K ) );
    ds.shape{ ii }.center         = mean(  ds.shape{ ii }.X{ ds.K }, 2 );
    ds.shape{ ii }.scale          = scale( ds.shape{ ii }.X{ ds.K } );
    ds.shape{ ii }.epsilon        = zeros( 1, ds.K );
    for kk = 1 : ds.K
        ds.shape{ ii }.X{kk}     = ds.shape{ii}.X{ ds.K }(:, 1:ds.N( kk ) );
        ds.shape{ ii }.X{kk}     = center(  ds.shape{ii}.X{kk} ) / scale(  ds.shape{ii}.X{kk} ) ;
        [ ds.shape{ ii }.U_X{kk} , tmpD_X , tmpV_X ] = svd( ds.shape{ii}.X{kk} );
        ds.shape{ ii }.D_X{kk}   = diag( tmpD_X );
        ds.shape{ ii }.V_X{kk}   = tmpV_X(:,1:3);
    end
    for kk = 2 : ds.K
       ds.shape{ ii }.epsilon(kk) = 1.0001*hausdorff( ds.shape{ii}.X{kk}(:,1:ds.N(kk-1)), ds.shape{ii}.X{kk} );
       ds.shape{ ii }.neigh{ kk } = jrangesearch(ds.shape{ii}.X{kk}(:,1:ds.N(kk-1)), ds.shape{ii}.X{kk} , ds.shape{ii}.epsilon(kk));
    end
end
disp('Done');

%Read the low resolution files, these are used for display puposes only
for ii = 1 : ds.n
    %Read the files
    lowres_off_fn = [outputPath 'subsampled' filesep ds.ids{ii} '.off'];
    if exist( lowres_off_fn , 'file' )
        [ds.shape{ ii }.lowres.V ,ds.shape{ ii }.lowres.F] = read_off(lowres_off_fn);
    else
        error(['Cannot find low resolution file ' lowres_off_fn ]);
    end
    %Scale according to highest resolution point cloud
    ds.shape{ii}.lowres.V = ds.shape{ii}.lowres.V-repmat(ds.shape{ii}.center,1,size(ds.shape{ii}.lowres.V,2));
    ds.shape{ii}.lowres.V = ds.shape{ii}.lowres.V / ( ds.shape{ii}.scale / sqrt( ds.N( ds.K ) ) );
end

% %% Initialization
% % 1. Fill in X with subsampled shapes
% % 2. Center and standardize them
% % 3. Compute Singular Value Decompositions and other useful quantities
% ds.shape = cell ( 1, ds.n );
% disp('Subsampling meshes...');
% for ii = 1 : ds.n
%     progressbar(ii, ds.n, 20);
%     [ds.shape{ ii }.origV, ds.shape{ ii }.origF] = read_off([ds.msc.mesh_dir 'original' filesep ds.names{ii} suffix]);
%     ds.shape{ ii }.X              = cell( 1, ds.K );
%     ds.shape{ ii }.X{ ds.K }      = get_subsampled_shape( ds.msc.mesh_dir , ds.ids{ii} , ds.N( ds.K )  );
%     ds.shape{ ii }.center         = mean(  ds.shape{ ii }.X{ ds.K }, 2 );
%     ds.shape{ ii }.scale          = scale( ds.shape{ ii }.X{ ds.K } );
%     %ds.shape{ ii }.delta          = cell( 1, ds.K );
%     ds.shape{ ii }.epsilon        = zeros( 1, ds.K );
%     for kk = 1 : ds.K
%         ds.shape{ ii }.X{kk}     = ds.shape{ii}.X{ ds.K }(:, 1:ds.N( kk ) );
%         ds.shape{ ii }.X{kk}     = center(  ds.shape{ii}.X{kk} ) / scale(  ds.shape{ii}.X{kk} ) ;
%         [ ds.shape{ ii }.U_X{kk} , tmpD_X , tmpV_X ] = svd( ds.shape{ii}.X{kk} );
%         ds.shape{ ii }.D_X{kk}   = diag( tmpD_X );
%         ds.shape{ ii }.V_X{kk}   = tmpV_X(:,1:3);
%         %ds.shape{ ii }.delta{kk} = squareform( pdist ( ds.shape{ ii }.X{ kk }' ) );
%     end
%     for kk = 2 : ds.K
%        ds.shape{ ii }.epsilon(kk) = 1.0001*hausdorff( ds.shape{ii}.X{kk}(:,1:ds.N(kk-1)), ds.shape{ii}.X{kk} );
%        ds.shape{ ii }.neigh{ kk } = jrangesearch(ds.shape{ii}.X{kk}(:,1:ds.N(kk-1)), ds.shape{ii}.X{kk} , ds.shape{ii}.epsilon(kk));
%     end
% end
% disp('Done');
% 
% %Read the low resolution files, these are used for display puposes only
% for ii = 1 : ds.n
%     %Read the files
%     lowres_off_fn = [ds.msc.mesh_dir 'subsampled' filesep ds.ids{ii} '.off'];
%     if exist( lowres_off_fn , 'file' )
%         [ds.shape{ ii }.lowres.V ,ds.shape{ ii }.lowres.F] = read_off(lowres_off_fn);
%     else
%         error(['Cannot find low resolution file ' lowres_off_fn ]);
%     end
%     %Scale according to highest resolution point cloud
%     ds.shape{ii}.lowres.V = ds.shape{ii}.lowres.V-repmat(ds.shape{ii}.center,1,size(ds.shape{ii}.lowres.V,2));
%     ds.shape{ii}.lowres.V = ds.shape{ii}.lowres.V / ( ds.shape{ii}.scale / sqrt( ds.N( ds.K ) ) );
% end

%% Alignment
% 'pa' stands for pairwise alignment
% 1. Compute a pairwise alignment of all pairs, then compute minimum
%    spanning tree
k = 1;
pa.A          = upper_triangle( ds.n ); % a 1 entry in this matrix indicates the pairwise distance should be computed
pa.L          = 8; % Number of positions to test, the first 8 are the 8 possibilities for aligning the principal axes
pa.max_iter   = max_iter;
f             = @( ii , jj ) gpd(  ds.shape{ii}.X{k}, ds.shape{jj}.X{k}, pa.L, pa.max_iter );
pa.pfj        = [ds.msc.output_dir 'jobs/low/'];
pa.codePath   = codePath;
pa.email_notification = email_notification;

% Break up all the pairwise distances into a a bunch of parallel tasks,
% to be computed either in the same machine or in different ones
% Remember to remove all previous jobs in the output/jobs folder!
touch(pa.pfj);
pa = compute_alignment( pa, f, n_jobs, use_cluster );

% %% Alignment
% % 'pa' stands for pairwise alignment
% % 1. Compute a pairwise alignment of all pairs, then compute minimum
% %    spanning tree
% k = 1;
% pa.A          = upper_triangle( ds.n ); % a 1 entry in this matrix indicates the pairwise distance should be computed
% pa.L          = 8; % Number of positions to test, the first 8 are the 8 possibilities for aligning the principal axes
% f             = @( ii , jj ) gpd(  ds.shape{ii}.X{k} , ds.shape{jj}.X{k}, pa.L );
% pa.pfj        = [ds.msc.output_dir 'jobs/'];
% 
% % Break up all the pairwise distances into a a bunch of parallel tasks,
% % to be computed either in the same machine or in different ones
% % Remember to remove all previous jobs in the output/jobs folder!
% pa = compute_alignment( pa, f, n_jobs, use_cluster );
% keyboard
pa = reduce( ds, pa, n_jobs );

% %Diagonals
% for ii = 1 : ds.n
%     pa.d(ii,ii)     = 0;
%     pa.R{ii,ii}     = eye(3);
%     pa.P{ii,ii}     = speye( ds.N(k));
%     pa.gamma(ii,ii) = 0;
% end

%% Globalization
% 'ga' stands for global alignment
mst     = graphminspantree( sparse( pa.d + pa.d' ) );
ga      = globalize( pa, mst+mst', 2 ); 
ga.k    = k;

plot_tree( pa.d+pa.d', mst, ds.names, 'mds', ones(1,ds.n),'');

%% Output low resolution
theta = pi/2; % Useful for rotating files to look nicer
write_off_global_alignment( [ds.msc.output_dir 'alignment_low.off' ], ds, ga, 1:ds.n, 10, [cos(theta) -sin(theta) 0 ; sin(theta) cos(theta) 0; 0 0 1]*[ 0 0 1; 0 -1 0; 1 0 0]*ds.shape{1}.U_X{k}', 3.0, 1);
write_morphologika( [ds.msc.output_dir 'morphologika_unscaled_low.txt'], ds, ga );
% theta=pi/2; % Useful for rotating files to look nicer
% write_off_global_alignment( [ds.msc.output_dir 'alignment.off' ], ds , ga , [1:ds.n], 10, [cos(theta) -sin(theta) 0 ; sin(theta) cos(theta) 0; 0 0 1]*[ 0 0 1; 0 -1 0; 1 0 0]*ds.shape{1}.U_X{k}',3.0,1);
% write_morphologika( [ds.msc.output_dir 'morphologika_unscaled.txt' ], ds, ga );
save( [ ds.msc.output_dir 'session.mat' ] , 'ds', 'pa', 'ga', 'mst' );

%% Compute the edges in the MST with higher number of points
pa_tmp = localize( ga );
pa.R = pa_tmp.R;

k         = 2; % Which level to run next
pa.A      = upper_triangle( ds.n );
pa.pfj    = [ds.msc.output_dir 'jobs/high/']; % 'pfj' stands for path for jobs
tmpR  = pa.R;
tmpP  = pa.P;
%dists = @(ii,jj) sqrt(sum((ds.shape{ii}.X{k-1}-tmpR{ii,jj}*ds.shape{jj}.X{k-1}*tmpP{ii,jj}).^2));
%myM   = @(ii,jj)  (ds.shape{ jj }.neigh{k}' * pre_M( ds.shape{ii}.X{k-1} , ds.shape{jj}.X{k-1} , dists(ii,jj) , ds.shape{ii}.epsilon(k) , ds.shape{jj}.epsilon(k) ) * ds.shape{ ii }.neigh{ k });
%f   = @( ii , jj ) locgpd(  ds.shape{ii}.X{k} , ds.shape{jj}.X{k}, pa.R{ii,jj} ,  myM(ii,jj)>0   );
f   = @( ii , jj ) locgpd( ds.shape{ii}.X{k}, ds.shape{jj}.X{k}, pa.R{ii,jj}, ones(ds.N(k)), pa.max_iter );

% Remember to remove all previous jobs in the output/jobs folder!
% system(['rm -rf ' pa.pfj '/*']);
touch(pa.pfj);
pa = compute_alignment( pa, f, n_jobs, use_cluster );

%%% Compute the edges in the MST with higher number of points
% pa_tmp = localize( ga );
% pa.R = pa_tmp.R;
% 
% k         = 2; % Which level to run next
% pa.A      = upper_triangle( ds.n );
% pa.pfj    = [ ds.msc.output_dir 'jobs/']; % 'pfj' stands for path for jobs
% tmpR  = pa.R;
% tmpP  = pa.P;
% %dists = @(ii,jj) sqrt(sum((ds.shape{ii}.X{k-1}-tmpR{ii,jj}*ds.shape{jj}.X{k-1}*tmpP{ii,jj}).^2));
% %myM   = @(ii,jj)  (ds.shape{ jj }.neigh{k}' * pre_M( ds.shape{ii}.X{k-1} , ds.shape{jj}.X{k-1} , dists(ii,jj) , ds.shape{ii}.epsilon(k) , ds.shape{jj}.epsilon(k) ) * ds.shape{ ii }.neigh{ k });
% %f   = @( ii , jj ) locgpd(  ds.shape{ii}.X{k} , ds.shape{jj}.X{k}, pa.R{ii,jj} ,  myM(ii,jj)>0   );
% f   = @( ii , jj ) locgpd(  ds.shape{ii}.X{k} , ds.shape{jj}.X{k}, pa.R{ii,jj} ,  ones(ds.N(k))   );
% 
% % Remember to remove all previous jobs in the output/jobs folder!
% delete '../output/run/jobs/*'
% pa = compute_alignment( pa, f, n_jobs, use_cluster );
% keyboard
pa = reduce( ds, pa, n_jobs );

%% Globalization
% mst is the same as before
ga     = globalize( pa, mst , 1 );
ga.k   = k;

%% Output higher resolution
write_off_global_alignment( [ds.msc.output_dir 'alignment_high.off' ], ds , ga, [1:ds.n], 10, [cos(theta) -sin(theta) 0 ; sin(theta) cos(theta) 0; 0 0 1]*[ 0 0 1; 0 -1 0; 1 0 0]*ds.shape{1}.U_X{k}',3.0,1);
write_morphologika( [ds.msc.output_dir 'morphologika_unscaled_high.txt' ], ds, ga );
% write_off_global_alignment( [ds.msc.output_dir 'alignment_2.off' ], ds , ga, [1:ds.n], 10, [cos(theta) -sin(theta) 0 ; sin(theta) cos(theta) 0; 0 0 1]*[ 0 0 1; 0 -1 0; 1 0 0]*ds.shape{1}.U_X{k}',3.0,1);
% write_morphologika( [ds.msc.output_dir 'morphologika_2_unscaled.txt' ], ds, ga );
save( [ ds.msc.output_dir 'session_2.mat' ] , 'ds', 'pa', 'ga', 'mst' );

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

proc_d=(proc_d+proc_d')/2;
coords=mdscale(proc_d,3)';
write_off_placed_shapes( [ds.msc.output_dir 'map.off' ], coords, ds, ga, eye(3), mst_proc_d);

disp('Alignment Completed');
%plot_shape_corr = @(ii,jj,k) plot_point_correspondence(ds.shape{ii}.X{k},ds.shape{jj}.X{k}*pa.P{ii,jj},pa.R{ii,jj})

