function [Z, mmean] = generalized_procrustes( config , method ) 
%Generalized Procrustes Analysis
%
% Arguments
% config - Cell of configuration matrices, where each is n x 3
% method - 'full' for Full Procrustes (default)
%          'partial' for Partial Procrustes

threshold = 1e-10;
n = length( config ); % Number of shapes

%Useful functions
center = @( M ) M-repmat(mean(M')',1,size(M,2));
scale  = @( M ) norm( center(M) , 'fro' );

%If it's partial procrustes, scale everything
if( strcmp(method,'partial') )
    for ii = 1 : n
        config{ii} = center(config{ii})/scale(config{ii});
    end
end

imean     = randi(n); % Index of initial mmean
mmean      = center(config{imean}); % Initial mmean
mmean_old  = zeros(size(mmean));

d = zeros( n , 1 );
Z = cell( n , 1 );
it = 0;
while( norm( mmean-mmean_old , 'fro' ) > threshold )
    it = it+1;
    %Compute Procrustes from the current mmean to each configuration matrix
    for ii = 1 : n
        if( strcmp( method, 'partial' ) )
            [d(ii), Z{ii}, transf] = procrustes( mmean', config{ii}', 'scaling', 0);
        elseif( strcmp(method,'full'))
            [d(ii), Z{ii}, transf] = procrustes( mmean', config{ii}');
        end
        Z{ii}=Z{ii}';
    end
    
    %Save new mmean
    mmean_old = mmean;
    
    %Update the mmean
    mmean = zeros( size(mmean) );
    for ii = 1 : n
        mmean = mmean + Z{ii};
    end
    mmean = mmean / n;
    
    mmean = center(mmean)/scale(mmean);
    
    display([' Iteration ' num2str(it) ' variation : ' num2str( norm( mmean-mmean_old , 'fro' ) ) ]);
end