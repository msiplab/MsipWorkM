% 例7.3 （MP法）
%村松正吾　「多次元信号・画像処理の基礎と展開」
%動作確認： MATLAB R2025b
%準備
prj = matlab.project.currentProject;
prjroot = prj.RootFolder;
datfolder = fullfile(prjroot,"data");
resfolder = fullfile(prjroot,"results");
myfilename = "example07_03"; % mfilename

imgname = "msipimg02";
imgfmt = "tiff";

%画像データの読込
imgfile = fullfile(datfolder,imgname);
X = im2double(rgb2gray(imread(imgfile,imgfmt)));

figure(1)
subplot(2,3,1)
imshow(X)
title('原画像')
imwrite(X,fullfile(resfolder,myfilename+"org"),imgfmt)

% GPUに転送
X = gpuArray(X);

%% スパース係数の設定
K = (3/64)*numel(X);

%% DCT の ||d_i||_2^2 の事前計算 
di_sqrdnorm_dct = 1;

%% MP + DCT
syndic = @(x,option) blockidct2(x,option);

% モニタリング準備
subplot(2,3,2)
him = imshow(zeros(size(X),'like',X));
htt = title("MP+DCT");

% MP法による近似
Xdct = mp(X,syndic,K,di_sqrdnorm_dct,him,htt);
imwrite(Xdct,fullfile(resfolder,myfilename+"dctmp"),imgfmt)

%% OMP + DCT
syndic = @(x,option) blockidct2(x,option);
nSGIter = 1; % 勾配降下法の反復回数
muSG = 1; % 勾配降下法のステップサイズ

% モニタリング準備
subplot(2,3,3)
him = imshow(zeros(size(X),'like',X));
htt = title("OMP+DCT");

% MP法による近似
Xdct = omp(X,syndic,K,nSGIter,muSG,di_sqrdnorm_dct,him,htt);
imwrite(Xdct,fullfile(resfolder,myfilename+"dctomp"),imgfmt)

%% CDF 5/3 DWT の ||d_i||_2^2 の事前計算 
sz0 = size(X);
disqrdnormfile = fullfile(datfolder, myfilename +...
    "_disqurdnorm_" +...
    num2str(sz0(1)) +"x"+num2str(sz0(2))+".mat");

if exist(disqrdnormfile,'file')

    disp("Loading ||d_i||_2^2")
    S = load(disqrdnormfile);
    di_sqrdnorm_dwt = S.di_sqrdnorm;

else

    disp("Calculating ||d_i||_2^2")
    zerocoefs2 = cdf53dwt3lv(zeros(sz0(1),sz0(2)),'adj');
    di_sqrdnorm_ = cell(size(zerocoefs2,1),size(zerocoefs2,2));

    parfor idx = 1:numel(zerocoefs2)

        delta2 = zerocoefs2;
        delta2(idx) = 1;
        dd = cdf53dwt3lv(cdf53dwt3lv(delta2,'syn'),'adj');
        di_sqrdnorm_{idx} = dd(idx);

    end
    di_sqrdnorm = cell2mat(di_sqrdnorm_);
    disp("Saving ||d_i||_2^2")
    save(disqrdnormfile,"di_sqrdnorm")
    di_sqrdnorm_dwt = di_sqrdnorm;

end

%% MP + DWT
syndic = @(x,option) cdf53dwt3lv(x,option);

% 随伴関係の確認
% <x,v> = <x,Du> = <D'x,u> = <y,Tv>
U = rand(size(X),'like',X); % u
V = syndic(U,'syn'); % v = Du
a = dot(X(:),V(:));
Y = syndic(X,'adj'); % D'x
b = dot(Y(:),U(:));
absdiff = max(abs(a-b));
assert(absdiff<1e-9,"随伴関係が成り立ちません: "+num2str(absdiff))

% モニタリング準備
subplot(2,3,5)
him = imshow(zeros(size(X),'like',X));
htt = title("MP+DWT");

% MP法による近似
Xdwt = mp(X,syndic,K,di_sqrdnorm_dwt,him,htt);
imwrite(Xdwt,fullfile(resfolder, myfilename+"dwtmp"),imgfmt)

%% OMP + DWT
syndic = @(x,option) cdf53dwt3lv(x,option);
nLv = 3; % ツリー段数
gain2d = 4; % HH フィルタのゲイン
nSGIters = 100; % 反復回数
kappa = (gain2d^nLv)^2; % スペクトルノルム||D||_S の二乗
muSG = (1-1e-3)*(2/kappa); % ステップサイズ

% モニタリング準備
subplot(2,3,6)
him = imshow(zeros(size(X),'like',X));
htt = title("OMP+DWT");

% MP法による近似
Xdwt = omp(X,syndic,K,nSGIters,muSG,di_sqrdnorm_dwt,him,htt);
imwrite(Xdwt,fullfile(resfolder,myfilename+"dwtomp"),imgfmt)

