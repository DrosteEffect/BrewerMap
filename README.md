BREWERMAP Function
==================

BREWERMAP provides all ColorBrewer 2.0 colorschemes for MATLAB, with simple selection by colormap length and scheme name. Alternatively the scheme name can be preselected, after which only the colormap length is required to define an output colormap.

BREWERMAP is compatible with all MATLAB functions that require a colormap function. The function consists of just one M-file that provides all of the ColorBrewer colorschemes (no mat file, no third party files, no file-clutter!). Downsampling or interpolation or repetition of the nodes occurs automatically, if required.

### Examples ###

    % New colors for the COLORMAP example:
    S = load('spine.mat');
    image(S.X)
    colormap(brewermap([],"YlGnBu"))
    
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
    
    % Plot a scheme's RGB values:
    rgbplot(brewermap(NaN, '+Blues')) % standard
    rgbplot(brewermap(NaN, '-Blues')) % reversed
    
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

### Bonus Functions ###

BREWERMAP_PLOT creates a figure which shows the nodes (defining colors) of all ColorBrewer colorschemes.

BREWERMAP_VIEW creates an interactive figure that allows selection of the colorscheme, and that contains two colorbars showing colors of the colormap and the grayscale equivalent.

R2014b or later: BREWERMAP_VIEW can also update other axes' or figures' colormaps in real time, for example:

    S = load('spine');
    image(S.X)
    brewermap_view(gca) % default = colormap

R2019b or later: BREWERMAP_VIEW can also update other axes's or figures' line colororders in real time, for example:

    plot(rand(7,7))
    brewermap_view(gca,[],true) % colororder

PRESET_COLORMAP is a wrapper for any colormap function, storing the function and any parameter values for future calls.

    preset_colormap(@brewermap, "blues")
    colormap(preset_colormap)

### Colorspace ###

Interpolation is performed in RGB colorspace. Interpolation in other colorspaces (e.g. CIELab) produces no perceptable benefit at the cost of extra processing and noise caused by the round-trip conversion.

### Notes ###

The function BREWERMAP:
* Consists of just one convenient M-file (no .mat files or file clutter).
* Has no third-party file dependencies.
* Has no special toolbox dependencies.
* Requires just the standard ColorBrewer colorscheme name to select the colorscheme.
* Accepts the colorscheme name as a string scalar or a character vector.
* Supports all ColorBrewer colorschemes.
* Outputs a MATLAB standard N-by-3 numeric RGB array.
* Uses a default length the same as MATLAB's colormap functions.
* Is compatible with all MATLAB functions that use colormaps (eg: CONTOURCMAP).
* Includes the option to reverse the colormap color sequence.
* Does not break ColorBrewer's Apache license conditions (unlike many on MATLAB File Exchange).

This product includes color specifications and designs developed by Cynthia Brewer (http://colorbrewer.org/). See the ColorBrewer website for further information about each colorscheme, colorblind suitability, licensing, and citations.