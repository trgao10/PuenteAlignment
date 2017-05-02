function X = get_subsampled_shape( dir, id, N, ssType ) 
%Read already subsampled file, if it exists
%If it doesnt or it does not have enough points, read original off file, subsample, save the subsampled file, and return subsample

sub_off_fn = [ dir 'subsampled' filesep num2str(id) '.off' ];
off_fn     = [ dir 'original' filesep num2str(id) '.off' ];

if exist( sub_off_fn, 'file' )
    [ X, tmp ]       = read_off( sub_off_fn );
    n_subsampled_pts = size(X, 2);
else
    X                = [];
    n_subsampled_pts = 0;
end

if ( n_subsampled_pts < N )
    [V,F] = read_off( off_fn );
    if strcmpi(ssType, 'fps')
        ind   = subsample(V, N, X);
    elseif strcmpi(ssType, 'gpr')
        ind = gplmk(V, F, N, X);
    else
        error('unknown subsample type!');
    end
    X     = V ( :, ind );
    if( ~exist([dir filesep 'subsampled'], 'dir') )
        mkdir([dir filesep 'subsampled']);
    end
    write_off( sub_off_fn, X, [1 2 3]'); %write_off breaks if there are no faces
end

end