%% MP法
function [xaprx,s] = mp(x,syndic,nCoefs,di_sqrdnorm,him,htt)
stt = htt.String;
% 初期化
r = x;
I = [];
k = 0;
t = 0;
s = syndic(zeros(size(x),'like',x),'adj');
while k < nCoefs
    a = syndic(r,'adj'); % 相関計算
    a = a ./ di_sqrdnorm; % 正規化
    e = norm(r(:),2)^2 - (a.^2).*di_sqrdnorm; % 誤差評価
    [~,imin] = min(e(:)); % 要素画像の選択
    I = union(I,imin); % 添字集合の更新
    s(imin) = s(imin) + a(imin); % 係数更新
    xaprx = syndic(s,'syn'); % 近似画像の更新
    r = x - xaprx; % 残差更新
    k = numel(I);
    t = t + 1;

    % モニタリング
    if k==1 || mod(k,100)==0 || k==nCoefs
        him.CData = gather(xaprx);
        htt.String = stt + " (k: " + num2str(k) + ...
            ", PSNR: " + num2str(psnr(x,xaprx)) + " dB)";
        drawnow
    end
end

end

%% OMP法
function [xaprx,s] = omp(x,syndic,nCoefs,nSGIters,mu,di_sqrdnorm,him,htt)
stt = htt.String;
% 初期化
r = x;
I = [];
% 
s0 = syndic(x,'adj');
for k = 1:nCoefs
    a = syndic(r,'adj'); % 相関計算    
    a = a ./ di_sqrdnorm; % 正規化
    e = norm(r(:),2)^2 - (a.^2).*di_sqrdnorm; % 誤差評価
    [~,imin] = min(e(:)); % 要素画像の選択
    I = union(I,imin); % 添字集合の更新

    % 勾配法による最小自乗解
    s = zeros(size(s0),'like',s0);
    y = s0(I);
    for iter = 1:nSGIters
        % 合成処理 v = DS.'y
        s(I) = y;
        xaprx = syndic(s,'syn');
        % 随伴処理 z = D.'(v-x) = D.'(DS.'y-x)
        z = syndic(xaprx-x,'adj');
        % 勾配 ∇f(y) = Sz = SD.'(DS.'y-x)
        g = z(I);
        % 係数更新 y ← y - μ∇f(y)
        y = y - mu*g;
    end

    % 残差の更新
    r = x - xaprx;

    % モニタリング
    if k==1 || mod(k,100)==0 || k==nCoefs
        him.CData = gather(xaprx);
        htt.String = stt + " (k: " + num2str(k) + ...
            ", PSNR: " + num2str(psnr(x,xaprx)) + " dB)";
        drawnow
    end
end

end

%% ブロックDCT
function y = blockidct2(x,option)
if isgpuarray(x)
    C = dctmtx(8);
    if strcmp(option,'syn')
        %y = blockproc(x,[8 8],@(x) idct2(x.data));
        X = reshape(x,8,[]);
        U = pagemtimes(C,'transpose',X,'none'); % U = C.'X
        u = reshape(U,size(x));
        V = reshape(u.',8,[]); % V = U.'
        W = pagemtimes(C,'transpose',V,'none'); % W = C.'V
        y = reshape(W,size(x)).'; % Y = W.'
    elseif strcmp(option,'adj')
        %y = blockproc(x,[8 8],@(x) dct2(x.data));
        X = reshape(x,8,[]);
        U = pagemtimes(C,X); % U = CX
        u = reshape(U,size(x));
        V = reshape(u.',8,[]); % V = U.'
        W = pagemtimes(C,V); % W = CV
        y = reshape(W,size(x)).'; % Y = W.'
    else
        error('不正なオプションです')
    end
else
    if strcmp(option,'syn')
        y = blockproc(x,[8 8],@(x) idct2(x.data));
    elseif strcmp(option,'adj')
        y = blockproc(x,[8 8],@(x) dct2(x.data));
    else
        error('不正なオプションです')
    end
end

end

%% CDF 5/3 DWT
function y = cdf53dwt3lv(x,option)
import msip.*

%
sz0 = size(x);
sz1 = ceil(sz0/2);
sz2 = ceil(sz1/2);
sz3 = ceil(sz2/2);

if strcmp(option,'syn')
    %
    x1  = x(1:sz1(1),1:sz1(2),:);
    HL1 = x(1:sz1(1),sz1(2)+1:end,:);
    LH1 = x(sz1(1)+1:end,1:sz1(2),:);
    HH1 = x(sz1(1)+1:end,sz1(2)+1:end,:);
    %
    x2  = x1(1:sz2(1),1:sz2(2),:);
    HL2 = x1(1:sz2(1),sz2(2)+1:end,:);
    LH2 = x1(sz2(1)+1:end,1:sz2(2),:);
    HH2 = x1(sz2(1)+1:end,sz2(2)+1:end,:);
    %
    LL3 = x2(1:sz3(1),1:sz3(2),:);
    HL3 = x2(1:sz3(1),sz3(2)+1:end,:);
    LH3 = x2(sz3(1)+1:end,1:sz3(2),:);
    HH3 = x2(sz3(1)+1:end,sz3(2)+1:end,:);
    %
    LL2 = im53itrans(LL3,HL3,LH3,HH3);
    LL1 = im53itrans(LL2,HL2,LH2,HH2);
    y = im53itrans(LL1,HL1,LH1,HH1);

elseif strcmp(option,'adj') 

    [LL1,HL1,LH1,HH1] = imadj53itrans(x);
    [LL2,HL2,LH2,HH2] = imadj53itrans(LL1);
    [LL3,HL3,LH3,HH3] = imadj53itrans(LL2);
    Y2 = cat(1,cat(2,LL3,HL3),cat(2,LH3,HH3));
    Y1 = cat(1,cat(2,Y2,HL2),cat(2,LH2,HH2));
    y = cat(1,cat(2,Y1,HL1),cat(2,LH1,HH1));

else
    error('不正なオプションです')
end
end

%%
