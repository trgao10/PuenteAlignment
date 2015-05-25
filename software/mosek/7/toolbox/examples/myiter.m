function [r] =  myiter(handle,where,info)
% handle: Is a user-defined data structure.
% where : Is an integer indicating from where in the optimization
%         process the callback was invoked.
% info  : A MATLAB structure containing information about the state of the
%         optimization.

r = 0;   % r should always be assigned a value.

if handle.symbcon.MSK_CALLBACK_BEGIN_INTPNT==where
    fprintf('Interior point optimizer started\n');
end


% Print primal objective
fprintf('Interior-point primal obj.: %e\n',info.MSK_DINF_INTPNT_PRIMAL_OBJ);

% Terminate when cputime > handle.maxtime
if info.MSK_DINF_INTPNT_TIME > handle.maxtime
      r = 1;
else
  r = 0;
end
     

if handle.symbcon. MSK_CALLBACK_END_INTPNT==where
    fprintf('Interior-point optimizer terminated\n');
end

