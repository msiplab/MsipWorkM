% 例7.2 （ゾーン符号化と最小二乗法）
%村松正吾　「多次元信号・画像処理の基礎と展開」
%動作確認： MATLAB R2025b
%準備
isVerbose = false;
prj = matlab.project.currentProject;
prjroot = prj.RootFolder;
datfolder = fullfile(prjroot,"data");
resfolder = fullfile(prjroot,"results");
myfilename = "example07_02"; % mfilename

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

% GPU へ転送
X = gpuArray(X);

%%
%{
waveinfo('bior')
[h0,h1,f0,f1]=wfilters('bior2.2');
els1 = liftingStep('Type','predict',...
     'Coefficients',-[1/2 1/2],'MaxOrder',1);
els2 = liftingStep('Type','update',...
     'Coefficients',[1/4 1/4],'MaxOrder',0);
stepArray = [els1;els2];
lscBior = liftingScheme('LiftingSteps',stepArray,'NormalizationFactors',1);
disp(lscBior)

[lod,hid,lor,hir] = ls2filt(lscBior);
lvl = 3;
[ll,lh,hl,hh] = lwt2(X,LiftingScheme=lscBior,Level=lvl,Extension="symmetric");
ll = 1*ll;
lh{3}=1*lh{3};
lh{2}=0*lh{2};
lh{1}=0*lh{1};
hl{3}=1*hl{3};
hl{2}=0*hl{2};
hl{1}=0*hl{1};
hh{3}=0*hh{3};
hh{1}=0*hh{1};
hh{2}=0*hh{2};
V = ilwt2(ll,lh,hl,hh,LiftingScheme=lscBior,Extension="symmetric");
%}
import msip.*

% 分析処理
[LL1,HL1,LH1,HH1] = im53trans(X);
[LL2,HL2,LH2,HH2] = im53trans(LL1);
[LL3,HL3,LH3,HH3] = im53trans(LL2);

% ゾーン符号化
HH3 = 0*HH3;
HL2 = 0*HL2;
LH2 = 0*LH2;
HH2 = 0*HH2;
HL1 = 0*HL1;
LH1 = 0*LH1;
HH1 = 0*HH1;

% 合成処理
LL2 = im53itrans(LL3,HL3,LH3,HH3);
LL1 = im53itrans(LL2,HL2,LH2,HH2);
V = im53itrans(LL1,HL1,LH1,HH1);

% 結果表示
subplot(1,3,2)
imshow(V)
title("CDF 5/3 DWT　ゾーン符号化 (PSNR:"+num2str(psnr(X,V))+" dB)")
drawnow
imwrite(V,fullfile(resfolder,myfilename+"dwtzc"),imgfmt)

%% 随伴関係の確認
% <x,v> = <x,Du> = <D'x,u> = <y,Tv>
V = rand(size(X),'like',X); % v = Du
a = dot(X(:),V(:));
[YLL,YHL,YLH,YHH] = imadj53itrans(X); % D'x
[ULL,UHL,ULH,UHH] = im53trans(V); % Tv
Y = cat(1,cat(2,YLL,YHL),cat(2,YLH,YHH));
U = cat(1,cat(2,ULL,UHL),cat(2,ULH,UHH));
b = dot(Y(:),U(:));
absdiff = max(abs(a-b));
assert(absdiff<1e-9,"随伴関係が成り立ちません: "+num2str(absdiff))

%% 最小二乗法
nIters = 3000; % 繰り返し回数
nLv = 3; % ツリー段数
gain2d = 4; % HH フィルタのゲイン
kappa = (gain2d^nLv)^2; % スペクトルノルム||DS||_S の二乗
mu = (1-1e-3)*(2/kappa); % ステップサイズ

% 分析処理 c = D.'x
[LL1,HL1,LH1,HH1] = imadj53itrans(X);
[LL2,HL2,LH2,HH2] = imadj53itrans(LL1);
[LL3,HL3,LH3,HH3] = imadj53itrans(LL2);

