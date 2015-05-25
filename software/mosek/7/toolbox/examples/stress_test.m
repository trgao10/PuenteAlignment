clear prob;


ite = 500;
fprintf('Running afiro %d times, clear mosekopt after each run\n',ite);

% Perform the optimization.
tic;
for i=1:ite
  if (mod(i,100) == 0)
    fprintf('%d\n',i);
  end
    
  % Specifies c vector.
  prob.c = [ 1 2 0]';
  
  % Specify a in sparse format.
  subi   = [1 2 2 1];
  subj   = [1 1 2 3];
  valij  = [1.0 1.0 1.0 1.0];
  
  prob.a = sparse(subi,subj,valij);
  
  % Specify lower bounds on the constraints.
  prob.blc  = [4.0 1.0]';

  % Specify  upper bounds on the constraints.
  prob.buc  = [6.0 inf]';
  
  % Specify lower bounds on the variables.
  prob.blx  = sparse(3,1);
  
  % Specify upper bounds on the variables.
  prob.bux = [];   % There are no bounds.

  
  [r,res] = mosekopt('minimize echo(0)',prob); 
  
  if r ~= 0
    disp(res.rcodestr)
    disp(res.rmsg)
    error('Error from mosekopt');
  end
  
  clear mosekopt; % test if clearing mosekopt works

end
toc


clear prob;

ite = 2;
fprintf('Running afiro %d times, with debug\n',ite);

% Perform the optimization.
tic;
for i=1:ite
  
  % Specifies c vector.
  prob.c = [ 1 2 0]';
  
  % Specify a in sparse format.
  subi   = [1 2 2 1];
  subj   = [1 1 2 3];
  valij  = [1.0 1.0 1.0 1.0];
  
  prob.a = sparse(subi,subj,valij);
  
  % Specify lower bounds on the constraints.
  prob.blc  = [4.0 1.0]';

  % Specify  upper bounds on the constraints.
  prob.buc  = [6.0 inf]';
  
  % Specify lower bounds on the variables.
  prob.blx  = sparse(3,1);
  
  % Specify upper bounds on the variables.
  prob.bux = [];   % There are no bounds.

  
  [r,res] = mosekopt('minimize debug(100) echo(0)',prob); 
  
  if r ~= 0
    disp(res.rcodestr)
    disp(res.rmsg)
    error('Error from mosekopt');
  end
  
end
toc
