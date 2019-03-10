function [map,scheme] = brewermap_view(N,scheme)
% An interactive figure for ColorBrewer colormap selection. With demo!
%
% (c) 2014 Stephen Cobeldick
%
% View Cynthia Brewer's ColorBrewer colorschemes in a figure.
%
% * Two colorbars give the colorscheme in color and grayscale.
% * A button toggles between 3D-cube and 2D-lineplot of the RGB values.
% * A button toggles an endless cycle through the colorschemes.
% * A button reverses the colormap.
% * 35 buttons select any ColorBrewer colorscheme.
% * Text with the colorscheme's type (Diverging/Qualitative/Sequential)
% * Text with the colorscheme's number of nodes (defining colors).
%
%%% Syntax:
%  brewermap_view
%  brewermap_view(N)
%  brewermap_view(N,scheme)
%  brewermap_view([],...)
%  brewermap_view({axes/figure handles},...) % see "Adjust External Colormaps"
%  [map,scheme] = brewermap_view(...)
%
% Calling the function with an output argument blocks MATLAB execution until
% the figure is deleted: the final colormap and colorscheme are then returned.
%
% See also BREWERMAP CUBEHELIX RGBPLOT COLORMAP COLORMAPEDITOR COLORBAR UICONTROL ADDLISTENER
%
%% Adjust Colormaps of Other Figures or Axes %%
%
%%% Example:
%
% S = load('spine');
% image(S.X)
% brewermap_view({gca})
%
% Very useful! Simply provide a cell array of axes or figure handles when
% calling this function, and their colormaps will be updated in real-time:
% note that MATLAB versions <=2010 only support axes handles for this!
%
%% Input and Output Arguments %%
%
%%% Inputs (*=default):
%  N  = NumericScalar, an integer to define the colormap length.
%     = *[], colormap length of one hundred and twenty-eight (128).
%     = NaN, same length as the defining RGB nodes (useful for Line ColorOrder).
%     = CellArray of axes/figure handles, to be updated by BREWERMAP_VIEW.
%  scheme = CharRowVector, a ColorBrewer colorscheme name.
%
%%% Outputs (these block code execution until the figure is closed!):
%  map    = NumericMatrix, the colormap defined when the figure is closed.
%  scheme = CharRowVector, the name of the colorscheme given in <map>.
%
% [map,scheme] = brewermap_view(N,scheme)

%% Input Wrangling %%
%
persistent ax2D ln2D ax3D pt3D txtH is2D cbAx cbIm pTxt pSld bEig bGrp bRev scm isr
%
new = isempty(ax2D)||~ishghandle(ax2D);
dfn = 128;
upb = false;
hgc = {};
nmr = dfn;
%
% Parse colormap size:
if nargin==0 || isnumeric(N)&&isempty(N)
	N = dfn;
elseif isnumeric(N)
	assert(isscalar(N),'Input <N> must be a scalar numeric. NUMEL: %d',numel(N))
	assert(isreal(N),'Input <N> must be a real numeric: %g+%gi',N,imag(N))
	assert(isnan(N)||fix(N)==N&&N>0,'Input <N> must be positive integer: %g',N)
	N = double(N);
elseif iscell(N)&&numel(N)
	hgc = N(:);
	ish = all(1==cellfun('prodofsize',hgc)&cellfun(@ishghandle,hgc));
	assert(ish,'Input <N> may be a cell array of axes handles or figure handles.')
	nmr = [cellfun(@(h)size(colormap(h),1),hgc),dfn];
	N = nmr(1);
else
	error('Input <N> may be a numeric scalar/empty, or a cell array of handles.')
end
%
[mcs,mun,pyt] = brewermap('list');
%
% Check BREWERMAP outputs:
ers = 'The function BREWERMAP returned an unexpected %s.';
assert(all(35==[numel(mcs),numel(mun),numel(pyt)]),ers,'array size')
tmp = find(any(diff(+char(pyt)),2));
assert(numel(tmp)==2&&all(tmp==[9;17]),ers,'scheme name sequence')
%
% Default pseudo-random colorscheme:
if nargin==0 || new
	isr = false;
	scm = mcs{1+mod(round(now*1e7),numel(mcs))};
