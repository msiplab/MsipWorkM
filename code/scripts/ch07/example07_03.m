% 例7.3 （OMP法）
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
subplot(1,3,1)
imshow(X)
title('原画像')
imwrite(X,fullfile(resfolder,myfilename+"org"),imgfmt)

% GPUに転送
X = gpuArray(X);

%% OMPの設定
K = (3/64)*numel(X);

%% OMP + DCT
nSGIters = 1;
mu = 1;
syndic = @(x,option) blockidct2(x,option);

% モニタリング準備
subplot(1,3,2)
him = imshow(zeros(size(X),'like',X));
htt = title("OMP+DCT");

% OMP法による近似
Xdct = omp(X,syndic,K,nSGIters,mu,him,htt);
imwrite(Xdct,fullfile(resfolder,myfilename+"dctomp"),imgfmt)

%% OMP + DWT
nSGIters = 1000; % 勾配降下法の繰り返し回数
nLv = 3; % ツリー段数
gain2d = 4; % HH フィルタのゲイン
kappa = (gain2d^nLv)^2; % スペクトルノルム||DS||_S の二乗
mu = (1-1e-3)*(2/kappa); % ステップサイズ
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
subplot(1,3,3)
him = imshow(zeros(size(X),'like',X));
htt = title("OMP+DWT");

% OMP法による近似
Xdwt = omp(X,syndic,K,nSGIters,mu,him,htt);
imwrite(Xdwt,fullfile(resfolder,myfilename+"dwtomp"),imgfmt)

%% OMP法
function [xaprx,s] = omp(x,syndic,nCoefs,nSGIters,mu,him,htt)
    stt = htt.String;
    % 初期化
    r = x;
    I = [];
    s0 = syndic(x,'adj');

    for k = 1:nCoefs
        a = syndic(r,'corr'); % 相関計算
        %e = norm(r(:),2)^2 - a; % 誤差評価
        [~,imin] = max(a(:)); % min(e); 要素画像の選択
        I = union(I,imin); % 添字集合の更新
        % 勾配法による最小自乗解
        y = s0(I);
        for iter = 1:nSGIters
            % 合成処理 v = DS.'y
            s = zeros(size(a),'like',a);
            s(I) = y;
            xaprx = syndic(s,'syn');
            % 随伴処理 z = D.'(v-x) = D.'(DS.'y-x)
            z = syndic(xaprx-x,'adj');
            % 勾配 ∇f(y) = Sz = SD.'(DS.'y-x)
            g = z(I);
            % 係数更新 y ← y - μ∇f(y)
            y = y - mu*g;
        end
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
    if strcmp(option,'syn')
        sz0 = size(x);
        sz1 = ceil(sz0/2);
        sz2 = ceil(sz1/2);
        sz3 = ceil(sz2/2);
        %
        x1  = x(1:sz1(1),1:sz1(2));
        HL1 = x(1:sz1(1),sz1(2)+1:end);
        LH1 = x(sz1(1)+1:end,1:sz1(2));
        HH1 = x(sz1(1)+1:end,sz1(2)+1:end);
        %
        x2  = x1(1:sz2(1),1:sz2(2));
        HL2 = x1(1:sz2(1),sz2(2)+1:end);
        LH2 = x1(sz2(1)+1:end,1:sz2(2));
        HH2 = x1(sz2(1)+1:end,sz2(2)+1:end);
        %
        LL3 = x2(1:sz3(1),1:sz3(2));
        HL3 = x2(1:sz3(1),sz3(2)+1:end);        
        LH3 = x2(sz3(1)+1:end,1:sz3(2));
        HH3 = x2(sz3(1)+1:end,sz3(2)+1:end);
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
    elseif strcmp(option,'corr') 
        fL = [1 2 1]/2;
        fH = [-1 -2 6 -2 -1]/8;
        %
        fLL = kron(fL.',fL);
        fHL = kron(fH.',fL);
        fLH = kron(fL.',fL);
        fHH = kron(fL.',fL);
        %
        fLL1 = fLL; 
        %cLL1 = dot(fLL1(:),fLL1(:));
        fHL1 = fHL; 
        cHL1 = dot(fHL1(:),fHL1(:));
        fLH1 = fLH; 
        cLH1 = dot(fLH1(:),fLH1(:));
        fHH1 = fHH; 
        cHH1 = dot(fHH1(:),fHH1(:));
        %
        fLL2 = conv2(fLL1,upsample(upsample(fLL,2),2));
        %cLL2 = dot(fLL2(:),fLL2(:));
        fHL2 = conv2(fLL1,upsample(upsample(fHL,2),2)); 
        cHL2 = dot(fHL2(:),fHL2(:));
        fLH2 = conv2(fLL1,upsample(upsample(fLH,2),2));
        cLH2 = dot(fLH2(:),fLH2(:));
        fHH2 = conv2(fLL1,upsample(upsample(fHH,2),2));
        cHH2 = dot(fHH2(:),fHH2(:));
        %
        fLL3 = conv2(fLL2,upsample(upsample(fLL,2),2));
        cLL3 = dot(fLL3(:),fLL3(:));
        fHL3 = conv2(fLL2,upsample(upsample(fHL,2),2));
        cHL3 = dot(fHL3(:),fHL3(:));
        fLH3 = conv2(fLL2,upsample(upsample(fLH,2),2));
        cLH3 = dot(fLH3(:),fLH3(:));
        fHH3 = conv2(fLL2,upsample(upsample(fHH,2),2));
        cHH3 = dot(fHH3(:),fHH3(:));
        %
        [LL1,HL1,LH1,HH1] = imadj53itrans(x);
        [LL2,HL2,LH2,HH2] = imadj53itrans(LL1);
        [LL3,HL3,LH3,HH3] = imadj53itrans(LL2);
        Y2 = cat(1,cat(2,LL3/cLL3,HL3/cHL3),cat(2,LH3/cLH3,HH3/cHH3));
        Y1 = cat(1,cat(2,Y2,HL2/cHL2),cat(2,LH2/cLH2,HH2/cHH2));
        y = cat(1,cat(2,Y1,HL1/cHL1),cat(2,LH1/cLH1,HH1/cHH1));
    else
        error('不正なオプションです')
    end
end

