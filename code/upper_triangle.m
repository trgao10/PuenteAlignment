function M=upper_triangle( nn )
%Creates a sparse square matrix with 1's above the diagonal,
%zero everywhere else
M=sparse(nn,nn);
[tmpi,tmpj]=ndgrid(1:nn,1:nn);
M(find(tmpj>tmpi))=1;
end