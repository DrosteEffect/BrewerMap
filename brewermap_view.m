function [map,num,typ,scheme] = brewermap_view(N,scheme) %#ok<*ISMAT>
% An interactive figure for ColorBrewer colormap selection. With demo!
%
% (c) 2014-2020 Stephen Cobeldick
%
% View Cynthia Brewer's ColorBrewer colorschemes in a figure.
%
% * Two colorbars give the colorscheme in color and grayscale.
% * A button toggles between 3D-cube and 2D-lineplot of the RGB values.
% * A button toggles an endless demo cycle through the colorschemes.
% * A button reverses the colormap.
% * 35 buttons select any ColorBrewer colorscheme.
% * Text with the colorscheme's type (Diverging/Qualitative/Sequential)
% * Text with the colorscheme's number of nodes (defining colors).
%
%%% Syntax:
% brewermap_view
% brewermap_view(N)
% brewermap_view(N,scheme)
% brewermap_view([],...)
% brewermap_view(axes/figure handles,...) % see "Adjust Colormaps"
% [map,scheme] = brewermap_view(...)
%
% Calling the function with an output argument blocks MATLAB execution until
% the figure is deleted: the final colormap and colorscheme are then returned.
%
%% Adjust Colormaps of Figures or Axes %%
%
% Only R2014b or later. Provide axes or figure handles as the first input
% and their colormaps will be updated in real-time by BREWERMAP_VIEW.
%
%%% Example:
%
% >> S = load('spine');
% >> image(S.X)
% >> brewermap_view(gca)
%
%% Input and Output Arguments %%
%
%%% Inputs (*=default):
% N = NumericScalar, an integer to define the colormap length.
%   = *[], colormap length of one hundred and twenty-eight (128).
%   = NaN, same length as the defining RGB nodes (useful for Line ColorOrder).
%   = Array of axes/figure handles. R2014b or later only.
% scheme = CharRowVector, a ColorBrewer colorscheme name.
%
%%% Outputs (these block code execution until the figure is closed!):
% map = NumericMatrix, the colormap defined when the figure is closed.
% num = NumericVector, the number of nodes defining the ColorBrewer colorscheme.
% typ = CharRowVector, the colorscheme type: 'Diverging'/'Qualitative'/'Sequential'.
%
% See also BREWERMAP CUBEHELIX RGBPLOT COLORMAP COLORMAPEDITOR COLORBAR UICONTROL ADDLISTENER

%% Input Wrangling %%
%
persistent ax2D ln2D ax3D pt3D txtH is2D cbAx cbIm pTxt pSld bEig bGrp bRev scm isr
%
new = isempty(ax2D)||~ishghandle(ax2D);
dfn = 128;
upd = false;
upb = false;
hgv = [];
nmr = dfn;
%
err = 'First input must be a real positive scalar numeric or [] or NaN.';
if nargin==0 || isnumeric(N)&&isequal(N,[])
	N = dfn;
elseif isnumeric(N)
	assert(isscalar(N),'SC:brewermap_view:NotScalarNumeric',err)
	assert(isnan(N)||isreal(N)&&isfinite(N)&&fix(N)==N&&N>0,...
		'SC:brewermap_view:NotRealPositiveNotNaN',err)
	N = double(N);
elseif all(ishghandle(N(:))) % R2014b or later
	assert(isgraphics(N(:),'axes')|isgraphics(N(:),'figure'),...
		'SC:brewermap_view:NotAxesNorFigureHandles',...
		'First input may be an array of figure or axes handles.')
	hgv = N(:);
	nmr = arrayfun(@(h)size(colormap(h),1),hgv);
	N = nmr(1);
else
	error('SC:brewermap_view:UnsupportedInput',err)
end
%
[mcs,mun,pyt] = brewermap('list');
%
% Check BREWERMAP output:
tmp = find([any(diff(double(char(pyt)),1),2);1]);
assert(isequal(tmp,[9;17;35]),'SC:brewermap_view:SchemeSequence',...
	'The BREWERMAP function returned an unexpected scheme sequence.')
%
% Default pseudo-random colorscheme:
if nargin==0 || new
	isr = false;
	scm = mcs{1+mod(round(now*1e7),numel(mcs))};
end
% Parse input colorscheme:
if nargin==2
	assert(ischar(scheme)&&ndims(scheme)==2&&size(scheme,1)==1,...
		'SC:brewermap_view:NotCharacterVector',...
		'Second input <scheme> must be a 1xN char vector.')
	% Check if a reversed colormap was requested:
	isr = strncmp(scheme,'*',1);
	scm = scheme(1+isr:end);
end
%
if isnan(N)
	N = mun(strcmpi(scm,mcs));
