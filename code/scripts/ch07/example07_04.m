% 例7.4（IHT法）
%村松正吾　「多次元信号・画像処理の基礎と展開」
%動作確認： MATLAB R2025b
%準備
prj = matlab.project.currentProject;
prjroot = prj.RootFolder;
datfolder = fullfile(prjroot,"data");
resfolder = fullfile(prjroot,"results");
myfilename = "example07_04"; % mfilename

imgname = "msipimg02";
imgfmt = "tiff";

%画像データの読込
imgfile = fullfile(datfolder,imgname);
X = im2double(rgb2gray(imread(imgfile,imgfmt)));

figure(1)
subplot(1,3,1)
imshow(X)
title('原画像')
imwrite(X,fullfile(resfolder,myfilename+"org"),imgfmt)

% GPUに転送
X = gpuArray(X);

%% スパース係数のの設定
K = (3/64)*numel(X);

%% IHT + DCT
syndic = @(x,option) blockidct2(x,option);
nIters = 1; % 反復回数
mu = 1; % ステップサイズ

% モニタリング準備
subplot(1,3,2)
him = imshow(zeros(size(X),'like',X));
htt = title("IHT+DCT");

% IHT法による近似
Xdct = iht(X,syndic,K,nIters,mu,him,htt);
imwrite(Xdct,fullfile(resfolder,myfilename+"dctiht"),imgfmt)

%% IHT + DWT
nLv = 3; % ツリー段数
gain2d = 4; % HH フィルタのゲイン
syndic = @(x,option) cdf53dwt3lv(x,option);
nIters = 10000; % 反復回数
kappa = (gain2d^nLv)^2; % スペクトルノルム||D||_S の二乗
mu = (1-1e-3)*(1/kappa); % ステップサイズ

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
subplot(1,3,3)
him = imshow(zeros(size(X),'like',X));
htt = title("IHT+DWT");

% IHT法による近似
Xdwt = iht(X,syndic,K,nIters,mu,him,htt);
imwrite(Xdwt,fullfile(resfolder,myfilename+"dwtiht"),imgfmt)

%% IHT法
function [xaprx,s] = iht(x,syndic,nCoefs,nIters,mu,him,htt)
stt = htt.String;
% 初期化
s = syndic(zeros(size(x),'like',x),'adj');
xaprx = syndic(s,'syn');
for t = 1:nIters
    % 勾配 ∇f(y) = D.'(Ds-x)
    g = syndic(xaprx-x,'adj');
    % 勾配降下 z ← s - μ∇f(s)
    z = s - mu*g;
    % ハード閾値処理
    [~,I] = maxk(z(:),nCoefs,'ComparisonMethod','abs');
    s = zeros(size(s),'like',s);
    s(I) = z(I);

    % 近似画像の更新
    xaprx = syndic(s,'syn');

    % モニタリング
    if t==1 || mod(t,100)==0 || t==nIters
        him.CData = gather(xaprx);
        htt.String = stt + " (t: " + num2str(t) + ...
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
    elseif strcmp(option,'corr') || strcmp(option,'adj')
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
    elseif strcmp(option,'corr') || strcmp(option,'adj')
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