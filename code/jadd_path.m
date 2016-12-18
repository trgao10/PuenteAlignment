%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%% setup parameters in this section 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%% "meshesPath" is where the orignal meshes are located
meshesPath = '~/Work/tmpMeshes/input/';

%%%%% "outputPath" stores intermediate files, re-aligned meshes, and
%%%%% morphologika files
outputPath = '~/Work/tmpMeshes/output/';

%%%%% set parameters for the algorithm
restart = 1;
iniNumPts = 100;
finNumPts = 400;
type = 'SDP'; %%% 'MST' | 'SPEC' | 'SDP'

use_cluster = 0;
n_jobs = 100; %%% more nodes, more failure (no hadoop!)
allow_reflection = 1;
max_iter = 100;
email_notification = '';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%% NO NEED TO MODIFY ANYTHING OTHER THAN THIS FILE!
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
codePath= [fileparts(pwd) filesep];
path(pathdef);
path(path, genpath([codePath 'software']));
setenv('MOSEKLM_LICENSE_FILE', [codePath 'software/mosek/mosek.lic'])
