function coords = mds(dissimilarity)
%MDS Summary of this function goes here
%   Detailed explanation goes here

tmp = dissimilarity; %tmp=sqrt(dissimilarity);
tmp = tmp-diag(diag(tmp));
tmp = (tmp+tmp')/2;
coords = mdscale(tmp,2)';
if( length(find(dissimilarity==0)) > size(dissimilarity,2))
    display(['Dissimilarity has more than n zeros, maybe its incomplete']);
end

end

