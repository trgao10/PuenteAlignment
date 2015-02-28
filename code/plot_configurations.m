function plot_configurations( config , ind ) 

figure('renderer','opengl');  hold on;
for ii = 1 : length(config)
    if( sum(find(ind==ii))>0 )
        scatter3( config{ii}(1,:), config{ii}(2,:), config{ii}(3,:),20,ii*ones(1,size(config{ii},2)),'filled');
    end
end
axis equal;


