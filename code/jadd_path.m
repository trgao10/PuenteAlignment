%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%% setup parameters in this section 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%% "meshesPath" is where the orignal meshes are located
meshesPath = '/gtmp/BoyerLab/PNAS/';

%%%%% "outputPath" stores intermediate files, re-aligned meshes, and
%%%%% morphologika files
outputPath = '/gtmp/BoyerLab/output/';

%%%%% set parameters for the algorithm
restart = 1;
iniNumPts = 200;
finNumPts = 1000;
n_jobs = 100; %%% more nodes, more failure (no hadoop!)
use_cluster = 1;
max_iter = 3000;
email_notification = 'trgao10@math.duke.edu';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%% NO NEED TO MODIFY ANYTHING OTHER THAN THIS FILE!
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
codePath= [fileparts(pwd) filesep];
path(pathdef);
path(path, genpath([codePath 'software']));
