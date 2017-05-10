%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%% setup parameters in this section 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%% "meshesPath" is where the orignal meshes are located

meshesPath = '~/Dropbox/Transmission/data/PNASExt/meshes/';

%%%%% "outputPath" stores intermediate files, re-aligned meshes, and
%%%%% morphologika files
outputPath = '~/Downloads/output_tmp/';

%%%%% set parameters for the algorithm
restart = 0;

iniNumPts = 128;
finNumPts = 256;
ssType = 'GPR'; %%% 'FPS' | 'GPR'
type = 'MST'; %%% 'MST' | 'SPC' | 'SDP'

use_cluster = 1;
n_jobs = 100; %%% more nodes, more failure (no hadoop!)
allow_reflection = 1; %%% if set to 0, no reflection will be allowed in
                      %%% the alignments
max_iter = 100; %%% maximum number of iterations for each pairwise alignment
email_notification = ''; %%% put your email address here f you would like
                         %%% to get notified when a parallel job finishes

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%% NO NEED TO MODIFY ANYTHING OTHER THAN THIS FILE!
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
codePath= [fileparts(pwd) filesep];
path(pathdef);
path(path, genpath([codePath 'software']));
setenv('MOSEKLM_LICENSE_FILE', [codePath 'software/mosek/mosek.lic'])
