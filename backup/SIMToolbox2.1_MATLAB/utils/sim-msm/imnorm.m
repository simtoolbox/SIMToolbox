function [IM,varargout] = imnorm(IM,varargin)
% IM ... input/output image
% varargin{1} = max(IM);
% varargin{2} = min(IM);
%
% varargout{1} = max(IM);
% varargout{2} = min(IM);

if nargin == 1
    IMmin = min(IM(:));
    IMmax = max(IM(:));
elseif nargin == 2
    IMmin = min(IM(:));
    if ~isnan(varargin{1}), IMmax = varargin{1}; else, IMmax = max(IM(:)); end
elseif nargin == 3
    if ~isnan(varargin{2}), IMmin = varargin{2}; else, IMmin = min(IM(:)); end
    if ~isnan(varargin{1}), IMmax = varargin{1}; else, IMmax = max(IM(:)); end
end

IM  = IM - IMmin;
IM = IM./IMmax;

varargout{1} = IMmax;
varargout{2} = IMmin;