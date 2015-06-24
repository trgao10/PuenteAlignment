function submit_jobs( pa, n_jobs )
%Send jobs to the cluster

% Text wrappers
PBS        = '#PBS -l nodes=1:ppn=1,walltime=3:00:00\n#PBS -m abe\n';
script     = 'matlab -nodesktop -nodisplay -nojvm -nosplash -r ' ;
matlab_cmd = @( kk ) ['\"cd ' pa.codePath 'code/;' 'jadd_path; load(''' pa.pfj 'job_' num2str( kk, '%.4d') ''');process_job(''' pa.pfj 'job_' num2str(kk,'%.4d') ''', ''' pa.pfj 'ans_' num2str(kk,'%.4d') ''', ''' pa.pfj 'f.mat'');exit;\"'];
if (length(strfind(pa.email_notification, '@')) == 1)
    sub_sh     = @( kk ) ['!qsub -m e -M ' pa.email_notification ' -N job_' num2str(kk,'%.4d') ' -o ' pa.pfj 'stdout_' num2str(kk,'%.4d') ' -e ' pa.pfj 'stderr_' num2str(kk,'%.4d') ' ' pa.pfj 'job_' num2str(kk,'%.4d') '.sh'];
else
    sub_sh     = @( kk ) ['!qsub -N job_' num2str(kk,'%.4d') ' -o ' pa.pfj 'stdout_' num2str(kk,'%.4d') ' -e ' pa.pfj 'stderr_' num2str(kk,'%.4d') ' ' pa.pfj 'job_' num2str(kk,'%.4d') '.sh'];
end

%Create scripts
for kk = 0 : n_jobs-1
    script_txt = [ PBS script matlab_cmd(kk) ];
    fid        = fopen([ pa.pfj 'job_' num2str( kk, '%.4d') '.sh'],'w');
    fprintf( fid, script_txt );
    fclose(fid);
end

% Submit scripts
for kk = 0: n_jobs -1
    eval( sub_sh(kk) )
end
    
    


