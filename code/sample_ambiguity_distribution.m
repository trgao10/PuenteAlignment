function R = sample_ambiguity_distribution( X , Y , L )
%Get L samples from the ambiguity distribution

sigmaX = X*X'; 
sigmaY = Y*Y';
DX2 = eig(sigmaX);
DY2 = eig(sigmaY);

f = @(Q) trace(Q'*sigmaX*Q*sigmaY);
g = @()  uniform_random_orthogonal(3);
M = DX2'*DY2;

R = cell(1, L);
for ii = 1 : L
    R{ ii } = rejection_sampling(f,g,M);
end

end

function R = uniform_random_orthogonal( dim )
    [R, u] = qr(randn(dim,dim));
end