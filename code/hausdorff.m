function [d , iargX, iargY] = hausdorff( X , Y )
% Compute the Hausdorff distance using euclidean distances between
% points whose coordinates are the columns of X and Y

[ind1 , D1 ] = knnsearch(X',Y');
[ind2 , D2 ] = knnsearch(Y',X');

[ m1, argm1 ] = max( D1 );
[ m2, argm2 ] = max( D2 );

if ( m1 > m2 )
    d = m1;
    iargX = ind1( argm1 );
    iargY = argm1;
else
    d = m2;
    iargX = argm2;
    iargY = ind2( argm2 );
end


