function [ d, R, P, gamma ] = locgpd( X, Y, R_0, M_0, max_iter )
% Local Generalized Procrustes Distance function

N           = size( X, 2 );

% How many different entries do these permutations have ?
diff_perms = @( P1, P2 ) sum(sum(abs(P1-P2)));

% Compute the required distances
MD2_0 = D2_sparse( X , R_0*Y , M_0 );

[P_0, d2, n_vars] = linassign( M_0 , MD2_0 );
%%% uncomment the following line to get debug information printed to screen
% display(['Initial linear assignment, nvars/tot = ' num2str( 100*nnz(M_0)/(size(X,2).^2), '%.2f' ) '%' ]);

% Not very elegant since MATLAB doesn't have repeat-until loops
P = P_0; R = R_0; d = sqrt( d2 ); P_prev = sparse( N, N );
numIter = 0;
while (diff_perms(P,P_prev) > 0)
    numIter = numIter+1;
    d_prev = d; P_prev = P; R_prev = R;
    
    [R, d]   = jprocrustes( X, Y*P_prev );
    
    gamma    = 1.5*ltwoinf(X-R*Y*P_prev);
    [M, MD2] = jrangesearch( X, R*Y, gamma);
    
    [P, d2, n_vars] = linassign( M , MD2 );        
    
    if( d > d_prev )
        %Check.This should not be possible, throw an error
        %Have to debug why sometimes it gets here.
        %error('Impossible, the function should have decreased, there has to be a bug');
    end
    
    %%% uncomment the following line to get debug information printed to screen
    % display(['P diff = ' num2str(diff_perms(P,P_prev) ) ', d = ' num2str(d,'%.4f') ', nvars/tot = ' num2str(100*n_vars/( size(X,2).^2 ) , '%.2f') '% ; gamma = '  num2str(gamma) ' ; d_R = ' num2str( acos( trace(R*R_prev'/3) ) , '%.6f' ) ]);
    if ((abs(d-d_prev)<1e-5*d_prev) || (numIter>max_iter))
        break;
    end
    if (numIter>100 && (mod(numIter,100)==0))
        disp(numIter);
    end
end

end

function D2 = D2_sparse(X,Y,A)
%The (i,j) column of D2 contains the distance between X(:,i) and Y(:,j) if
%A(i,j)=1, otherwise it is zero
[ r , c ] = find( A );
tmpD2     = sum( ( X(:,r) - Y(:,c) ).^2 , 1 );
D2        = sparse( r , c , tmpD2 );
end







