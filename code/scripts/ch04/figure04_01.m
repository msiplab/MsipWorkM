prj = matlab.project.currentProject;
prjroot = prj.RootFolder;
datfolder = fullfile(prjroot,"data");
resfolder = fullfile(prjroot,"results");

imgname = "msipimg08";
imgfmt = "tiff";

imgfile = fullfile(datfolder,imgname);
X = imresize(im2double(rgb2gray(imread(imgfile,imgfmt))),[96 96]);

figure(1)
imshow(X)

figure(2)
h = surf(X);
colormap("gray")
h.EdgeColor = "none";

shading interp
daspect([8 8 1])
ax = gca;
ax.FontSize = 12;
ax.YDir = 'reverse';
ax.XTick = 0:20:100;
ax.YTick = 0:20:100;
ax.ZTick = 0:1;
ax.Color = 'none';
fg = gcf;
fg.Color = 'none';
set(fg,'Renderer','opengl'); 
xlabel("$q_\mathrm{h}$","Interpreter","latex","FontSize",16);
ylabel("$q_\mathrm{v}$","Interpreter","latex","FontSize",16);
zlabel("$u(\mathbf{q})$","Interpreter","latex","FontSize",16);

exportgraphics(ax,fullfile(resfolder,"fig04-01a.png"),'BackgroundColor','none','ContentType','image')

%%
figure(3)
Y = fftshift((abs(fft2(X,128,128))));
[Fx,Fy] = meshgrid(-1:2/128:1-2/128,-1:2/128:1-2/128);
h = surf(Fx,Fy,Y);
A = 10*log10(h.CData);
h.CData = (A-min(A(:)))/(max(A(:))-min(A(:)));
colormap("gray")
h.EdgeColor = "none";

shading interp
daspect([1 1 12000])
ax = gca;
ax.FontSize = 12;
ax.YDir = 'reverse';
ax.XTick = -1:1;
ax.XTickLabel = {"-\pi/\Delta_h","0","\pi/\Delta_h"};
ax.YTick = -1:1;
ax.YTickLabel = {"-\pi/\Delta_v","0","\pi/\Delta_v"};
ax.ZTick = 0;
ax.Color = 'none';
fg = gcf;
fg.Color = 'none';
set(fg,'Renderer','opengl'); 
xlabel("$\nu_\mathrm{h}$","Interpreter","latex","FontSize",16);
ylabel("$\nu_\mathrm{v}$","Interpreter","latex","FontSize",16);
zlabel("$|\tilde{u}(\mathbf{\nu})|$","Interpreter","latex","FontSize",16);

exportgraphics(ax,fullfile(resfolder,"fig04-01b.png"),'BackgroundColor','none','ContentType','image')


%%
[Qx,Qy] = meshgrid(-0.5:1/128:0.5-1/128,-0.5:1/128:0.5-1/128);

idx = 1;
for iv = 0:2
    for ih = 0:2
        figure(3+idx)
        nuv = 2*pi*iv;
        nuh = 2*pi*ih;

        b = @(qv,qh) cos(nuv.*qv+nuh.*qh);

        surf(Qx,Qy,b(Qx,Qy))
        axis off
        daspect([1 1 64])
        colormap("gray")
        h.EdgeColor = "none";
        shading interp
        idx = idx + 1;
        ax = gca;
        ax.Color = 'none';
        fg = gcf;
fg.Color = 'none';
set(fg,'Renderer','opengl'); 
        exportgraphics(ax,fullfile(resfolder,"fig04-01c"+"_"+num2str(iv)+"_"+num2str(ih)+".png"),'BackgroundColor','none','ContentType','image')

    end
end