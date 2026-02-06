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

imgname = "msipimg01";
imgfmt = "tiff";
%%
%[text] ## 画像データの読込
imgfile = fullfile(datfolder,imgname);
X = rgb2gray(imread(imgfile,imgfmt));

%%
%[text] ## 幾何処理前の画像表示
figure(1)
imshow(X) 
title('原画像') 
%%
%[text] ## 幾何処理
U = imresize(X,0.5,'box'); % 縮小
figure(2)
imshow(U)
title('縮小画像') 

%%
%[text] ## 幾何処理後の画像表示
Y = imresize(U,2,'bilinear');
figure(3)
imshow(Y)
title('拡大画像') 

%%
%[text] ## ピーク信号対雑音比による誤差評価
fprintf('PSNR:  %6.2f dB\n',psnr(X,Y)) %[output:0c054bf0]

%%
%[text] ## 結果出力
imwrite(X,fullfile(resfolder,"fig01-02a.png"))
imwrite(U,fullfile(resfolder,"fig01-02b.png"))
imwrite(Y,fullfile(resfolder,"fig01-02c.png"))