%[text] # 例1.12（復元処理）
%[text] 村松正吾　「多次元信号・画像処理の基礎と展開」
%[text] 動作確認： MATLAB R2017a
%[text] ## 画像データのダウンロード
isVerbose = false;
msip.download_img(isVerbose) %[output:4971f24d]
%%
%[text] ## 画像データの読込
X = im2double(rgb2gray(imread('./data/lena.png')));
%%
%[text] ## 劣化前の画像表示
figure(1)
imshow(X)
title('原画像')
%%
%[text] ## 劣化過程
hsigma  = 4;                    % ガウスカーネル分散
hsize   = 2*ceil(2*hsigma)+1;   % ガウスカーネルサイズ
nvar    = (10/255)^2;            % 加法性白色ガウスノイズ分散
gaussfilt = fspecial('gaussian',hsize,hsigma);             % ガウスカーネル
linproc = @(x) imfilter(x,gaussfilt,'conv','circular'); % 線形観測過程
U = linproc(X);                 % 線形観測
V = imnoise(U,'gaussian',0,nvar);  % 加法性白色ガウスノイズ
%%
%[text] ## 劣化後の画像表示
figure(2)
imshow(V)
title('劣化画像')
%%
%[text] ## 劣化後の品質
fprintf('劣化後の品質(PSNR)： %6.2f [dB]\n',psnr(V,X))
%%
%[text] ## 復元前処理
adjproc = @(x) imfilter(x,gaussfilt,'corr','circular'); %　随伴観測過程
vpst = rand(size(V),'like',V);
lpre = 1.0;
err_ = Inf;
while ( err_ >  1e-5 ) % べき乗法
    % vpst = (P.'*P)*vupre
    vpre = vpst/norm(vpst(:));
    u    = linproc(vpre); % P
    vpst = adjproc(u);    % P.'
    n    = (vpst(:).'*vpst(:));
    d    = (vpst(:).'*vpre(:));
    lpst = n/d;
    err_ = norm(lpst-lpre);
    lpre = lpst;
end
frameBound = 1; % フレーム境界
L = frameBound*lpst ;  
%fprintf('L = %g\n',L);
%%
%[text] ## **復元処理(FISTA)**
lambda  = 5e-4;
nLevels = 5;
nItrs   = 25;
isFista = true;
%
[Cpre,S]= msip.nshaarwtdec2(adjproc(V),nLevels);
tpre = 1;
%
Y = msip.nshaarwtrec2(Cpre,S);
R = linproc(Y)-V;
for iItr = 1:nItrs
    D = (1/L)*msip.nshaarwtdec2(adjproc(R),nLevels);
    C = softthresh(Cpre-D,lambda/L);
    if isFista % FISTA
        W = C;
        t = (1+sqrt(1+4*tpre^2))/2;
        C = W+(tpre-1)/t*(W-Cpre);
        tpre = t;
    end
    Y = msip.nshaarwtrec2(C,S);
    R = linproc(Y)-V;
    Cpre = C;
end
%%
%[text] ## 復元後の画像表示
figure(3)
imshow(Y)
title('復元画像')
%%
%[text] ## 復元後の品質
fprintf('復元後の品質(PSNR)： %6.2f [dB]\n',psnr(Y,X))
%%
%[text] ## 関数定義
%[text] ソフト閾値処理
function y = softthresh(x,thresh)
    v = abs(x)-thresh;
    y = sign(x).*(v+abs(v))/2;
end

%[appendix]{"version":"1.0"}
%---
%[metadata:view]
%   data: {"layout":"onright"}
%---
%[output:4971f24d]
%   data: {"dataType":"error","outputData":{"errorType":"runtime","text":"次を使用中のエラー: <a href=\"matlab:matlab.lang.internal.introspective.errorDocCallback('imread', 'C:\\Program Files\\MATLAB\\R2025b\\toolbox\\matlab\\matlab_im\\imread.m', 430)\" style=\"font-weight:bold\">imread<\/a> (<a href=\"matlab: opentoline('C:\\Program Files\\MATLAB\\R2025b\\toolbox\\matlab\\matlab_im\\imread.m',430,0)\">行 430<\/a>)\n'http:\/\/homepages.cae.wisc.edu\/~ece533\/images\/lena.png' を開けません。指定したインターネット URL には認証が必要な場合がありますが、これはサポートされていません。\n\nエラー: <a href=\"matlab:matlab.lang.internal.introspective.errorDocCallback('msip.download_img', 'C:\\Users\\shogo\\Workspace\\GitHub\\MsipWorkM\\code\\+msip\\download_img.m', 20)\" style=\"font-weight:bold\">msip.download_img<\/a> (<a href=\"matlab: opentoline('C:\\Users\\shogo\\Workspace\\GitHub\\MsipWorkM\\code\\+msip\\download_img.m',20,0)\">行 20<\/a>)\n            img = imread(...\n            ^^^^^^^^^^^^^^^^"}}
%---
