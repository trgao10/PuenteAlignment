function ind = gplmk( V, F, N, seed )
% Subsample N points from V, using Gaussian Process landmarking
% Arguments:
%   seed - 3 x M matrix with points to be respected in V, i.e. points that
%   belong to V and that should be the first M points in the resulting X.
%   E.g. when you had a previously subsampled set and you want to just
%   increase the number of sampled points

nV = size(V,2);
Center = mean(V,2);
V = V - repmat(Center,1,nV);
Area = compute_surface_area(V',F');
V = V * sqrt(1/Area);

[~,curvature] = findPointNormals(V',10);
Lambda = curvature/sum(curvature);

I = [F(1,:),F(2,:),F(3,:)];
J = [F(2,:),F(3,:),F(1,:)];
E = [I ; J];
E = sort(E)';
E = sortrows(E);
E = unique(E,'rows','stable')';
EdgeIdxI = E(1,:);
EdgeIdxJ = E(2,:);
bandwidth = mean(sqrt(sum((V(:,EdgeIdxI)-V(:,EdgeIdxJ)).^2)))/5;

BNN = min(500,nV);
atria = nn_prepare(V');
[idx, dist] = nn_search(V',atria,(1:nV)',BNN+1,-1,0.0);
fullPhi = sparse(repmat(1:nV,1,BNN+1),idx,exp(-dist.^2/bandwidth),nV,nV);

disp('Constructing full kernel......');
tic;
fullMatProd = fullPhi * sparse(1:nV,1:nV,Lambda,nV,nV) * fullPhi;
disp(['full kernel constructed in ' num2str(toc) ' sec.']);

KernelTrace = diag(fullMatProd);

if isempty( seed )
    [~,maxIdx] = max(KernelTrace);
    seed  = V(:,maxIdx);
end

% Find indices corresponding to seed
ind_seed = knnsearch( V', seed' );
if( norm( seed - V(:,ind_seed) , 'fro' ) > 1e-10 )
    error('Some seed point did not belong to the set of points to subsample from');
end
n_seed = length( ind_seed );
ind = [ reshape( ind_seed, 1, n_seed )  zeros( 1, N - n_seed ) ];

invKn = zeros(N);
invKn(1:ind(1:n_seed),1:ind(1:n_seed)) = inv(fullMatProd(ind(1:n_seed),ind(1:n_seed)));

cback = 0;
for j=n_seed + 1 : N
    for cc=1:cback
        fprintf('\b');
    end
    cback = fprintf('Landmark: %4d\n',j);
    
    if j == 2
        invKn(1:(j-1),1:(j-1)) = 1/fullMatProd(ind(1),ind(1));
        ptuq = KernelTrace - sum(fullMatProd(:,ind(1:(j-1)))'...
            .*(invKn(1:(j-1),1:(j-1))*fullMatProd(ind(1:(j-1)),:)),1)';
    else
        p = fullMatProd(ind(1:(j-2)),ind(j-1));
        mu = 1./(fullMatProd(ind(j-1),ind(j-1))-p'*invKn(1:(j-2),1:(j-2))*p);
        invKn(1:(j-2),1:(j-1)) = invKn(1:(j-2),1:(j-2))*[eye(j-2)+mu*(p*p')*invKn(1:(j-2),1:(j-2)),-mu*p];
        invKn(j-1,1:(j-1)) = [invKn(1:(j-2),j-1)',mu];
        productEntity = invKn(1:(j-1),1:(j-1))*fullMatProd(ind(1:(j-1)),:);
        ptuq = KernelTrace - sum(fullMatProd(:,ind(1:(j-1)))'...
            .*productEntity,1)';
    end
    [~,maxUQIdx] = max(ptuq);
    ind(j) = maxUQIdx;
end

% cback = 0;
% for j = n_seed + 1 : N
%     for cc=1:cback
%         fprintf('\b');
%     end
%     cback = fprintf('Landmark: %4d\n',j);
%     
%     ptuq = KernelTrace - sum(fullMatProd(:,ind(1:(j-1)))'...
%         .*(fullMatProd(ind(1:(j-1)),ind(1:(j-1)))\fullMatProd(ind(1:(j-1)),:)),1)';
%     [~,maxUQIdx] = max(ptuq);
%     ind(j) = maxUQIdx;
% end

% patch('Vertices', V', 'Faces', F', 'FaceColor',[0.5,0.5,0.5],'CDataMapping','direct');
% axis equal;
% axis off
% hold on
% axis equal
% scatter3(V(1,ind),V(2,ind),V(3,ind),20,'g','filled')
% keyboard

end

