operating_system='Linux';%'Windows';

if( strcmp(operating_system,'Linux') )
    sep = '/';
    bm_path= '/home/grad/trgao10/Work/MATLAB/JesusAlignment/';
elseif( strcmp(operating_system,'Windows') )
    sep = '\';
    bm_path= 'C:\Jesus\work\BoneMatching\';
else
    error('Operating system not recognized');
end

% Set path and global  variables SHOULD USE SETENVS instead of a variable
path(pathdef);
% path(path,[bm_path 'software' sep 'ToolboxGraph' sep 'toolbox_graph' sep 'toolbox_graph' sep 'toolbox']);
% path(path,[bm_path 'software' sep 'ToolboxGraph' sep 'toolbox_graph' sep 'toolbox_graph']);
% path(path,[bm_path 'software' sep 'ToolboxGraph' sep 'toolbox_graph']);
% path(path,[bm_path 'software' sep 'RectangularAssignment']);
addpath(path, genpath([bm_path 'software']));
addpath(path, '~/Documents/MATLAB/mosek/7/toolbox/r2013a');
% path(path,[bm_path 'code' sep 'MSTEWQ']);
% path(path,[bm_path 'code' sep 'MSTEWQ' sep 'cpp' ]);
% path(path,[bm_path 'software' sep 'ToolboxFastMarching' sep 'toolbox_fast_marching' sep 'mex']);
% path(path,[bm_path 'software' sep 'ToolboxFastMarching' sep 'toolbox_fast_marching' sep 'toolbox']);
% path(path,[bm_path 'software' sep 'ToolboxFastMarching' sep 'toolbox_fast_marching' ]);
% path(path,[bm_path 'software' ]);
% path(path,[bm_path 'software' sep 'spectral_clustering']);
% path(path,[bm_path 'software' sep 'ICP']);
% path(path,[bm_path 'software' sep 'ICP' sep 'Kroon']);
% path(path,[bm_path 'software' sep 'ICP' sep 'Bergstrom']);
% path(path,[bm_path 'software' sep 'ICP' sep 'Wilm']);
% path(path,[bm_path 'software' sep 'ICP' sep 'icp_logbarrier']);
% path(path,[bm_path 'code']);
% path(path,[bm_path 'code' sep 'shape_comparison']);
% path(path,[bm_path 'code' sep 'alignment_optimization']);
% path(path,[bm_path 'code' sep 'dimensionality_reduction' ]);

