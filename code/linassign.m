function [ P, d, n_vars] = linassign( A , D )
% Linear assignment problem
% In the case of Procrustes distance, notice that chancer are you want to pass D as a distance SQUARED
% and you want to take the SQUARE ROOT after you call this function
% The Output P is a permutation matrix such that Y*P has indices aligned
% with those of X in our Generalized Procrustes Distance Framework.
% This differs from saying that P(i,j)=1 if point i in X corresponds to point j
% in Y. In order to get the latter, P would need to be transposed.
%

N     = size( A, 1 );

if (  A == ones ( N , N ) )
    %     [tmpP, d] = munkres(D);
    %Use Hungarian Algorithm, Buehren's implementation
    [tmpP, d] = assignmentoptimal( D );
    P = sparse( 1:N, tmpP, ones(1,N) );
    P = P';
    n_vars = N * N;
else
    tmpD  = reshape( D, N*N, 1);
    ivars = find( A );
    n_vars= length(ivars);
    
    %Build equality constrains for all (useful and useless) variables, we will
    %reduce it later
    Aeq = [ kron( speye(N), ones(1,N) ) ; kron( ones(1,N) , speye(N) ) ];
    
    %Reduce the number of variables using ivars
    Aeq_red = Aeq(:,ivars);
    dissimilarity_for_lp_red = tmpD(ivars);
    
    %Positivity constrain and rhs of equality constrains
    lb_red  = sparse(length(ivars),1);
    beq     = sparse(ones(2*N,1));
    
    %Solve linear program
    prob.c = dissimilarity_for_lp_red;
    prob.a = Aeq_red;
    prob.buc = beq;
    prob.blc = beq;
    prob.blx = lb_red;
    param.MSK_IPAR_OPTIMIZER = 'MSK_OPTIMIZER_PRIMAL_SIMPLEX';
    [~,res] = mosekopt('minimize echo(0)',prob,param);
    P_red = res.sol.bas.xx;
    d = res.sol.bas.pobjval;
    
%     options = optimset('Display','none');
%     [P_red, d]=linprog(dissimilarity_for_lp_red,[],[],Aeq_red,beq,lb_red,[],[],options);
    
    %Remove spurious (close to zero) values
    P_red = sparse( P_red > 1e-1 );
    
    %Expand to right size and shape
    %tmpP          = sparse( N*N,1);
    %tmpP(ivars,1) = P_red;
    tmpP          = sparse( ivars, 1, P_red , N*N , 1 );
    P             = reshape(tmpP,N,N);
    P             = P'; % TRANSPOSE to fit the description of GPD
end
end