end
%
%% Ensure Figure Exists %%
%
% LHS and RHS slider bounds/limits, and slider step sizes:
lbd = 1;
rbd = dfn;
stp = [1,10]; % [minor,major]
%
% Define the 3D cube axis order:
xyz = 'RGB'; % choose order
[~,xyz] = ismember(xyz,'RGB');
%
if new % Create a new figure.
	%
	% Figure parameters:
	M = 9; % buttons per column
	gap = 0.01; % gaps
	bth = 0.04; % demo button height
	btw = 0.10; % demo button width
	bgh = 0.40; % button group height
	cbw = 0.23; % colorbar width (both together)
	cbh = 1-3*gap-bth; % colorbar height
	axh = 1-bgh-2*gap; % axes height
	axw = 1-cbw-2*gap; % axes width
	bgw = axw-btw-gap; % button group width
	%
	figH = figure('HandleVisibility','callback', 'Color','white',...
		'IntegerHandle','off', 'NumberTitle','off', 'Units','normalized',...
		'Name','ColorBrewer Interactive ColorScheme Selector',...
		'MenuBar','figure', 'Toolbar','none', 'Tag',mfilename);
	%
	% Add 2D lineplot:
	ax2D = axes('Parent',figH, 'Position',[gap,bgh+gap,axw,axh], 'Box','on',...
		'ColorOrder',[1,0,0; 0,1,0; 0,0,1; 0.6,0.6,0.6], 'HitTest','off',...
		'Visible','off', 'XLim',[0,1], 'YLim',[0,1], 'XTick',[], 'YTick',[]);
	ln2D = line([0,0,0,0;1,1,1,1],[0,0,0,0;1,1,1,1], 'Parent',ax2D,...
		'Visible','off', 'Linestyle','-', 'Marker','.');
	%
	% Add 3D scatterplot:
	ax3D = axes('Parent',figH, 'OuterPosition',[0,bgh,axw+2*gap,1-bgh],...
		'Visible','on', 'XLim',[0,1], 'YLim',[0,1], 'ZLim',[0,1], 'HitTest','on');
	pt3D = patch('Parent',ax3D, 'XData',[0;1], 'YData',[0;1], 'ZData',[0;1],...
		'Visible','on', 'LineStyle','none', 'FaceColor','none', 'MarkerEdgeColor','none',...
		'Marker','o', 'MarkerFaceColor','flat', 'MarkerSize',10, 'FaceVertexCData',[1,1,0;1,0,1]);
	view(ax3D,3);
	grid(ax3D,'on')
	lbl = {'Red','Green','Blue'};
	xlabel(ax3D,lbl{xyz(1)})
	ylabel(ax3D,lbl{xyz(2)})
	zlabel(ax3D,lbl{xyz(3)})
	%
	% Add warning text:
	txtH = text('Parent',ax2D, 'Units','normalized', 'Position',[1,1],...
		'HorizontalAlignment','right', 'VerticalAlignment','top', 'Color','k');
	%
	% Add demo button:
	demo = uicontrol(figH, 'Style','togglebutton', 'Units','normalized',...
		'Position',[1-cbw/2,1-bth-gap,cbw/2-gap,bth], 'String','Demo',...
		'Max',1, 'Min',0, 'Callback',@bmvDemo); %#ok<NASGU>
	% Add 2D/3D button:
	is2D = uicontrol(figH, 'Style','togglebutton', 'Units','normalized',...
		'Position',[1-cbw/1,1-bth-gap,cbw/2-gap,bth], 'String','2D / 3D',...
		'Max',1, 'Min',0, 'Callback',@bmv2D3D);
	% Add reverse button:
	bRev = uicontrol(figH, 'Style','togglebutton', 'Units','normalized',...
		'Position',[bgw+2*gap,bgh-bth,btw,bth], 'String','Reverse',...
		'Max',1, 'Min',0, 'Callback',@bmvRevM);
	%
	% Add colorbars:
	C(1,1,:) = [1,1,1];
	cbAx(2) = axes('Parent',figH, 'Visible','off', 'Units','normalized',...
		'Position',[1-cbw/2,gap,cbw/2-gap,cbh], 'YLim',[0.5,1.5],...
		'YDir','reverse', 'HitTest','off');
	cbAx(1) = axes('Parent',figH, 'Visible','off', 'Units','normalized',...
		'Position',[1-cbw/1,gap,cbw/2-gap,cbh], 'YLim',[0.5,1.5],...
		'YDir','reverse', 'HitTest','off');
	cbIm(2) = image('Parent',cbAx(2), 'CData',C);
	cbIm(1) = image('Parent',cbAx(1), 'CData',C);
	%
	% Add parameter slider, listener, and corresponding text:
	sv = mean([lbd,rbd],2);
	pTxt = uicontrol(figH,'Style','text', 'Units','normalized',...
		'Position',[bgw+2*gap,bgh-2*bth-gap,btw,bth], 'String','X');
	pSld = uicontrol(figH,'Style','slider', 'Units','normalized',...
		'Position',[bgw+2*gap,gap,btw,bgh-2*bth-gap], 'Min',lbd(1), 'Max',rbd(1),...
		'SliderStep',stp(1,:)/(rbd(1)-lbd(1)), 'Value',sv(1));
	addlistener(pSld, 'Value', 'PostSet',@bmvSldr);
	%
	% Add colorscheme button group:
	bGrp = uibuttongroup('Parent',figH, 'BorderType','none', 'Units','normalized',...
		'BackgroundColor','white', 'Position',[gap,gap,bgw,bgh-gap]);
	% Determine button locations:
	Z = 1:numel(mcs);
	Z = Z+(Z>17);
	C = (ceil(Z/M)-1)/4;
	R = (M-1-mod(Z-1,M))/M;
	% Add colorscheme buttons to group:
	for jj = numel(mcs):-1:1
		bEig(jj) = uicontrol('Parent',bGrp, 'Style','Toggle', 'String',mcs{jj},...
			'Unit','normalized', 'Position',[C(jj),R(jj),1/4,1/M]);
	end
	set(bGrp,'SelectionChangeFcn',@bmvChgS);
	%
