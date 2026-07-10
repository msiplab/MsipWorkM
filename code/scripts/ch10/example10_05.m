%[text] # 例10.5（スコアベースRED法）
%[text] 村松正吾　「多次元信号・画像処理の基礎と展開」
%[text] 動作確認： MATLAB R2026a
%[text] ## 準備
%[text] 事前学習済みSBDMのノイズレベル条件付き除去器 $f(\\cdot;\\sigma)$ として，
%[text] 例10.2の結合重みTNRDをノイズレベル条件付きに拡張したモデルを用いる。
%[text] Tweedieの公式より除去器の残差の大きさは $\\sigma$ に比例するため，
%[text] 残差を $\\sigma$ でスケーリングする
%[text]  $f(\\mathbf{v};\\sigma)=\\mathbf{v}-\\sigma\\lambda\\,\\mathbf{W}\_a^\\top\\tanh(\\mathbf{W}\_a\\mathbf{v}+\\mathbf{b}\_a)$
%[text] とすれば，単一のネットワークで異なるノイズレベルに対応できる。
prj = matlab.project.currentProject;
prjroot = prj.RootFolder;
datfolder = fullfile(prjroot,"data");
resfolder = fullfile(prjroot,"results");
myfilename = "example10_05"; %#ok<NASGU>

imgname = "msipimg05";
imgfmt  = "tiff";

rng(0)
close all
%%
%[text] ## 画像データの読込
szOrg = [96 96];
imgfile = fullfile(datfolder,imgname);
X = imresize(im2double(rgb2gray(imread(imgfile,imgfmt))),szOrg,'bilinear');
%%
%[text] ## 観測モデルの設定
%[text] ガウスぼかし + AWGN: $\\mathbf{v}=\\mathbf{Hx}+\\mathbf{w}$ （例10.4と同一）
sigmaK = 2.0;
blurKernel = fspecial('gaussian', 9, sigmaK);
H   = @(x)   imfilter(x, blurKernel, 'circular');
Ht  = @(x)   imfilter(x, rot90(blurKernel,2), 'circular');

sigmaW = 5/255;
V = H(X) + sigmaW * randn(size(X));
psnr_obs = psnr(V, X);
fprintf("観測画像 PSNR: %.2f dB\n", psnr_obs)
%%
%[text] ## ノイズレベル条件付きTNRD除去器の学習または読込
%[text] 事例画像（kodim01〜08，復元対象とは別）に対し，ランダムな
%[text] ノイズレベル $\\sigma\\in\[\\sigma\_{\\min},\\sigma\_{\\max}\]$ のAWGN観測
%[text] $\\mathbf{v}\_\\sigma=\\mathbf{x}+\\mathbf{w}\_\\sigma$ を毎エポック生成して
%[text] MMSE規範で学習する（例10.2の 'tied' と同じ結合重み構造）。
sigmaMin = 2/255;
sigmaMax = 25/255;

tnrdFile = fullfile(datfolder,'example10_05_tnrd.mat');
if isfile(tnrdFile)
    S = load(tnrdFile);
    fprintf("σ条件付きTNRD除去器を読込: %s\n", tnrdFile)
