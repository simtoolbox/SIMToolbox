function [IM,IMmax,IMmin] = imnorm(IM,varargin)
% IM ... input/output image
% varargin{1} = max(IM);
% varargin{2} = min(IM);
%
% varargout{1} = max(IM);
% varargout{2} = min(IM);

if any(~isfinite(IM(:)))
    finitmin = min(IM(isfinite(IM(:))));
    IM(~isfinite(IM)) = finitmin;
end

if nargin == 1
    IMmin = min(IM(:));
	IM = IM - IMmin;
    IMmax = max(IM(:));
    IM = IM./IMmax;
elseif nargin == 2
    IMmin = min(IM(:));
    IM  = IM - IMmin;
    if ~isnan(varargin{1}), IMmax = varargin{1}; else, IMmax = max(IM(:)); end
    IM = IM./IMmax;
elseif nargin == 3
    if ~isnan(varargin{2}), IMmin = varargin{2}; else, IMmin = min(IM(:)); end
    IM  = IM - IMmin;
    if ~isnan(varargin{1}), IMmax = varargin{1}; else, IMmax = max(IM(:)); end
    IM = IM./IMmax;
end