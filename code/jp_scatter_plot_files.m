function jp_scatter_plot_files( points , varargin )
% Write files that jp_scatter_plot.py uses to generate a scatter plot with
% polygons
% Arguments:
%   points - Matrix with
%       (1) First row are  x-coords
%       (2) Second row are y-coords
%       (3) Thrid row is a group id (integer, starting at 0)
%   points_fn - (Optional) a filename to save points
%   hull_fn   - (Optional) a filename to save the convex hull
%
% This file will write 'points.txt' and 'hull.txt', which should be input
% to the python script, i.e. run
%
% jp_scatter_plot.py points.txt hull.txt file_name 
%
% Jesus Puente 20130327.

%Parse optional arguments
points_fn = 'points.txt';
hull_fn   = 'hull.txt';
if( nargin == 2 )
    points_fn = varargin{1};
end
if( nargin == 3)
    hull_fn   = varargin{2};
end

%Write points file
dlmwrite(points_fn , points, ' ');

%Compute convex hull and save to hull.txt
hull=[];
groups = unique(sort(points(3,:)));
for kk = 0 : max(groups)
    inds = find(points(3,:)==kk);
    chi = convhull( [points(1:2,inds)]' );
    hull = [hull points(1:3,inds(chi)) ];
end
dlmwrite(hull_fn, hull, ' ');

%For some reason, importing scipy inside the jp_scatter_plot script gives a
%MATLAB error:
%system(['python /home/jpuente/bin/jp_scatter_plot.py points.txt hull.txt ' name ]);
    
