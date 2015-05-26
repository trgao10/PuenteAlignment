function plot_tree ( dissimilarity, tree, names, method, classes, jtitle )
% Embed points with given dissimilarity and simultaneously plot
% a tree connecting them
% Notice, ot all parameters are used with all methods
% Knn and epsilon neighs parameters spec. below here

k=5; %nearest neighbors ( must modify interface so this comes from arguments )
eps=5; %epsilon threshold

nn=size(dissimilarity,2);

% %Plot the tree
% figure; imagesc(tree);
% title('Connectivity of tree');

tree = (tree+tree')/2; tree=tree>0;

if(strcmp(method,'random'))
    coords=rand(2,100);
    ind=CORR_spread_points_euclidean(coords',1,size(dissimilarity,1));
    coords=coords(:,ind);
    figure_flag = 1;
elseif (strcmp(method,'circle'))
    %Disregard dissimilarity, plot points on a circle
    coords=[ cos(0:2*pi/nn:2*pi-.0001) ; sin(0:2*pi/nn:2*pi-.0001) ];
    figure_flag = 1;
elseif(strcmp(method,'mds'))
    tmp=dissimilarity; %tmp=sqrt(dissimilarity);
    for ll=1:nn  %Need to set the diagonal to 0, otherwise mdscale complains
        tmp(ll,ll)=0;
    end
    tmp=(tmp+tmp')/2;
    coords=cmdscale(tmp,2)';
%     coords=mdscale(tmp,2)';
    if( length(find(dissimilarity==0)) > nn )
        display(['Dissimilarity has more than n zeros, maybe its incomplete']);
    end
    figure_flag = 1;
elseif(strcmp(method,'3Dmds'))
    tmp=dissimilarity; %tmp=sqrt(dissimilarity);
    for ll=1:nn  %Need to set the diagonal to 0, otherwise mdscale complains
        tmp(ll,ll)=0;
    end
    tmp=(tmp+tmp')/2;
    coords=mdscale(tmp,3)';
    if( length(find(dissimilarity==0)) > nn )
        display(['Dissimilarity has more than n zeros, maybe its incomplete']);
    end
    figure_flag = 1;
elseif(strcmp(method,'isomap_tree_topology'))
    [tmp,coords]=jp_isomap(dissimilarity,tree,2,[], classes);
    figure_flag = 1;
elseif(strcmp(method,'isomap_knn'))
    T=jp_knn(dissimilarity, k);
    [tmp,coords]=jp_isomap(dissimilarity, T, 2, [], classes );
    figure_flag = 1;
elseif(strcmp(method,'isomap_epsilon_neigh'))
    tag=['epsilon = ' num2str(eps) ' thres.'];
    [tmp,coords]=jp_isomap(dissimilarity, dissimilarity<eps, 2, [ ], classes );
    figure_flag = 1;
elseif(strcmp(method,'lap_eig_combinatorial_tree'))
    [tmp,coords]=laplacian_eigenmaps(tree,tree,1,[ jtitle '- lap_eig_combinatorial_tree '],classes);
    figure_flag = 1;
elseif(strcmp(method,'lap_eig_combinatorial_knn'))
    %This one breaks, must check why
    T = jp_knn(dissimilarity,k);
    [tmp,coords]=laplacian_eigenmaps(T,T,1,[ jtitle '- lap_eig_combinatorial_knn '], classes);
    figure_flag = 1;
else
    error('Method is not recognized');
end

if(figure_flag)
    if( strcmp(method,'3Dmds'))
        figure; hold on;
        jp_gplot(tree,coords');
        scatter3(coords(1,:),coords(2,:),coords(3,:),30,classes,'filled');
        title([ jtitle '. Embed: ' method ]);
        for kk=1:nn
            text(coords(1,kk)-0.00,coords(2,kk),coords(3,kk),names{kk},'Interpreter','none');
        end
        axis([min(coords(1,:))-0.3 max(coords(1,:))+0.3 min(coords(2,:))-0.3 max(coords(2,:))+0.3 min(coords(3,:))-0.3 max(coords(3,:))+0.3]);
    else
        figure; hold on;
        gplot(tree,coords');
        scatter(coords(1,:),coords(2,:),25,classes,'filled');
        title([ jtitle '. Embed: ' method ]);
        for kk=1:nn
            text(coords(1,kk)-0.00,coords(2,kk),names{kk},'Interpreter','none');
        end
        axis([min(coords(1,:))-0.3 max(coords(1,:))+0.3 min(coords(2,:))-0.3 max(coords(2,:))+0.3 ]);
    end
end

end

function jp_gplot( tree, coords )
[r,c,v]=find(tree);
for kk=1:length(r)
    plot3([ coords(r(kk),1) coords(c(kk),1) ], [ coords(r(kk),2) coords(c(kk),2) ], [ coords(r(kk),3) coords(c(kk),3) ], 'Interpreter', 'none' );
end
end



% %%%%
% figure; hold on;
% %gplot3(tree,coords');
% plot3(coords(1,:),coords(2,:),coords(3,:),'rx');
% plot3(coords(1,:),coords(2,:),coords(3,:),'ro');
% plot3(coords(1,1),coords(2,1),coords(3,:),'k.');
% title(['Minimal Spanning Tree, ' bones.type_of_bone_extended]);
% for kk=1:bones.nn
%     text(coords(1,kk)-0.1,coords(2,kk),coords(3,:),bones.names{kk});
% end
% axis([min(coords(1,:))-0.3 max(coords(1,:))+0.3 min(coords(2,:))-0.3 max(coords(2,:))+0.3  min(coords(3,:))-0.3 max(coords(3,:))+0.3 ]);

