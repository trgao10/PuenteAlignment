ii = 8; jj=76; k=2;
% Global alignment
plot_point_correspondence(ga.R{ii}*ds.shape{ii}.X{k}, ga.R{jj}*ds.shape{jj}.X{2}*ga.P{jj}, eye(3));

% Local alignment
plot_point_correspondence(ds.shape{ii}.X{k},ds.shape{jj}.X{k}*pa.P{ii,jj},  pa.R{ii,jj});

%Side by side
figure; hold on;
plot_mesh(ds.shape{ii}.lowres.V, ds.shape{ii}.lowres.F);
plot_mesh(pa.R{ii,jj}*ds.shape{jj}.lowres.V + repmat( [2 0 0]', 1, size(ds.shape{jj}.lowres.V,2) ), ds.shape{jj}.lowres.F);
title('Pairwise');

%
figure; hold on;
plot_mesh(ds.shape{ii}.lowres.V, ds.shape{ii}.lowres.F);
plot_mesh(pa.R{ii,jj}*ds.shape{jj}.lowres.V + repmat( [2 0 0]', 1, size(ds.shape{jj}.lowres.V,2) ), ds.shape{jj}.lowres.F);
title('Global');


% Lets find the ga and pa that differ
tmppa = localize(ga);
%pa is the pairwise alignments
Rdist = zeros( ds.n, ds.n);
for ii=1:ds.n -1
    for jj= ii+1 : ds.n
         Rdist(ii,jj) = real(acos(trace(tmppa.R{ii,jj}*pa.R{ii,jj}'/3)));
    end
end
