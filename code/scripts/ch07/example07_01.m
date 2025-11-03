% 例7.1 （ゾーン符号化）
%村松正吾　「多次元信号・画像処理の基礎と展開」
%動作確認： MATLAB R2025b
%準備
prj = matlab.project.currentProject;
prjroot = prj.RootFolder;
datfolder = fullfile(prjroot,"data");
resfolder = fullfile(prjroot,"results");
myfilename = "example07_01"; % mfilename

imgname = "msipimg02";
imgfmt = "tiff";

%画像データの読込
imgfile = fullfile(datfolder,imgname);
X = im2double(rgb2gray(imread(imgfile,imgfmt)));

figure(1)
subplot(1,2,1)
imshow(X)
title('原画像')

%% ブロックDCT
Z = zeros(8);
Z(1,1)=1;
Z(1,2)=1;
Z(2,1)=1;
Y = blockproc(X,[8 8],@(x) idct2(Z.*dct2(x.data)));

subplot(1,2,2)
imshow(Y)
title("ブロックDCT (PSNR:"+psnr(X,Y)+" dB")
