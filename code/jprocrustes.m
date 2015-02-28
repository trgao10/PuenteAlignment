function [R, d] = jprocrustes(x, y) 
%Computes the best rotation that when applied to 
%y lies closest to x. No scaling.
A = x*y';
[u,s,v]=svd(A);
R=u*v';

tmp = x-R*y;
d = sqrt(sum(sum(tmp.^2))); % Notice there IS the square root
end