else
    fprintf("σ条件付きTNRD除去器の学習を開始します...\n")
    nExemplars = 8;
    Es = cell(1, nExemplars);
    for idx = 1:nExemplars
        exfile = fullfile(datfolder, sprintf("kodim%02d.png", idx));
        Es{idx} = imresize(im2single(rgb2gray(imread(exfile))), szOrg, 'bilinear');
    end

    P = 32; fs = 5; N = fs*fs;
    Wa = dlarray(randn(fs, fs, 1, P, 'single') / sqrt(P*N));
    ba = dlarray(zeros(P, 1, 'single'));
    bs = dlarray(zeros(1, 1, 'single'));
    loglambda = dlarray(log(single(1.0)));
    lr = 1e-3; beta1=0.9; beta2=0.999; eps_a=1e-8;
    avgG_Wa=[]; avgSqG_Wa=[]; avgG_ba=[]; avgSqG_ba=[];
    avgG_bs=[]; avgSqG_bs=[]; avgG_lam=single(0); avgSqG_lam=single(0);
    for epoch = 1:2000
        E = Es{randi(nExemplars)};
        E_dl = dlarray(E,'SSCB');
        % 対数一様分布からノイズレベルを抽出
        sigma_e = single(exp(log(sigmaMin) + (log(sigmaMax)-log(sigmaMin))*rand));
        V_dl = dlarray(E + sigma_e*randn(size(E),'single'),'SSCB');
        [~,gWa,gba,gbs,glam] = dlfeval(@convCondTnrdLoss,Wa,ba,bs,loglambda,V_dl,E_dl,sigma_e);
        [Wa,avgG_Wa,avgSqG_Wa] = adamupdate(Wa,gWa,avgG_Wa,avgSqG_Wa,epoch,lr,beta1,beta2,eps_a);
        [ba,avgG_ba,avgSqG_ba] = adamupdate(ba,gba,avgG_ba,avgSqG_ba,epoch,lr,beta1,beta2,eps_a);
        [bs,avgG_bs,avgSqG_bs] = adamupdate(bs,gbs,avgG_bs,avgSqG_bs,epoch,lr,beta1,beta2,eps_a);
        [loglambda,avgG_lam,avgSqG_lam] = adamupdate(loglambda,glam,avgG_lam,avgSqG_lam,epoch,lr,beta1,beta2,eps_a);
        if mod(epoch,400)==0
            lf = exp(double(extractdata(loglambda)));
            sig_t = single(10/255);
            Vt = Es{1} + sig_t*randn(size(Es{1}),'single');
            Xh = convCondTnrdDenoise(Wa,ba,bs,lf,Vt,sig_t);
            fprintf("  epoch %4d: PSNR(σ=10/255)=%.2f dB, λ=%.4f\n", ...
                epoch,psnr(Xh,double(Es{1})),lf)
        end
    end
    S = struct('Wa',Wa,'ba',ba,'bs',bs,'loglambda',loglambda);
    save(tnrdFile, '-struct', 'S')
    fprintf("保存完了: %s\n", tnrdFile)
end
lambda_tnrd = exp(double(extractdata(S.loglambda)));

% ノイズレベル σ を条件とするAWGN除去器 f(・;σ)
deawgn = @(v, sigma) convCondTnrdDenoise(S.Wa, S.ba, S.bs, lambda_tnrd, v, sigma);
%%
%[text] ## スコアベースRED法による画像復元
%[text] 例10.4と同形の反復:
%[text]  $\\mathbf{x}^{(t+1)}\\leftarrow\\mathbf{x}^{(t)}-\\mu\\left\[\\mathbf{H}^\\top(\\mathbf{H}\\mathbf{x}^{(t)}-\\mathbf{v})+\\lambda(\\mathbf{x}^{(t)}-f(\\mathbf{x}^{(t)};\\sigma^{(t)}))\right\]$
%[text] ノイズレベル $\\sigma^{(t)}$ は正則化の強さを制御する調整パラメータであり，
%[text] (a) 固定値，(b) 大きな値から徐々に減衰させる設定を比較する。
%[text] さらに，(c) 除去器の入力に微小なノイズを注入する確率的な拡張
%[text] $f(\\mathbf{x}^{(t)}+\\sigma^{(t)}\\boldsymbol{\\zeta}^{(t)};\\sigma^{(t)})$ も実行する。
mu     = 0.5;   % ステップサイズ
lambda = 0.1;   % 正則化パラメータ
nIters = 200;

% (a) 固定ノイズレベル
sigmaFixed = 5/255;
% (b) 減衰スケジュール（対数的に減衰）
sigmaSchedule = exp(linspace(log(sigmaMax), log(sigmaMin), nIters));

labels = {'固定 \sigma', '減衰 \sigma^{(t)}', '確率的拡張'};       % 凡例用（TeX表記）
plainLabels = {'固定σ', '減衰σ(t)', '確率的拡張'};                 % 表示用
psnrs = zeros(nIters, 3);
xs = cell(1, 3);

