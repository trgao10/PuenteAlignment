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
rng('shuffle');

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

%% subsample meshes (locally or on cluster)
if use_cluster == 0
    for ii = 1:ds.n            
        fprintf('Getting Subsampled Mesh %s......', ds.names{ii});
        get_subsampled_shape( outputPath, ds.ids{ii}, ds.N( ds.K ), ssType );
        fprintf('DONE\n');
    end
else
    PBS = '#PBS -l nodes=1:ppn=1,walltime=3:00:00\n#PBS -m abe\n';
    script = 'matlab -nodesktop -nodisplay -nojvm -nosplash -r ' ;
    matlab_cmd = @( kk ) ['\"cd ' codePath 'code/; ' 'jadd_path; get_subsampled_shape(''' outputPath ''', ' ds.ids{kk} ', ' num2str(ds.N(ds.K)) ', ''' ssType '''); exit;\"'];
    pfj = [ds.msc.output_dir 'jobs/subs/'];
    touch(pfj);
    % if (length(strfind(email_notification, '@')) == 1)
    %     sub_sh = @( kk ) ['!qsub -m e -M ' email_notification ' -N job_' num2str(kk,'%.4d') ' -o ' pfj 'stdout_' num2str(kk,'%.4d') ' -e ' pfj 'stderr_' num2str(kk,'%.4d') ' ' pfj 'job_' num2str(kk,'%.4d') '.sh'];
    % else
    %     sub_sh = @( kk ) ['!qsub -N job_' num2str(kk,'%.4d') ' -o ' pfj 'stdout_' num2str(kk,'%.4d') ' -e ' pfj 'stderr_' num2str(kk,'%.4d') ' ' pfj 'job_' num2str(kk,'%.4d') '.sh'];
    % end
    sub_sh = @( kk ) ['!qsub -N job_' num2str(kk,'%.4d') ' -o ' pfj 'stdout_' num2str(kk,'%.4d') ' -e ' pfj 'stderr_' num2str(kk,'%.4d') ' ' pfj 'job_' num2str(kk,'%.4d') '.sh'];
    
    for ii = 1:ds.n
        script_txt = [ PBS script matlab_cmd(ii) ];
        fid        = fopen([ pfj 'job_' num2str( ii, '%.4d') '.sh'],'w');
        fprintf( fid, script_txt );
        fclose(fid);
        
        eval( sub_sh(ii) )
    end
    
end

%% save intermediate results
disp(['Saving current workspace at ' outputPath 'session_low.mat...']);
save([outputPath 'session_low.mat'], '-v7.3');
disp('Saved!');

