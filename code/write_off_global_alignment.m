function write_off_global_alignment( filename, ds, ga, varargin )
% Write an off file with the shapes in ds aligned according
% to global alignment ga
% Output only the shapes with indices in ind and display with
% 'per_row' number of shapes per row

% Parameters
inds    = 1 : ds.n;
if( nargin >= 4)
    inds    = varargin{1};
end
per_row = floor( sqrt( length( inds ) ) );
if( nargin >= 5 )
    per_row = varargin{2};
end
view_rot = eye(3);
if( nargin >=6 )
    view_rot = varargin{3};
end
offset = 3.0; 
if( nargin >=7 )
    offset = varargin{4};
end
reference = 1;
if( nargin >= 8 )
    reference = varargin{5};
end


%Create vertices and faces of the resulting off file

V=[]; F=[];
for ii = 1 : length( inds )
    if ( det( ga.R{ inds(ii) } ) < 0 ) % Need to invert faces orientation
        F = [ F ( ds.shape{ inds(ii) }.lowres.F([2 1 3],:) + size(V,2) ) ];
    else
        F = [ F ( ds.shape{ inds(ii)}.lowres.F + size(V,2) ) ];
    end
    r = floor( (ii-1) / per_row );
    c = (ii-1) - r * per_row;
    V = [V ( view_rot * ga.R{ inds(ii) } * ds.shape{ inds(ii) }.lowres.V * (ds.shape{inds(ii)}.scale/sqrt(ds.N(ds.K)))...
        + repmat( [ offset*c 0 offset*r ]' , 1, size( ds.shape{ inds(ii) }.lowres.V , 2 ) ) )];
%     V = [ V ( view_rot * ga.R{ inds(ii) } * ds.shape{ inds(ii) }.lowres.V + repmat( [ offset*c 0 offset*r ]' , 1, size( ds.shape{ inds(ii) }.lowres.V , 2 ) ) ) ];
end

%%% Add a cube to mark shape number 1
%%% tg -- maybe uncomment this block back?
% if( reference )
%     center = @(X) X-repmat(mean(X,2),1,size(X,2));
%     tmpV = center([1 1 1 ; -1 1 -1 ; -1 -1 1 ; 1 -1 -1]');
%     tmpF = [0 1 2 ; 0 2 3 ; 0 3 1 ; 3 2 1]'+1 ; % Have to be 1-indexed
%     
%     F = [ F tmpF + size(V,2) ];
%     V = [ V ( tmpV     - repmat( [ offset 0 offset ]' , 1 , size(tmpV,2) ) ) ];
%     F = [ F tmpF + size(V,2) ];
%     V = [ V ( 0.5*tmpV - repmat( [ 0 0 offset ]' , 1 , size(tmpV,2) ) ) ];
% end

write_off(filename,V,F);

end