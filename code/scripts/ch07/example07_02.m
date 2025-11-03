% 例7.2 （ゾーン符号化と最小二乗法）
%村松正吾　「多次元信号・画像処理の基礎と展開」
%動作確認： MATLAB R2025b
%準備
isVerbose = false;
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
subplot(1,3,1)
imshow(X)
title('原画像')

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
title("CDF 5/3 DWT　ゾーン符号化 (PSNR:"+psnr(X,V)+" dB)")

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
nIters = 1000; % 繰り返し回数
nLv = 3; % ツリー段数
gain2d = 4; % HH フィルタのゲイン
kappa = (gain2d^nLv)^2; % スペクトルノルム||DS||_S の二乗
mu = 0.9*(2/kappa); % ステップサイズ

% 分析処理 c = Tx
[LL1,HL1,LH1,HH1] = im53trans(X);
[LL2,HL2,LH2,HH2] = im53trans(LL1);
[LL3,HL3,LH3,HH3] = im53trans(LL2);

% 初期化（ゾーン符号化） y = Sc = STx
y_LL3 = LL3;
y_HL3 = HL3;
y_LH3 = LH3;
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

    % 係数更新 y <- y - μ∇f(y)
    y_LL3 = y_LL3 - mu*grad_LL3;
    y_HL3 = y_HL3 - mu*grad_HL3;
    y_LH3 = y_LH3 - mu*grad_LH3;
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
subplot(1,3,3)
imshow(V)
title("CDF 5/3 DWT 最小二乗法 (PSNR:"+psnr(X,V)+" dB)")