end
% Parse input colorscheme:
if nargin==2
	assert(ischar(scheme)&&isrow(scheme),'Second input <scheme> must be a 1xN char vector.')
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
	bth = 0.04; % demo height
	btw = 0.10; % demo width
	uih = 0.40; % height of UI control group
	cbw = 0.23; % width of both colorbars
	axh = 1-uih-2*gap; % axes height
	wdt = 1-cbw-2*gap; % axes width
	%
	figH = figure('HandleVisibility','callback', 'Color','white',...
		'IntegerHandle','off', 'NumberTitle','off', 'Units','normalized',...
		'Name','ColorBrewer Interactive ColorScheme Selector',...
		'MenuBar','figure', 'Toolbar','none', 'Tag',mfilename);
	%
	% Add 2D lineplot:
	ax2D = axes('Parent',figH, 'Position',[gap,uih+gap,wdt,axh], 'Box','on',...
		'ColorOrder',[1,0,0; 0,1,0; 0,0,1; 0.6,0.6,0.6], 'HitTest','off',...
		'Visible','off', 'XLim',[0,1], 'YLim',[0,1], 'XTick',[], 'YTick',[]);
	ln2D = line([0,0,0,0;1,1,1,1],[0,0,0,0;1,1,1,1], 'Parent',ax2D,...
		'Visible','off', 'Linestyle','-', 'Marker','.');
	%
	% Add 3D scatterplot:
	ax3D = axes('Parent',figH, 'OuterPosition',[0,uih,wdt+2*gap,1-uih],...
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
		'Position',[gap,uih+gap+0*bth,btw,bth], 'String','Demo',...
		'Max',1, 'Min',0, 'Callback',@bmvDemo); %#ok<NASGU>
	% Add 2D/3D button:
	is2D = uicontrol(figH, 'Style','togglebutton', 'Units','normalized',...
		'Position',[gap,uih+gap+1*bth,btw,bth], 'String','2D / 3D',...
		'Max',1, 'Min',0, 'Callback',@bmv2D3D);
	% Add reverse button:
	bRev = uicontrol(figH, 'Style','togglebutton', 'Units','normalized',...
		'Position',[gap,uih+gap+2*bth,btw,bth], 'String','Reverse',...
		'Max',1, 'Min',0, 'Callback',@bmvRevM);
	%
	% Add colorbars:
	C(1,1,:) = [1,1,1];
	cbAx(2) = axes('Parent',figH, 'Visible','off', 'Units','normalized',...
		'Position',[1-cbw/2,gap,cbw/2-gap,1-2*gap], 'YLim',[0.5,1.5],...
		'YDir','reverse', 'HitTest','off');
	cbAx(1) = axes('Parent',figH, 'Visible','off', 'Units','normalized',...
		'Position',[1-cbw/1,gap,cbw/2-gap,1-2*gap], 'YLim',[0.5,1.5],...
		'YDir','reverse', 'HitTest','off');
	cbIm(2) = image('Parent',cbAx(2), 'CData',C);
	cbIm(1) = image('Parent',cbAx(1), 'CData',C);
	%
	% Add parameter slider, listener, and corresponding text:
	sv = mean([lbd,rbd],2);
	pTxt = uicontrol(figH,'Style','text', 'Units','normalized',...
		'Position',[gap,uih-bth,btw,bth], 'String','X');
	pSld = uicontrol(figH,'Style','slider', 'Units','normalized',...
		'Position',[gap,gap,btw,uih-bth], 'Min',lbd(1), 'Max',rbd(1),...
		'SliderStep',stp(1,:)/(rbd(1)-lbd(1)), 'Value',sv(1));
	addlistener(pSld, 'Value', 'PostSet',@bmvSldr);
	%
	% Add colorscheme button group:
	bGrp = uibuttongroup('Parent',figH, 'BorderType','none', 'Units','normalized',...
		'BackgroundColor','white', 'Position',[2*gap+btw,gap,wdt-btw-gap,uih-gap]);
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
set(bGrp,'SelectedObject',bEig(strcmpi(scm,mcs)));
set(pSld,'Value',max(lbd,min(rbd,N)));
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
		for ii = find(cellfun(@ishghandle,hgc))
			colormap(hgc{ii},brewermap(nmr(ii),makeName()));
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
			set(ax2D, 'HitTest','on', 'Visible','on')
			set(pt3D, 'Visible','off')
			set(ln2D, 'Visible','on')
		else % 3D
			set(ax2D, 'HitTest','off', 'Visible','off')
			set(ax3D, 'HitTest','on', 'Visible','on')
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
		N = round(get(pSld,'Value'));
		%
		bmvUpDt()
	end
%
	function bmvDemo(h,~)
		% Display all ColorBrewer colorschemes sequentially.
		%
		cnt = uint64(0);
		while ishghandle(h)&&get(h,'Value')
			cnt = cnt+1;
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
			try %#ok<TRYNC>
				set(pSld, 'Value',N)
			end
			%
			% Faster/slower:
			pause(0.1);
		end
		%
	end
%
%% Initialize the Figure %%
%
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
% Copyright (c) 2014 Stephen Cobeldick
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