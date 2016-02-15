function [ d, R, P, gamma ] = gpd ( X, Y, max_iter, ref )
% Generalized Procrustes Distance
% L - The number of samples from the abiguity distribution
%     The first 8 samples are forced to be exactly the 8 elements of the
%     ambiguity set when the singular values are different.

N = size( X , 2 );

% Intialize tests
tst.R_0   = [ principal_component_alignment( X, Y, ref ) ]; %sample_ambiguity_distribution( X, Y, L - 8 ) ];
L = length(tst.R_0);
tst.d     = zeros(1,L);
tst.R     = cell(1 ,L);
tst.P     = cell(1 ,L);
tst.gamma = zeros(1,L);

% Generate the random alignments and run locgpd on them
for ii = 1 : L
    [ tst.d(ii) , tst.R{ii} , tst.P{ii}, tst.gamma(ii) ] = locgpd( X, Y, tst.R_0{ii}, ones(N,N), max_iter );
end

% Get the optimum
[ jmin, jarg ] = min( tst.d );

% Return values
d     = tst.d( jarg );
R     = tst.R{ jarg };
P     = tst.P{ jarg };
gamma = tst.gamma( jarg );
end

function R = principal_component_alignment( X, Y, ref ) 
% Generate the rotations in the ambiguity set when the singular values
% are all diferent (w.p.1 in practice)

[UX,DX,VX] = svd(X);
[UY,DY,VY] = svd(Y);

R = cell( 1, 8 );
R{ 1 } = UX*diag( [ 1  1  1 ] )*UY';
R{ 2 } = UX*diag( [-1 -1  1 ] )*UY';
R{ 3 } = UX*diag( [ 1 -1 -1 ] )*UY';
R{ 4 } = UX*diag( [-1  1 -1 ] )*UY';
R{ 5 } = UX*diag( [-1  1  1 ] )*UY';
R{ 6 } = UX*diag( [ 1 -1  1 ] )*UY';
R{ 7 } = UX*diag( [ 1  1 -1 ] )*UY';
R{ 8 } = UX*diag( [-1 -1 -1 ] )*UY';

if ref == 0    
    detIdx = [];
    for j=1:length(R)
        if det(R{j}) < 0
            detIdx = [ detIdx j];
        end
    end
    R(detIdx) = [];
end

end

