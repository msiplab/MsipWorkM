%[text] # 例1.11（幾何処理）
%[text] 村松正吾　「多次元信号・画像処理の基礎と展開」
%[text] 動作確認： MATLAB R2025b
%[text] ## 準備
isVerbose = false;
prj = matlab.project.currentProject;
prjroot = prj.RootFolder;
datfolder = fullfile(prjroot,"data");
resfolder = fullfile(prjroot,"results");
myfilename = "example01_11"; % mfilename

imgname = "msipimg05";
imgfmt = "tiff";
%%
%[text] ## 画像データの読込
imgfile = fullfile(datfolder,imgname);
V = rgb2gray(imread(imgfile,imgfmt));
%%
%[text] ## 幾何処理前の画像表示
figure(1)
imshow(V) %[output:5e5213dd]
title('原画像') %[output:5e5213dd]
%%
%[text] ## 幾何処理

%%
%[text] ## 幾何処理後の画像表示
U = imread(resimg,resfmt);
figure(2)
imshow(U) %[output:38c3f270]
title('画像') %[output:38c3f270]
%%

%%
%[text] ## ピーク信号対雑音比による誤差評価
fprintf('PSNR:  %6.2f [dB]\n',psnr(V,U)) %[output:0c054bf0]
%%
%[text] ## 結果出力
imwrite(V,fullfile(resfolder,"fig01-02a.png"))
imwrite(U,fullfile(resfolder,"fig01-02b.jpg"))
imwrite(Y,fullfile(resfolder,"fig01-02c.png"))
