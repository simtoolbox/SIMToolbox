function cmap=isolum(n,varargin)
%ISOLUM Isoluminant-Colormap compatible with red-green color perception deficiencies
%
%	Written by Matthias Geissbuehler - matthias.geissbuehler@a3.epfl.ch
%	January 2013
%
%   Features:
%     1) All colors have the same luminescence (ideal for lifetime
%        images that will be displayed with an additional transparency map
%        to "mask" places where the lifetime is not well defined)
%     2) Color vision deficient persons can only see reduced color: as much
%        as 10% of adult male persons have a red-green defiency (either
%        Deuteranope  or Protanope) -> as a result they can only distinguish
%        between blue and yellow. A colormap which is "save" for color vision
%        deficient persons is hence only based on these colors.
%        However: people with normal vision DO have a larger space of colors
%        available: it would be a pity to discard this freedom. So the goal
%        must be a colormap that is both using as many colors as possible
%        for normal-sighted people as well as a colormap that will "look"
%        blue-yellow to people with colorblindness without transitions that
%        falsify the information by including a non-distinct transitions
%        (as is the case for many colormaps based on the whole spectrum
%        (ex. rainbow or jet).
%        That's what this colormap here tries to achieve.
%     3) In order to be save for publications, the colormap uses colors that
%        are only from the CMYK colorspace (or at least not too far)
%
%
%   See also: ametrine, morgenstemning
%
%
%   Please feel free to use this colormap at your own convenience.
%   A citation to the original article is of course appreciated, however not "mandatory" :-)
%   
%   M. Geissbuehler and T. Lasser
%   "How to display data by color schemes compatible with red-green color perception deficiencies
%   Optics Express, 2013
%
%
%   For more detailed information, please see:
%   http://lob.epfl.ch -> Research -> Color maps
%
%
%   Usage:
%   cmap = isolum(n)
%
%   All arguments are optional:
%
%   n           The number of elements (256)
%
%   Further on, the following options can be applied
%     'gamma'    The gamma of the monitor to be used (1.8)
%     'minColor' The absolute minimum value can have a different color
%                ('none'), 'white','black','lightgray', 'darkgray'
%                or any RGB value ex: [0 1 0]
%     'maxColor' The absolute maximum value can have a different color
%     'invert'   (0), 1=invert the whole colormap
%
%   Examples:
%     figure; imagesc(peaks(200));
%     colormap(isolum)
%     colorbar
%
%     figure; imagesc(peaks(200));
%     colormap(isolum(256,'gamma',1.8,'minColor','black','maxColor',[0 1 0]))
%     colorbar
%
%     figure; imagesc(peaks(200));
%     colormap(isolum(256,'invert',1,'minColor','white'))
%     colorbar
%
%
%
%
%
%
%     This colormap is free software: you can redistribute it and/or modify
%     it under the terms of the GNU General Public License as published by
%     the Free Software Foundation, either version 3 of the License, or
%     (at your option) any later version.
% 
%     This colormap is distributed in the hope that it will be useful,
%     but WITHOUT ANY WARRANTY; without even the implied warranty of
%     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%     GNU General Public License for more details.
% 
%     You should have received a copy of the GNU General Public License
%     along with this program.  If not, see <http://www.gnu.org/licenses/>.

%   Copyright 2013 Matthias Geissbuehler - matthias.geissbuehler@a3.epfl.ch
%   $Revision: 3.0 $  $Date: 2013/01/29 12:00:00 $
p=inputParser;
p.addParameter('gamma',1.8, @(x)x>0);
p.addParameter('minColor','none');
p.addParameter('maxColor','none');
p.addParameter('invert',0, @(x)x==0 || x==1);

if nargin==1
    p.addRequired('n', @(x)x>0 && mod(x,1)==0);
    p.parse(n);
elseif nargin>1
    p.addRequired('n', @(x)x>0 && mod(x,1)==0);
    p.parse(n, varargin{:});
else
    p.addParameter('n',256, @(x)x>0 && mod(x,1)==0);
    p.parse();
end
config = p.Results;
n=config.n;

%the ControlPoints and the spacing between them
%the ControlPoints in a very isoluminescence case
cP(:,1) = [90  190 245]./255; k(1)=1;  %cyan at index 1
cP(:,2) = [157 157 200]./255; k(2)=16; %purple at index 16
cP(:,3) = [220 150 130]./255; k(3)=32; %purple at index 32
cP(:,4) = [245 120 80 ]./255; k(4)=43; %redish at index 43
cP(:,5) = [180 180 0  ]./255; k(5)=64; %yellow at index 64

% Making them strictly isoluminescent
tempgraymap = mean((cP).^config.gamma,1);
tempgraymap = tempgraymap .^(1/config.gamma);
cP(1,:)=cP(1,:)./tempgraymap.*mean(tempgraymap);
cP(2,:)=cP(2,:)./tempgraymap.*mean(tempgraymap);
cP(3,:)=cP(3,:)./tempgraymap.*mean(tempgraymap);

for i=1:4  % interpolation between control points, while keeping the luminescence constant
    f{i} = linspace(0,1,(k(i+1)-k(i)+1))';  % linear space between these controlpoints
    ind{i} = linspace(k(i),k(i+1),(k(i+1)-k(i)+1))';
    
    cmap(ind{i},1) = ((1-f{i})*cP(1,i)^config.gamma + f{i}*cP(1,i+1)^config.gamma).^(1/config.gamma);
    cmap(ind{i},2) = ((1-f{i})*cP(2,i)^config.gamma + f{i}*cP(2,i+1)^config.gamma).^(1/config.gamma);
    cmap(ind{i},3) = ((1-f{i})*cP(3,i)^config.gamma + f{i}*cP(3,i+1)^config.gamma).^(1/config.gamma);
end


% normal linear interpolation to achieve the required number of points for the colormap
cmap = abs(interp1(linspace(0,1,size(cmap,1)),cmap,linspace(0,1,n)));

if config.invert
    cmap = flipud(cmap);
end

if ischar(config.minColor)
    if ~strcmp(config.minColor,'none')
        switch config.minColor
            case 'white'
                cmap(1,:) = [1 1 1];
            case 'black'
                cmap(1,:) = [0 0 0];
            case 'lightgray'
                cmap(1,:) = [0.8 0.8 0.8];
            case 'darkgray'
                cmap(1,:) = [0.2 0.2 0.2];
        end
    end
else
    cmap(1,:) = config.minColor;
end
if ischar(config.maxColor)
    if ~strcmp(config.maxColor,'none')
        switch config.maxColor
            case 'white'
                cmap(end,:) = [1 1 1];
            case 'black'
                cmap(end,:) = [0 0 0];
            case 'lightgray'
                cmap(end,:) = [0.8 0.8 0.8];
            case 'darkgray'
                cmap(end,:) = [0.2 0.2 0.2];
        end
    end
else
    cmap(end,:) = config.maxColor;
end
