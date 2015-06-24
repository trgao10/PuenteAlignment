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

%% information and parameters
ds.N       = [iniNumPts, finNumPts];  % Number of points to spread
ds.dataset = ''; % Used for pulling the files containing the meshes
ds.run     = '';     % Used for writing output and intermediate files
[ds.names, suffix] = getFileNames(meshesPath);
ds.ids     = arrayfun(@(x) sprintf('%03d', x), 1:length(ds.names), 'UniformOutput', 0);
cellfun(@(a,b) copyfile(a,b),...
    cellfun(@(x) [meshesPath x suffix], ds.names, 'UniformOutput', 0),...
    cellfun(@(x) [outputPath 'original/' x suffix], ds.ids, 'UniformOutput', 0));

%% paths to be passed as global constants
ds.n                = length( ds.ids ); %Number of shapes
ds.K                = length( ds.N ); %Number of levels
ds.msc.mesh_dir     = meshesPath;
ds.msc.output_dir   = outputPath;
ds.msc.mesh_aligned_dir = [outputPath 'aligned/'];

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
    ds.shape{ ii }.X{ ds.K }      = get_subsampled_shape( outputPath, ds.ids{ii} , ds.N( ds.K )  );
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

%% Alignment
% 'pa' stands for pairwise alignment
% 1. Compute a pairwise alignment of all pairs, then compute minimum
%    spanning tree
k = 1;
pa.A          = upper_triangle( ds.n ); % a 1 entry in this matrix indicates the pairwise distance should be computed
pa.L          = 8; % Number of positions to test, the first 8 are the 8 possibilities for aligning the principal axes
f             = @( ii , jj ) gpd(  ds.shape{ii}.X{k}, ds.shape{jj}.X{k}, pa.L );
pa.pfj        = [ds.msc.output_dir 'jobs/'];

% Break up all the pairwise distances into a a bunch of parallel tasks,
% to be computed either in the same machine or in different ones
% Remember to remove all previous jobs in the output/jobs folder!
pa = compute_alignment( pa, f, n_jobs, use_cluster );
