function map = preset_colormap(N,varargin)
% Wrapper for any COLORMAP function, to provide preset parameter values.
%
%%% Syntax %%%
%
%   preset_colormap(@fun,p1,p2,...,pN) % store function with any parameters
%   map = preset_colormap(N)           % generate colormap
%   map = preset_colormap              % generate colormap
%
%% Examples %%
%
%   >> preset_colormap(@cubehelix,0.25,-0.67,1.5,1)
%   >> colormap(preset_colormap)
%
%   >> preset_colormap(5)
%   ans =
%            0         0         0
%       0.1055    0.2788    0.4895
%       0.1660    0.6705    0.4961
%       0.6463    0.8479    0.5076
%       1.0000    1.0000    1.0000
%
%   >> preset_colormap(@brewermap,'PuOr')
%   >> load topo
%   >> load coast
%   >> figure
%   >> worldmap(topo, topolegend)
%   >> contourfm(topo, topolegend);
%   >> contourcmap('preset_colormap', 'Colorbar','on', 'Location','horizontal','TitleString','Contour Intervals in Meters');
%   >> plotm(lat, long, 'k')
%
%% Dependencies %%
%
% * MATLAB R2008a or later.
%
% See also BREWERMAP CUBEHELIX CMOCEAN LBMAP COLORMAP CONTOURCMAP
persistent fnh arg
% Release | Feature
% --------|--------
% R2004b  | isscalar, function handles
% R2008a  | assert(cond, msgID, msg, printf format string)
% R2014b  | HG2 groot, F.Colormap in cmDefaultN     [HG1 fallback provided]
%
if nargin==0 % Default N same as MATLAB colormaps.
	N = cmDefaultN();
elseif nargin==1 && isnumeric(N)
	assert(isscalar(N) && isreal(N) && fix(N)==N,...
		'SC:preset_colormap:N:NotRealScalarNumeric',...
		'First input <N> must be a real scalar numeric of the colormap size.')
	N = double(N);
else % Store function handle and parameter values.
	assert(isa(N,'function_handle'),...
		'SC:preset_colormap:N:NotFunctionHandle',...
		'First input <N> must be a function handle to a colormap function.')
	fnh = N;
	arg = varargin;
	return
end
%
map = fnh(N,arg{:});
%
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%preset_colormap
function N = cmDefaultN()
% Get the colormap size from the current figure or default colormap.
try % >=R2014b, HG2
	F = get(groot,'CurrentFigure');
catch %#ok<CTCH> HG1
	N = size(get(gcf,'colormap'),1);
	return
end
if isempty(F)
	N = size(get(groot,'DefaultFigureColormap'),1);
else
	N = size(F.Colormap,1);
end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%cmDefaultN
%
% Copyright (c) 2014-2026 Stephen Cobeldick
%
% Licensed under the Apache License, Version 2.0 (the "License");
% you may not use this file except in compliance with the License.
% You may obtain a copy of the License at
%
% http://www.apache.org/licenses/LICENSE-2.0
%
% Unless required by applicable law or agreed to in writing, software
% distributed under the License is distributed on an "AS IS" BASIS,
% WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
% See the License for the specific language governing permissions and limitations under the License.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%license