for mode = 1:3
    rng(1)
    x_sred = V;  % 初期値: 観測画像
    for iter = 1:nIters
        if mode == 1
            sigma_t = sigmaFixed;
        else
            sigma_t = sigmaSchedule(iter);
        end

        % データフィデリティ項の勾配
        grad_data = Ht(H(x_sred) - V);

        % RED正則化項の勾配: x - f(x;σ)
        if mode == 3
            % 確率的拡張: 除去器の入力にノイズを注入
            zeta = randn(size(x_sred));
            grad_reg = x_sred - deawgn(x_sred + sigma_t * zeta, sigma_t);
        else
            grad_reg = x_sred - deawgn(x_sred, sigma_t);
        end

        % GD更新
        x_sred = x_sred - mu * (grad_data + lambda * grad_reg);
        x_sred = min(max(x_sred, 0), 1);
        psnrs(iter, mode) = psnr(x_sred, X);
    end
    xs{mode} = x_sred;
    fprintf("スコアベースRED (%s) PSNR: %.2f dB (反復数: %d)\n", ...
        plainLabels{mode}, psnrs(nIters, mode), nIters)
end
%%
%[text] ## ウィナーフィルタによる比較
H_freq = psf2otf(blurKernel, szOrg);
snr_est = 1 / sigmaW^2;
X_wiener = real(ifft2(fft2(V) .* conj(H_freq) ./ (abs(H_freq).^2 + 1/snr_est)));
X_wiener = min(max(X_wiener, 0), 1);
psnr_wiener = psnr(X_wiener, X);
fprintf("ウィナーフィルタ PSNR: %.2f dB\n", psnr_wiener)
%%
%[text] ## 結果の表示
fontSize = 14;

figure(1)
subplot(1,5,1); imshow(X);       title('原画像','FontSize',12)
subplot(1,5,2); imshow(V);       title(sprintf('観測 (%.2f dB)',psnr_obs),'FontSize',12)
subplot(1,5,3); imshow(xs{1});   title(sprintf('固定\\sigma (%.2f dB)',psnrs(nIters,1)),'FontSize',12)
subplot(1,5,4); imshow(xs{2});   title(sprintf('減衰\\sigma^{(t)} (%.2f dB)',psnrs(nIters,2)),'FontSize',12)
subplot(1,5,5); imshow(xs{3});   title(sprintf('確率的拡張 (%.2f dB)',psnrs(nIters,3)),'FontSize',12)
imwrite(xs{2}, fullfile(resfolder,'fig10-05a_verify.png'))

figure(2)
plot(1:nIters, psnrs(:,1), 'k-',  'LineWidth', 1.5)
hold on
plot(1:nIters, psnrs(:,2), 'k--', 'LineWidth', 1.5)
plot(1:nIters, psnrs(:,3), 'k:',  'LineWidth', 1.5)
hold off
xlabel('反復数','FontSize',fontSize)
ylabel('PSNR [dB]','FontSize',fontSize)
yline(psnr_wiener,'k-.','LineWidth',1.0,'Label','ウィナーフィルタ')
legend(labels{:}, 'Location', 'southeast')
title('スコアベースRED法: PSNRの収束')
set(gca,'FontSize',fontSize)
%%
%[text] ## 【関数定義】

function [loss, gWa, gba, gbs, glam] = convCondTnrdLoss(Wa, ba, bs, loglambda, V, X_star, sigma)
Y = dlconv(V, Wa, ba, 'Padding','same');
G = dltranspconv(tanh(Y), Wa, bs, 'Cropping','same');
lam = exp(loglambda);
loss = mean((X_star - (V - sigma*lam*G)).^2, 'all');
[gWa, gba, gbs, glam] = dlgradient(loss, Wa, ba, bs, loglambda);
end

function x_out = convCondTnrdDenoise(Wa, ba, bs, lambda_f, x_in, sigma)
V_dl  = dlarray(single(x_in),'SSCB');
Y     = dlconv(V_dl, Wa, ba, 'Padding','same');
G     = dltranspconv(tanh(Y), Wa, bs, 'Cropping','same');
x_out = double(x_in) - double(sigma) * lambda_f * double(extractdata(G));
x_out = min(max(x_out,0),1);
end

%[text] © Copyright, Shogo MURAMATSU, All rights reserved.

%[appendix]{"version":"1.0"}