end
%
%% Nested Functions %%
%
	function str = makeName()
		str = '*';
		str = [str(isr),scm];
	end
%
	function bmvUpDt()
		% Update all graphics objects in the figure.
		%
		% Get ColorBrewer colormap and grayscale equivalent:
		[map,num,typ] = brewermap(N,makeName());
		mag = map*[0.298936;0.587043;0.114021];
		%
		% Update colorbar values:
		set(cbAx, 'YLim', [0,abs(N)+(N==0)]+0.5);
		set(cbIm(1), 'CData',reshape(map,[],1,3))
		set(cbIm(2), 'CData',repmat(mag,[1,1,3]))
		%
		% Update 2D line / 3D patch values:
		if  get(is2D, 'Value') % 2D
			set(ln2D, 'XData',linspace(0,1,abs(N)));
			set(ln2D,{'YData'},num2cell([map,mag],1).');
		else % 3D
			set(pt3D,...
				'XData',map(:,xyz(1)),...
				'YData',map(:,xyz(2)),...
				'ZData',map(:,xyz(3)),...
				'FaceVertexCData',map)
		end
		%
		% Update reverse button:
		set(bRev, 'Value',isr)
		%
		% Update warning text:
		str = {[typ,' '];sprintf('%d Nodes ',num)};
		set(txtH,'String',str);
		%
		% Update parameter value text:
		set(pTxt(1), 'String',sprintf('N = %.0f',N));
		%
		% Update external axes/figure:
		nmr(1) = N;
		for k = 1:numel(hgv)
			colormap(hgv(k),brewermap(nmr(k),makeName()));
		end
		%
		drawnow()
	end
%
	function bmv2D3D(h,~)
		% Switch between 2D-line and 3D-cube representation.
		%
		if get(h,'Value') % 2D
			set(ax3D, 'HitTest','off', 'Visible','off')
			set(ax2D, 'HitTest','on',  'Visible','on')
			set(pt3D, 'Visible','off')
			set(ln2D, 'Visible','on')
		else % 3D
			set(ax2D, 'HitTest','off', 'Visible','off')
			set(ax3D, 'HitTest','on',  'Visible','on')
			set(ln2D, 'Visible','off')
			set(pt3D, 'Visible','on')
		end
		%
		bmvUpDt();
	end
%
	function bmvChgS(~,e)
		% Change the colorscheme.
		%
		scm = get(e.NewValue,'String');
		%
		bmvUpDt()
	end
%
	function bmvRevM(h,~)
		% Reverse the colormap.
		%
		isr = logical(get(h,'Value'));
		%
		bmvUpDt()
	end
%
	function bmvSldr(~,~)
		% Update the slider position.
		%
		if ~upd
			return
		end
		%
		N = round(get(pSld,'Value'));
		%
		bmvUpDt()
	end
%
	function bmvDemo(h,~)
		% Display all ColorBrewer colorschemes sequentially.
		%
		cnt = 0;
		while ishghandle(h)&&get(h,'Value')
			cnt = mod(cnt+1,pow2(53));
			%
			if mod(cnt,23)<1
				ids = 1+mod(find(strcmpi(scm,mcs)),numel(mcs));
				scm = mcs{ids};
				try %#ok<TRYNC>
					set(bGrp, 'SelectedObject',bEig(ids));
				end
			end
			%
			if mod(cnt,69)<1
				isr = ~isr;
			end
			%
			upb = (upb || N<=1) && N<dfn;
			N = N - 1 + 2*upb;
			%
			% Update slider position:
			upd = false;
			try %#ok<TRYNC>
				set(pSld, 'Value',N)
				bmvUpDt()
			end
			upd = true;
			%
			% Faster/slower:
			pause(0.1);
		end
		%
	end
%
%% Initialize the Figure %%
%
set(bGrp,'SelectedObject',bEig(strcmpi(scm,mcs)));
set(pSld,'Value',max(lbd,min(rbd,N)));
upd = true;
bmvUpDt()
%
if nargout
	waitfor(ax2D);
	scheme = makeName();
else
	clear map
end
%
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%brewermap_view
%
% Copyright (c) 2014-2020 Stephen Cobeldick
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