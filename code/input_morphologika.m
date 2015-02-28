function dataset = input_morphologika( filename )
%Read information from morphologika into dataset object
%
%Jesus Puente

dataset.filename = filename;
fid = fopen ( filename , 'r' );

while( ~feof(fid) )
    line = lower(strtrim(fgetl(fid)));
    if( strcmp(line,'[individuals]') )
        dataset.individuals = fscanf(fid,'%d');
    elseif( strcmp(line,'[landmarks]') )
        dataset.landmarks = fscanf(fid,'%d');
    elseif( strcmp(line, '[dimensions]') )
        dataset.dimensions = fscanf(fid,'%d');
    elseif( strcmp(line, '[names]') )
        dataset.names = cell( dataset.individuals, 1 );
        for ii = 1 : dataset.individuals
            dataset.names{ii} = strtrim(fgetl(fid));
        end
    elseif( strcmp(line,'[groups]') )
        line = strtrim(fgetl(fid));
        [number_start, number_end] = regexp( line, '\d*' );
        [name_start, name_end ] = regexp(line,'\D*');
        dataset.number_of_groups = length(number_start);
        %         dataset.group_name = cell(dataset.number_of_groups,1);
        %         dataset.group_inds  = cell(dataset.number_of_groups,1);
        %         cumul=0;
        %         for ii = 1: dataset.number_of_groups
        %             dataset.group_name{ii}=line(name_start(ii):name_end(ii));
        %             dataset.group_inds{ii}=[cumul+1 : cumul+str2num(line(number_start(ii):number_end(ii)))];
        %             cumul = cumul + str2num(line(number_start(ii):number_end(ii)));
        %         end
        dataset.group = zeros( 1, dataset.individuals);
        dataset.group_name = cell(dataset.number_of_groups,1);
        cumul=0;
        for ii = 1: dataset.number_of_groups
            dataset.group_name{ii}=line(name_start(ii):name_end(ii));
            dataset.group([cumul+1 : cumul+str2num(line(number_start(ii):number_end(ii)))])=ii;
            cumul = cumul + str2num(line(number_start(ii):number_end(ii)));
        end
    elseif( strcmp(line,'[rawpoints]') )        
        for ii = 1 : dataset.individuals
            %Eat up newlines
            label = strtrim(fgetl(fid));
            while(length(label)==0) label = strtrim(fgetl(fid)); end;
            dataset.labels{ii} = label;
            [ coords ] = fscanf(fid,'%f',dataset.dimensions * dataset.landmarks);
            dataset.verts{ii} = reshape(coords, dataset.dimensions, dataset.landmarks);     
        end
    end
end