%{
% CDF 5/3 DWT の ||d_i||_2^2 の事前計算 
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

% スケーリング係数
sz0 = size(X);
sz1 = ceil(sz0/2);
sz2 = ceil(sz1/2);
sz3 = ceil(sz2/2);
cLL1 = di_sqrdnorm(1:sz1(1),1:sz1(2));
cHL1 = di_sqrdnorm(1:sz1(1),sz1(2)+1:end);
cLH1 = di_sqrdnorm(sz1(1)+1:end,1:sz1(2));
cHH1 = di_sqrdnorm(sz1(1)+1:end,sz1(2)+1:end);
cLL2 = cLL1(1:sz2(1),1:sz2(2));
cHL2 = cLL1(1:sz2(1),sz2(2)+1:end);
cLH2 = cLL1(sz2(1)+1:end,1:sz2(2));
cHH2 = cLL1(sz2(1)+1:end,sz2(2)+1:end);
cLL3 = cLL2(1:sz3(1),1:sz3(2));
cHL3 = cLL2(1:sz3(1),sz3(2)+1:end);
cLH3 = cLL2(sz3(1)+1:end,1:sz3(2));
cHH3 = cLL2(sz3(1)+1:end,sz3(2)+1:end);
%}

% 初期化（ゾーン符号化） y = Sc = STx
y_LL3 = LL3; %./cLL3;
y_HL3 = HL3; %./cHL3;
y_LH3 = LH3; %./cLH3;
%
c_HH3 = 0*HH3;
c_HL2 = 0*HL2;
c_LH2 = 0*LH2;
c_HH2 = 0*HH2;
c_HL1 = 0*HL1;
c_LH1 = 0*LH1;
c_HH1 = 0*HH1;

for iter = 1:nIters
    % 合成処理 v = DS.'y
    y_LL2 = im53itrans(y_LL3,y_HL3,y_LH3,c_HH3);
    y_LL1 = im53itrans(y_LL2,c_HL2,c_LH2,c_HH2);
    V = im53itrans(y_LL1,c_HL1,c_LH1,c_HH1);

    % 随伴処理 z = D.'(v-x) = D.'(DS.'y-x)
    [z_LL1,z_HL1,z_LH1,z_HH1] = imadj53itrans(V-X);
    [z_LL2,z_HL2,z_LH2,z_HH2] = imadj53itrans(z_LL1);
    [z_LL3,z_HL3,z_LH3,z_HH3] = imadj53itrans(z_LL2);

    % 勾配 ∇f(y) = Sz = SD.'(DS.'y-x)
    grad_LL3 = z_LL3;
    grad_HL3 = z_HL3;
    grad_LH3 = z_LH3;

    % 係数更新 y ← y - μ∇f(y)
    y_LL3 = y_LL3 - mu*grad_LL3;
    y_HL3 = y_HL3 - mu*grad_HL3;
    y_LH3 = y_LH3 - mu*grad_LH3;

    % モニタリング
    if iter == 1
        subplot(1,3,3)
        him = imshow(V);
        stt = "CDF 5/3 DWT 最小二乗法 ";
        htt = title(stt + "(t: " + num2str(iter) + ", PSNR:"+num2str(psnr(X,V))+" dB)");
        drawnow
    elseif mod(iter,100)==0 
        him.CData = gather(V);
        htt.String = stt + "(t: " + num2str(iter) + ", PSNR:"+num2str(psnr(X,V))+" dB)";
        drawnow
    end
end

% ゾーン符号化 c = y
c_LL3 = y_LL3;
c_HL3 = y_HL3;
c_LH3 = y_LH3;

% 合成処理 v = DS.'c
c_LL2 = im53itrans(c_LL3,c_HL3,c_LH3,c_HH3);
c_LL1 = im53itrans(c_LL2,c_HL2,c_LH2,c_HH2);
V = im53itrans(c_LL1,c_HL1,c_LH1,c_HH1);

% 結果表示
him.CData = V;
htt.String = stt + "(t: " + num2str(nIters) + ", PSNR:"+num2str(psnr(X,V))+" dB)";
drawnow
imwrite(V,fullfile(resfolder,myfilename+"dwtls"),imgfmt)

%{
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

elseif strcmp(option, 'ana')

    [LL1,HL1,LH1,HH1] = im53trans(x);
    [LL2,HL2,LH2,HH2] = im53trans(LL1);
    [LL3,HL3,LH3,HH3] = im53trans(LL2);
    Y2 = cat(1,cat(2,LL3,HL3),cat(2,LH3,HH3));
    Y1 = cat(1,cat(2,Y2,HL2),cat(2,LH2,HH2));
    y = cat(1,cat(2,Y1,HL1),cat(2,LH1,HH1));

else
    error('不正なオプションです')
end
end
%}