function write_morphologika(filename , ds , ga , varargin)
% Write shape information to a Morphologika file

%Arguments
remove = [];
if( nargin == 4 )
    toremove = varargin{1};
end

ind = [ 1 : ds. n ];
ind ( remove ) = [];

nn  = length( ind );

global file; file=[]; 

add('[Individuals]');
add( nr ( nn ) );
add('[landmarks]' );
add( nr ( ds.N( ga.k ) ) );
add('[dimensions]');
add( nr ( 3 ) );
add('[names]');
for ll = 1:nn
    add( ds.names{ ind(ll) } );
end
addnl;
add('[rawpoints]');
for ll= 1:nn
    addnl;
    display( ['Adding bone ' num2str( ind(ll) ) ] );
    add([ ''''  ds.names{ ind(ll) } ]);
    addnl;
    
%     V = ga.R{ ind(ll) } * ds.shape{ ind(ll) }.X{ ga.k } * ga.P{ ind(ll) };
    V = ga.R{ind(ll)} * ds.shape{ind(ll)}.X{ga.k} * ga.P{ind(ll)} * (ds.shape{ind(ll)}.scale/sqrt(ds.N(ds.K)));
    
    for vv = 1 : ds.N( ga.k ) 
        add( [ nre( V(1,vv) ) ' ' nre( V(2,vv) ) ' ' nre( V(3,vv) ) ]);
    end 
end

fileID = fopen( filename, 'w' );
fprintf( fileID, file );
fclose(fileID);
end

function add( txt ) 
global file;
file = [ file  txt '\n' ];
end

function str = nr( num ) 
str=num2str(num);
end

function str = nre( num ) 
str=num2str(num,'%12.7e');
end

function addnl
global file;
file = [file '\n'];
end