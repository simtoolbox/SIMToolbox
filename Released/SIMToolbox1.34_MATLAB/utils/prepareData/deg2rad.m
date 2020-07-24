function angleInRadians = deg2rad(angleInDegrees)
% DEG2RAD Convert angles from degrees to radians
%
%   angleInRadians = DEG2RAD(angleInDegrees) converts angle units from
%   degrees to radians for each element of angleInDegrees. In the case of
%   complex input, real and imaginary parts are converted separately.
%
%   Example:
%      % Compute the tangent of a 45-degree angle
%      tan(deg2rad(45))
%
%   Class support for input angleInDegrees:
%      float: double, single
%
%   See also: RAD2DEG

% Copyright 1996-2014 The MathWorks, Inc.

angleInRadians = (pi/180) * angleInDegrees;