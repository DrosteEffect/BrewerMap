BREWERMAP Function
==================

BREWERMAP provides all ColorBrewer colorschemes for MATLAB, with simple selection by colormap length and scheme name. Alternatively the scheme name can be preselected, after which only the colormap length is required to define an output colormap.

BREWERMAP is compatible with all MATLAB functions that require a colormap. The function consists of just one M-file that provides all of the ColorBrewer colorschemes (no mat file, no third party files, no file-clutter!). Downsampling or interpolation or repetition of the nodes occurs automatically, if required. Interpolation uses the Lab colorspace.

### Examples ###

    % Plot a scheme's RGB values:
    rgbplot(brewermap(9, 'Blues')) % standard
    rgbplot(brewermap(9,'*Blues')) % reversed
    
    % View information about a colorscheme:
    [~,num,typ] = brewermap(NaN,'Paired')
    num = 12
    typ = 'Qualitative'
    
    % Multiline plot using matrices:
    N = 6;
    axes('ColorOrder',brewermap(N,'Pastel2'),'NextPlot','replacechildren')
    X = linspace(0,pi*3,1000);
    Y = bsxfun(@(x,n)n*sin(x+2*n*pi/N), X.', 1:N);
    plot(X,Y, 'linewidth',4)
    
    % Multiline plot in a loop:
    set(0,'DefaultAxesColorOrder',brewermap(NaN,'Accent'))
    N = 6;
    X = linspace(0,pi*3,1000);
    Y = bsxfun(@(x,n)n*sin(x+2*n*pi/N), X.', 1:N);
    for n = 1:N
        plot(X(:),Y(:,n), 'linewidth',4);
        hold all
    end
    
    % New colors for the COLORMAP example:
    S = load('spine.mat');
    image(S.X)
    colormap(brewermap([],'YlGnBu'))
    
    % New colors for the SURF example:
    [X,Y,Z] = peaks(30);
    surfc(X,Y,Z)
    colormap(brewermap([],'RdYlGn'))
    axis([-3,3,-3,3,-10,5])
    
    % New colors for the CONTOURCMAP example:
    brewermap('PuOr'); % preselect the colorscheme.
    load topo
    load coast
    figure
    worldmap(topo, topolegend)
    contourfm(topo, topolegend);
    contourcmap('brewermap', 'Colorbar','on', 'Location','horizontal',...
    'TitleString','Contour Intervals in Meters');
    plotm(lat, long, 'k')

### Bonus Function ###

BREWERMAP_PLOT creates a figure which shows the nodes of all ColorBrewer colorschemes.

### Bonus Function ###

BREWERMAP_VIEW creates an interactive figure that allows selection of the colorscheme, and that contains two colorbars showing colors of the colormap and the grayscale equivalent.

R2014b or later: BREWERMAP_VIEW can also update other axes' or figures' colormaps in real time, for example:

    S = load('spine');
    image(S.X)
    brewermap_view(gca)

### Notes ###

The function BREWERMAP:
* Consists of just one convenient M-file (no .mat files or file clutter).
* Has no third-party file dependencies.
* Interpolates in the Lab colorspace.
* Requires just the standard ColorBrewer scheme name to select the colorscheme.
* Supports all ColorBrewer colorschemes.
* Outputs a MATLAB standard N-by-3 numeric RGB array.
* Uses a default length the same as MATLAB's colormaps (i.e. the length of the current colormap).
* Is compatible with all MATLAB functions that use colormaps (eg: CONTOURCMAP).
* Includes the option to reverse the colormap color sequence.
* Does not break ColorBrewer's Apache license conditions (unlike many on MATLAB File Exchange).

This product includes color specifications and designs developed by Cynthia Brewer (http://colorbrewer.org/). See the ColorBrewer website for further information about each colorscheme, colorblind suitability, licensing, and citations.