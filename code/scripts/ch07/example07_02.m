% 例7.1 （ゾーン符号化と最小二乗法）
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

% 分析処理
[LL1,HL1,LH1,HH1] = im53trans(X);
[LL2,HL2,LH2,HH2] = im53trans(LL1);
[LL3,HL3,LH3,HH3] = im53trans(LL2);

% ゾーン符号化
LL3 = 1*LL3;
HL3 = 1*HL3;
LH3 = 1*LH3;
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
title("CDF 5/3 DWT (PSNR:"+psnr(X,V)+" dB")

%% 最小二乗法
% <x,v> = <x,Du> = <D'x,u> = <y,Tv>
V = rand(size(X),'like',X); % v = Du
a = dot(X(:),V(:))
[YLL,YHL,YLH,YHH] = imadj53itrans(X); % D'x
[ULL,UHL,ULH,UHH] = im53trans(V); % Tv
Y = cat(3,YLL,YHL,YLH,YHH);
U = cat(3,ULL,UHL,ULH,UHH);
b = dot(Y(:),U(:))
assert(a==b,"随伴関係が成り立ちません")
% TODO 境界処理の見直し

%%
function [subLL,subHL,subLH,subHH] = im53trans(fullPicture)
%
% im53trans
%
% Copyright (C) 2005-2025 Shogo MURAMATSU, All rights reserved
%

fullPicture = double(fullPicture);

% 垂直変換（インプレース演算）
fullPicture = predictionStep(fullPicture,-1/2);
fullPicture = updateStep(fullPicture,1/4);

% 水平変換（インプレース演算）
fullPicture = predictionStep(fullPicture.',-1/2);
fullPicture = updateStep(fullPicture,1/4).';

% 係数並べ替え
subLL = fullPicture(1:2:end,1:2:end,:);
subHL = fullPicture(1:2:end,2:2:end,:);
subLH = fullPicture(2:2:end,1:2:end,:);
subHH = fullPicture(2:2:end,2:2:end,:);

end

%%
function fullPicture = im53itrans(subLL,subHL,subLH,subHH)
%
% im53itrans
%
% Copyright (C) 2005-2025 Shogo MURAMATSU, All rights reserved
%

% 配列の準備
fullSize = size(subLL) + size(subHH);
fullPicture = zeros(fullSize);

% 係数並べ替え
fullPicture(1:2:end,1:2:end,:) = subLL;
fullPicture(1:2:end,2:2:end,:) = subHL;
fullPicture(2:2:end,1:2:end,:) = subLH;
fullPicture(2:2:end,2:2:end,:) = subHH;

% 水平変換（インプレース演算）
fullPicture = updateStep(fullPicture.',-1/4);
fullPicture = predictionStep(fullPicture,1/2).';

% 垂直変換（インプレース演算）
fullPicture = updateStep(fullPicture,-1/4);
fullPicture = predictionStep(fullPicture,1/2);

end

%%
function [subLL,subHL,subLH,subHH] = imadj53itrans(fullPicture)
%
% imadj53itrans
%
% Copyright (C) 2005-2025 Shogo MURAMATSU, All rights reserved
%

fullPicture = double(fullPicture);

% 垂直変換（インプレース演算）
fullPicture = updateStep(fullPicture,1/2);
fullPicture = predictionStep(fullPicture,-1/4);

% 水平変換（インプレース演算）
fullPicture = updateStep(fullPicture.',1/2);
fullPicture = predictionStep(fullPicture,-1/4).';

% 係数並べ替え
subLL = fullPicture(1:2:end,1:2:end,:);
subHL = fullPicture(1:2:end,2:2:end,:);
subLH = fullPicture(2:2:end,1:2:end,:);
subHH = fullPicture(2:2:end,2:2:end,:);

end

%%
function picture = predictionStep(picture,p)
%
% predictionStep
%
% Copyright (C) 2005-2025 Shogo MURAMATSU, All rights reserved
%

if (mod(size(picture,1),2)==0)
    picture(2:2:end,:,:) = imlincomb(...
        p, picture(1:2:end,:,:), ...
        1, picture(2:2:end,:,:), ...
        p, [picture(3:2:end,:,:); picture(end-1,:,:)] ...
        );
else
    picture(2:2:end,:,:) = imlincomb(...
        p, picture(1:2:end-2,:,:), ...
        1, picture(2:2:end,:,:), ...
        p, picture(3:2:end,:,:) ...
        );
end
end

%%
function picture = updateStep(picture,u)
%
% updateStep
%
% Copyright (C) 2005-2025 Shogo MURAMATSU, All rights reserved
%
if (mod(size(picture,1),2)==0)
    picture(1:2:end,:,:) = imlincomb(...
        u, [picture(2,:,:); picture(2:2:end-1,:,:)], ...
        1, picture(1:2:end,:,:), ...
        u, picture(2:2:end,:,:) ...
        );
else
    picture(1:2:end,:,:) = imlincomb(...
        u, [picture(2,:,:); picture(2:2:end-1,:,:)], ...
        1, picture(1:2:end,:,:), ...
        u, [picture(2:2:end,:,:); picture(end-1,:,:)] ...
        );
end
end