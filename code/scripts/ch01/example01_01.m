%[text] # 例1.1（配列表現）
%[text] 村松正吾　「多次元信号・画像処理の基礎と展開」
%[text] 動作確認： MATLAB R2025b
%[text] ## 画像データのダウンロード
isVerbose = false;
msip.download_img(isVerbose)
%%
%[text] ## (a) グレースケール画像
fprintf('(a) グレースケール画像\n')
V = rgb2gray(imread('./data/kodim01.png'));
fprintf('配列次元： D = %d\n',ndims(V))
imshow(V)
%%
%[text] ## (b) RGB画像
fprintf('(b) RGBカラー画像\n')
V = imread('./data/kodim23.png');
fprintf('配列次元： D = %d\n',ndims(V))
imshow(V)
%%
%[text] ## (c) 動画像
fprintf('(c) 動画像\n')
vrObj = VideoReader('shuttle.avi');
V = zeros(vrObj.Height,vrObj.Width,3,2,'uint8');
V(:,:,:,1) = readFrame(vrObj);
V(:,:,:,2) = readFrame(vrObj);
fprintf('配列次元： D = %d\n',ndims(V))
imshow(V(:,:,:,1))
title('第0フレーム')
imshow(V(:,:,:,2))
title('第1フレーム')
%%
%[text] ## (d) ボリュームデーデータ
fprintf('(d) ボリュームデータ\n')
load mri
V = squeeze(D);
fprintf('配列次元： D = %d\n',ndims(V))
imshow(V(:,:,1))
title('第0スライス(xy)')
imshow(V(:,:,2))
title('第1スライス(xy)')
%%
%[text] © Copyright, Shogo MURAMATSU, All rights reserved.

%[appendix]{"version":"1.0"}
%---
%[metadata:view]
%   data: {"layout":"onright"}
%---
