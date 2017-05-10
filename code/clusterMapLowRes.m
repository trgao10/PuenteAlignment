jadd_path;

disp(['Loading saved workspace from ' outputPath 'session_low.mat...']);
load([outputPath 'session_low.mat']);
disp('Loaded!');

jadd_path;

ds.msc.output_dir = outputPath;
ds.msc.mesh_aligned_dir = [outputPath 'aligned/'];

%% Initialization
% 1. Fill in X with subsampled shapes
% 2. Center and standardize them
% 3. Compute Singular Value Decompositions and other useful quantities
center = @(X) X-repmat(mean(X,2),1,size(X,2));
scale  = @(X) norm(center(X),'fro') ;

ds.shape = cell ( 1, ds.n );
for ii = 1 : ds.n
    [ds.shape{ ii }.origV, ds.shape{ ii }.origF] = read_off([meshesPath ds.names{ii} suffix]);
    ds.shape{ ii }.X              = cell( 1, ds.K );
    fprintf('Getting Subsampled Mesh %s......', ds.names{ii});
    ds.shape{ ii }.X{ ds.K }      = get_subsampled_shape( outputPath, ds.ids{ii}, ds.N( ds.K ), ssType );
    fprintf('DONE\n');
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

%% Read the low resolution files, these are used for display puposes only
for ii = 1:ds.n
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

