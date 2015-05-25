function mosekdiag()
%
% MOSEK diagnostics script for MATLAB.
%

clear all

disp(sprintf('Matlab version: %s', version()));
disp(sprintf('Architecture  : %s', computer()));

s = sscanf(version(),'%d.%d');
if s(1) < 7 || (s(1) == 7 && s(2) < 9)
    error(['MOSEK supports MATLAB 7.9 or newer. Installed version: %d.%d'], ...
          s(1), s(2))
end

[status, cmdout]=system('mosek -f');
if status > 0
    s = ['The mosek optimizer could not be invoked from the command line. ' ...
         'Most likely the path has not been configured correctly. ' ...
         'The mosek optimizer can still be invoked from the MATLAB ' ...
         'environment.' ];                
    warning(s)
else
    disp(['The mosek optimizer executed successfully from the command line:']);
    disp(sprintf('%s',cmdout));    
end

c = which('mosekopt');
if length(c) == 0
    % This should never happen (mosekopt.m and mosekdiag.m
    % are in the same directory).
    error('mosekopt is not included in the MATLAB path.')
else
    disp(sprintf('mosekopt: %s', c))
end

if strcmp(c(end-1:end),'.m')
    error(sprintf(['mosekopt.%s not found. Mostly likely the ' ...
                   'architecture of MATLAB and MOSEK does not ' ...
                   'match.'], mexext()))    
end

% Testing a simple linear optimization problem
prob.c = [ 1 2 0]';
subi   = [1 2 2 1];
subj   = [1 1 2 3];
valij  = [1.0 1.0 1.0 1.0];
prob.a = sparse(subi,subj,valij);
prob.blc = [4.0 1.0]';
prob.buc = [6.0 inf]';
prob.blx = sparse(3,1);
prob.bux = [];
[r,res] = mosekopt('minimize echo(0)',prob); 

if r 
    error(sprintf('mosekopt returned an error: %d. [%s]', ...
                  r, res.rcodestr));
else
    disp('mosekopt is working correctly.');
end

% Testing Java and Fusion
if ~usejava('jvm')
    warning('Java Virtual Machine not enabled; MOSEK Fusion will not work.');
else
    try 
        import('mosek.fusion.Model')
        disp('MOSEK Fusion is working correctly.')
    catch
        warning(['MOSEK Fusion is not configured correctly; check that ', ...
                 'mosek.jar is added to the javaclasspath.'])
    end
end
    