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

% GPUに転送
X = gpuArray(X);

% OMP法による近似
Xdct = omp(X,syndic,K,nSGIters,mu,him,htt);
imwrite(Xdct,fullfile(resfolder,myfilename+"dctomp"),imgfmt)

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

%% 



