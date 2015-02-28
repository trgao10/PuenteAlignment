function write_files_aligned( ds , ga, input_dir, output_dir, type, scale)
% Write aligned offs, e.g. for Kate's analysis
% Note: ply is VERY slow because of write_ply

for kk = 1: ds.n
    % Read original off file
    [V,F] = read_off( [input_dir ds.ids{ kk } '.off' ] );
    %Scale according to highest resolution point cloud
    V = V-repmat(ds.shape{kk}.center,1,size(V,2));
    if( scale )
        V = V / ( ds.shape{kk}.scale / sqrt( ds.N( ds.K ) ) );
    end
    
    %Rotate according to ga
    if ( det( ga.R{ kk } ) < 0 ) % Need to invert faces orientation
        F = F([2 1 3],:);
    end
    V = ga.R{ kk } * V ;
    
    %Write output
    if( strcmp(type,'off') )
        write_off( [output_dir ds.ids{kk} '.off'], V, F);
    elseif( strcmp(type,'ply'))
        write_ply(V,F,[output_dir ds.ids{kk} '.ply']);
    else
        error('Unrecognized file format');
    end
    
    display( [ 'Shape ' num2str( kk ) ' done. '] );
end

    
end
