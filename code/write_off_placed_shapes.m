function write_off_placed_shapes( filename, coords, ds , ga, varargin )
% Write off file with the meshes in their respective locations according

%Make sure we have 3D coordinates
if( size(coords,1) == 2 )
    coords = [ coords; zeros(1,size(coords,2) )];
end

view_rot = eye(3);
if( nargin >=5 )
view_rot = varargin{1};
end

% Compute MST and use as default parameter for tree
dbp     = squareform(pdist(coords'));
mst     = graphminspantree(sparse(dbp));
tree    = mst;
if( nargin >=6 )
tree    = varargin{2};
end

% Compute adequate scale for resizing the lowres meshes
tree = (tree>0).*dbp;
[r,c,v] = find(tree);
sc      = mean(v)/8;

%Create vertices and faces of the resulting off file
V=[]; F=[];
for ii = 1 : ds.n
    if ( det( ga.R{ ii } ) < 0 ) % Need to invert faces orientation
        F = [ F ( ds.shape{ ii }.lowres.F([2 1 3],:) + size(V,2) ) ];
    else
        F = [ F ( ds.shape{ ii}.lowres.F + size(V,2) ) ];
    end
    V = [ V ( sc * view_rot * ga.R{ ii } * ds.shape{ ii }.lowres.V + repmat( coords(:,ii) , 1, size( ds.shape{ ii }.lowres.V , 2 ) ) ) ];
end

%Add tree to the off file
g = 0.125 * sc;
Vl = diag([g g 1]) * [ 1 -1 -1 1 1 -1 -1 1 ; 1 1 -1 -1 1 1 -1 -1; 0 0 0 0 1 1 1 1];
Fl = [1 4 3 3 3 6 2 2;  4 8 8 7 6 3 5 1; 5 5 4 8 7 2 6 5 ];

for kk = 1 : length( r )
    s = coords(:,r(kk));
    e = coords(:,c(kk));
    Vedge = diag([1 1 v(kk)])*Vl;
    tmpv = (e - s)/v(kk);
    [Rot , tmp] = qr([ tmpv randn(3,2)]) ;
    if( Rot(1,1) / tmpv(1) < 0 ) Rot = -Rot;end
	if( det(Rot) < 0 ) Rot = Rot * [1 0 0 ;   0 0 1; 0 1 0]; end
    Rot =  Rot * [0 0 1; 0 1 0; 1 0 0];
    Vedge = Rot * Vedge + repmat(s-[0;0;-5*g],1,size(Vedge,2));
    F = [ F ( Fl + size(V,2) ) ];
    V = [ V Vedge ];
end

write_off( filename, V, F );



%%



