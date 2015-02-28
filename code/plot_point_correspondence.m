function plot_point_correspondence(X,Y,Rot)
%Plots point correspondences between shapes

figure('renderer','opengl'); hold on;
Y=Rot*Y;
plot3(X(1,:),X(2,:),X(3,:),'b.');
plot3(Y(1,:),Y(2,:),Y(3,:),'r.');
for kk=1:size(Y,2) 
    plot3([X(1,kk) Y(1,(kk))],[X(2,kk) Y(2,kk)],[X(3,kk) Y(3,kk)],'k-');
end
axis equal;

% 
% global bones;
% 
% %Bring bone ii and jj to coordinates of bone 1
% Rotation_i = bones.globalrotations(3*(ii-1)+1:3*(ii-1)+3,1:3)';
% Rotation_j = bones.globalrotations(3*(jj-1)+1:3*(jj-1)+3,1:3)';
% Vinew=Rotation_i*bones.verts{ind_sample_size}{ii};
% Vjnew=Rotation_j*bones.verts{ind_sample_size}{jj};
% 
% %%Find nearest neighbors
% %[indi,disti]=knnsearch(Vjnew',Vinew');
% %[indj,distj]=knnsearch(Vinew',Vjnew');
% 
% %Use the correspondences given by globalpc
% indi = invert_permutation(bones.globalpc{ind_sample_size}{ii}( invert_permutation(bones.globalpc{ind_sample_size}{jj}) ));
% %indi = invert_permutation(bones.globalpc{ind_sample_size}{ii}(invert_permutation(bones.globalpc{ind_sample_size}{jj})))
% 
% %Make the plot
% figure('renderer','opengl'); hold on;
% %figure; hold on;
% %title(['Point correspondences - ' bones.names{ii} ' (blue) <-> ' bones.names{jj} '(red)'  ]);
% plot3(Vinew(1,:),Vinew(2,:),Vinew(3,:),'b.');
% plot3(Vjnew(1,:),Vjnew(2,:),Vjnew(3,:),'r.');
% for kk=1:size(Vinew,2) 
%     plot3([Vinew(1,kk) Vjnew(1,indi(kk))],[Vinew(2,kk) Vjnew(2,indi(kk))],[Vinew(3,kk) Vjnew(3,indi(kk))],'k-');
%     %plot3([Vjnew(1,kk) Vinew(1,indj(kk))],[Vjnew(2,kk) Vinew(2,indj(kk))],[Vjnew(3,kk) Vinew(3,indj(kk))],'m-');
% end
% %plot_mesh(Rotation_j*bones.lowres{jj}.verts,bones.lowres{jj}.faces);
% axis equal;