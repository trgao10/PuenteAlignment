% Run Generalized Procrustes Analysis (Full or Partial) on
% a morphologica dataset and produce the files required
% by jp_scatter_plot to make the plots with the convex hulls

%Justin's dataset
if(0)
    morphologika_file = 'Observer determined landmarks_106taxa_use-landmarks_1-5_7-27_30.txt';
    ind = [ 1:5 7:27 30]; %Indices of landmarks we care about
    db_group = [1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	2	2	2	2	2	2	2	2	2	2	2	2	2	2	2	2	2	2	2	2	2	2	2	2	2	2	2	2	2	2	2	2	2	2	2	2	2	2	2	2	3	3	3	3	3	3	3	3	3	3	3	3	3	3	3	3	3	4	4	4	4	4	4	5	5	5	5	2	5	3	2	2	5	5	7	7	4	7	6	6	6	6	6	5	5	7	7]; %Groups given by Doug
    method='full';
    pcx=1; % Number of ppal component to plot in x axis
    pcy=3; % Number of ppal component to plot in y axis
end

%Jesus' dataset
if(0)
    morphologika_file = 'Computer-correspondence_106taxa_1200points.txt';
    ind = [ 1:1200]; %Indices of landmarks we care about
    db_group = [1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	2	2	2	2	2	2	2	2	2	2	2	2	2	2	2	2	2	2	2	2	2	2	2	2	2	2	2	2	2	2	2	2	2	2	2	2	2	2	2	2	3	3	3	3	3	3	3	3	3	3	3	3	3	3	3	3	3	4	4	4	4	4	4	5	5	5	5	2	5	3	2	2	5	5	7	7	4	7	6	6	6	6	6	5	5	7	7]; %Groups given by Doug
    method='full';
    pcx=1; % Number of ppal component to plot in x axis
    pcy=3; % Number of ppal component to plot in y axis
end

%Test dataset with 128 points only
if(0)
    morphologika_file = 'morphologika_2.txt';
    ind = [ 1:256]; %Indices of landmarks we care about
    db_group = [1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	2	2	2	2	2	2	2	2	2	2	2	2	2	2	2	2	2	2	2	2	2	2	2	2	2	2	2	2	2	2	2	2	2	2	2	2	2	2	2	2	3	3	3	3	3	3	3	3	3	3	3	3	3	3	3	3	3	4	4	4	4	4	4	5	5	5	5	2	5	3	2	2	5	5	7	7	4	7	6	6	6	6	6	5	5	7	7]; %Groups given by Doug
    method='full';
    pcx=1; % Number of ppal component to plot in x axis
    pcy=2; % Number of ppal component to plot in y axis
end

if(1) % Teeth dataset from PNAS paper
    morphologika_file = [ds.msc.output_dir 'morphologika_2.txt'];
    ind = [ 1:256]; %Indices of landmarks we care about
    db_group = ones(1,ds.n);
    method='full';
    pcx=1; % Number of ppal component to plot in x axis
    pcy=3; % Number of ppal component to plot in y axis 
end


% Read Morphologika file
curr_dataset = input_morphologika( morphologika_file );

%Subsample the appropriate landmarks
curr_dataset.landmarks = length(ind);
tmp = curr_dataset.verts;
clear curr_dataset.verts;
curr_dataset.verts = cell( curr_dataset.individuals, 1);
for ii = 1 : curr_dataset.individuals
    curr_dataset.verts{ii} = tmp{ii}(:,ind);
end

%Overwrite the appropriate groups
curr_dataset.group = db_group;

%Run Generalized Full Procrustes
[Z,mmean]=generalized_procrustes( curr_dataset.verts , method );

%Convert matrices to vectors and do PCA on them
X = zeros( curr_dataset.individuals , curr_dataset.landmarks * curr_dataset.dimensions);
for ii = 1: curr_dataset.individuals
    X(ii,:)=reshape( Z{ii}, 1, curr_dataset.landmarks * curr_dataset.dimensions);
end
[ coeff , score, latent ] = princomp(X);

%Plot the ii and jj principal components
figure; hold on;
scatter( score(:,pcx), score(:,pcy),30,curr_dataset.group,'filled')

%Create files for python script
jp_scatter_plot_files([score(:,pcx)' ;  score(:,pcy)' ; curr_dataset.group-1]); %Groups must be 0-indexed for the python script
%Have to run the script

if(0)
    %Plot aligned configurations
    plot_configurations(Z,[67 68])
    title('Alignments');
end


