%[text] # 例4.1（二次元余弦波）
%[text] 村松正吾　「多次元信号・画像処理の基礎と展開」
%[text] 動作確認： MATLAB R2025b
%[text] ## 準備
isVerbose = false;
prj = matlab.project.currentProject;
prjroot = prj.RootFolder;
datfolder = fullfile(prjroot,"data");
resfolder = fullfile(prjroot,"results");
myfilename = "example04_01"; % mfilename
%%
N = 128;
[Qx,Qy] = meshgrid(-0.5:1/N:0.5-1/N,-0.5:1/N:0.5-1/N);
%%
nus = {[0;2*pi],[4*pi;0],[4*pi;2*pi]};
labels = {"a","b","c"};
for idx=1:3 %[output:group:1ea6798d]
    nuv = nus{idx}(1);
    nuh = nus{idx}(2);
    b = @(qv,qh) cos(nuv.*qv+nuh.*qh);

    figure(idx) %[output:371711f5] %[output:119263d2] %[output:2fd18be8]
    h = surf(Qx,Qy,b(Qy,Qx)); %[output:371711f5] %[output:119263d2] %[output:2fd18be8]
    %axis off
    daspect([1 1 8])
    colormap("gray")
    h.EdgeColor = "none";
    shading interp
    xlabel("$q_\mathrm{h}$","Interpreter","latex")
    ylabel("$q_\mathrm{v}$","Interpreter","latex")
    ax = gca;
    ax.YDir = 'reverse';
    ax.Color = 'none';
    ax.FontSize = 20;
    fg = gcf;
    fg.Color = 'none';
    set(fg,'Renderer','opengl');
    exportgraphics(fg,fullfile(resfolder,"fig04-02"+labels{idx}+".png"),'BackgroundColor','none','ContentType','image') %[output:75101925] %[output:371711f5] %[output:0a1594f0] %[output:119263d2] %[output:61b47e3d] %[output:2fd18be8]
end %[output:group:1ea6798d]

%[text] © Copyright, Shogo MURAMATSU, All rights reserved.

%[appendix]{"version":"1.0"}
%---
%[metadata:view]
%   data: {"layout":"onright","rightPanelPercent":26.6}
%---
%[output:75101925]
%   data: {"dataType":"warning","outputData":{"text":"警告: 背景の透明度はサポートされていないため、代わりに white を使用します。"}}
%---
%[output:371711f5]
%   data: {"dataType":"image","outputData":{"height":179,"width":297}}
%---
%[output:0a1594f0]
%   data: {"dataType":"warning","outputData":{"text":"警告: 背景の透明度はサポートされていないため、代わりに white を使用します。"}}
%---
%[output:119263d2]
%   data: {"dataType":"image","outputData":{"height":179,"width":297}}
%---
%[output:61b47e3d]
%   data: {"dataType":"warning","outputData":{"text":"警告: 背景の透明度はサポートされていないため、代わりに white を使用します。"}}
%---
%[output:2fd18be8]
%   data: {"dataType":"image","outputData":{"height":179,"width":297}}
%---
