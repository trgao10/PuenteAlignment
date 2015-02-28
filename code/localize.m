function pa = localize( ga )
%Takes a global alignment and returns a pairwise one

n = size( ga.R , 2);
a = 1; % the base


pa.R      = cell ( n, n );
pa.P      = cell ( n, n );
for ii = 1 : n
    for jj = 1 : n
        pa.R{ ii , jj } = ga.R{ ii }' * ga.R{ jj }  ;
        pa.P{ ii , jj } = ga.P{ jj }  * ga.P{ ii  }';
    end
end