function ga = globalize(pa, tree, base, type)
% Takes a pairwise alignment (pa) and a tree and returns
% the global alignment (ga) obtained by propagating through the tree
% Base is the index of the element whose ga is the identity

n  = size(tree, 1);
[r,c] = find(tree);
mm = min(r(1),c(1));
MM = max(r(1),c(1));
N  = size( pa.P{mm,MM}, 2);

ga.R = cell(1, n);
ga.P = cell(1, n);

BaseDistMatrix = pa.d; %% pa.d is upper-triangular!
BaseDistMatrix = BaseDistMatrix-diag(diag(BaseDistMatrix));
BaseDistMatrix = BaseDistMatrix + BaseDistMatrix'; %% upper-triangular!

tD = BaseDistMatrix;
tD = tD+diag(Inf(size(tD,1),1));
epsilon = mean(min(tD, [] ,2));
adjMat = exp(-tD.^2/epsilon^2);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% pa.R{j,k} acts on shape k %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
RCell = cell(size(pa.R));
for j=1:size(RCell,1)
    for k=(j+1):size(RCell,2)
        RCell{j,k} = pa.R{j,k}; %% this is good --- pa.R is also upper-triangular
        RCell{k,j} = RCell{j,k}';
    end
end

if strcmpi(type, 'mst')
    for ii = 1:n
        [dist, pat] = graphshortestpath(tree+tree', ii, base);
        P = speye(N);
        R = eye(3);
        for jj = 2:length(pat)
            if(pat(jj-1) > pat(jj))
                P = P * pa.P{ pat(jj), pat(jj-1) };
                R = pa.R{ pat(jj) , pat(jj-1) } * R;
            else
                P = P * pa.P{ pat(jj-1), pat(jj) }';
                R = pa.R{ pat(jj-1) , pat(jj) }' * R;
            end 
        end
        ga.R{ ii } = R;
        ga.P{ ii } = P;
    end
    
    MSTPerEdgeFrustVec =...
        getPerEdgeFrustFromEdgePot(adjMat, RCell, cellfun(@(x) x', ga.R, 'UniformOutput', false));
    
    ga.TotalFrust = sum(MSTPerEdgeFrustVec);
    
elseif strcmpi(type, 'spec')    
    [wGCL, wGCL_Dvec, wGCL_W] = assembleGCL(adjMat, RCell, 3);
    if ~issymmetric(wGCL)
        warning('wGCL not symmetric!');
        wGCL = triu(wGCL,1);
        wGCL = wGCL+wGCL'+eye(size(wGCL));
    end
    if ~issymmetric(wGCL_W)
        warning('wGCL_W not symmetric!');
        wGCL_W = triu(wGCL_W,1);
        wGCL_W = wGCL_W+wGCL_W';
    end

    [RelaxSolCell_SPC, RelaxSolMat_SPC] = syncSpecRelax(wGCL, 3, wGCL_Dvec);
    
    for ii = 1:n
        ga.R{ii} = RelaxSolCell_SPC{ii}';
        if(ii > base)
            ga.P{ii} = double(pa.P{ base, ii });
        else
            ga.P{ii} = double(pa.P{ ii, base })';
        end
    end
    for ii=1:length(ga.P)
        if isempty(ga.P{ii})
            ga.P{ii} = speye(N);
            break
        end
    end
    
    SPCPerEdgeFrustVec =...
        getPerEdgeFrustFromEdgePot(adjMat, RCell, cellfun(@(x) x', ga.R, 'UniformOutput', false));
    ga.TotalFrust = sum(SPCPerEdgeFrustVec);
        
elseif strcmpi(type, 'sdp')
    [wGCL, wGCL_Dvec, wGCL_W] = assembleGCL(adjMat, RCell, 3);
    if ~issymmetric(wGCL)
        warning('wGCL not symmetric!');
        wGCL = triu(wGCL,1);
        wGCL = wGCL+wGCL'+eye(size(wGCL));
    end
    if ~issymmetric(wGCL_W)
        warning('wGCL_W not symmetric!');
        wGCL_W = triu(wGCL_W,1);
        wGCL_W = wGCL_W+wGCL_W';
    end

    run ../software/cvx/cvx_startup.m
    [RelaxSolCell_SDP, RelaxSolMat_SDP] = syncSDPRelax(wGCL, 3, wGCL_Dvec);
    
    for ii = 1:n
        ga.R{ii} = RelaxSolCell_SDP{ii}';
        if(ii > base)
            ga.P{ii} = double(pa.P{ base, ii });
        else
            ga.P{ii} = double(pa.P{ ii, base })';
        end
    end
    for ii=1:length(ga.P)
        if isempty(ga.P{ii})
            ga.P{ii} = speye(N);
            break
        end
    end
    
    SDPPerEdgeFrustVec =...
        getPerEdgeFrustFromEdgePot(adjMat, RCell, cellfun(@(x) x', ga.R, 'UniformOutput', false));
    ga.TotalFrust = sum(SDPPerEdgeFrustVec);

else
    error(['unknown type: ' type]);
end
