function [idx, val] = findlocmax2d(x, thr, nbr)
% Find local maxima in a 4-neighbourhood
%
% USE:
%   [val,idx] = findlocmax2d(X)               ... all local maxima
%   [val,idx] = findlocmax2d(X, thr)          ... local maxima above threshold
%
% IN:
%   x       ... [m x n] matrix
%   thr     ... local maxima threshold 
%
% OUT:
%  val      ... functional values
%  idx      ... index coordinates

[m,n] = size(x);

% find all local maxima in 4-neighbourhood
idx = find([false(1,n); diff(x(1:end-1,:),1,1) >= 0 & diff(-x(2:end,:),1,1) >= 0; false(1,n)] & ...
           [false(m,1), diff(x(:,1:end-1),1,2) >= 0 & diff(-x(:,2:end),1,2) >= 0, false(m,1)]) ;

% get only points above threshold
if nargin > 1 && ~isempty(thr)
  idx = idx(x(idx) > thr);
end;

% functional value of points
val = x(idx);

%eof