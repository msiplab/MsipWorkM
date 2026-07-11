%[text] # 例10.7（DIP-SURE：スタインの不偏リスク推定）
%[text] 村松正吾　「多次元信号・画像処理の基礎と展開」
%[text] 動作確認： MATLAB R2026a
%[text] ## 準備
prj = matlab.project.currentProject;
prjroot = prj.RootFolder;
datfolder = fullfile(prjroot,"data");
resfolder = fullfile(prjroot,"results");
myfilename = "example10_07"; %#ok<NASGU>

imgname = "msipimg05";
imgfmt  = "tiff";

rng(0)
close all
%%
%[text] ## 画像データの読込
szOrg = [96 96];
imgfile = fullfile(datfolder,imgname);
X = imresize(im2single(rgb2gray(imread(imgfile,imgfmt))),szOrg,'bilinear');
%%
%[text] ## ノイズ付加
sigmaW = single(25/255);
V = X + sigmaW * randn(size(X),'single');
psnr_noisy = psnr(double(V), double(X));
fprintf("観測画像 PSNR: %.2f dB\n", psnr_noisy)
%%
%[text] ## DIP-SUREネットワークの構築
%[text] DIP-SUREの問題設定（$\mathbf{H}=\mathbf{I}$ のノイズ除去）:
%[text]  $\hat{\mathbf{\Theta}}=\arg\min_{\mathbf{\Theta}}\;\mathrm{MSE}(\mathbf{f}_\Theta(\mathbf{v}),\mathbf{v})+\frac{2\sigma_w^2}{N}\mathrm{div}_\mathbf{v}(\mathbf{f}_\Theta(\mathbf{v}))$
%[text]  $\hat{\mathbf{x}}=\mathbf{f}_{\hat{\mathbf{\Theta}}}(\mathbf{v})$
%[text] DIPとの主な違い:
%[text] - 入力: 乱数画像 $\bm{\zeta}$ の代わりに観測画像 $\mathbf{v}$ を使用
%[text] - 損失: 発散項 $\mathrm{div}_\mathbf{v}(\cdot)$ を追加（過適合抑制）
%[text]
%[text] ### 発散項のモンテカルロ近似
%[text]  $\mathrm{div}_\mathbf{v}(\mathbf{f}(\mathbf{v}))\approx\bm{\zeta}^\top\frac{\mathbf{f}(\mathbf{v}+\epsilon\bm{\zeta})-\mathbf{f}(\mathbf{v})}{\epsilon}$
%[text] ただし $\bm{\zeta}\sim\mathcal{N}(\mathbf{0},\mathbf{I})$，$\epsilon\approx\sigma_w/100$
%[text]
%[text] ### ネットワーク構造（DIPと同じ砂時計型）
nCh = [16 32 64];

lgraph = layerGraph();
lgraph = addLayers(lgraph, imageInputLayer([szOrg 1],'Name','input','Normalization','none'));
lgraph = addLayers(lgraph, [convolution2dLayer(3,nCh(1),'Padding','same','Stride',2,'Name','e1'); reluLayer('Name','re1')]);
lgraph = addLayers(lgraph, [convolution2dLayer(3,nCh(2),'Padding','same','Stride',2,'Name','e2'); reluLayer('Name','re2')]);
lgraph = addLayers(lgraph, [convolution2dLayer(3,nCh(3),'Padding','same','Stride',2,'Name','e3'); reluLayer('Name','re3')]);
lgraph = addLayers(lgraph, transposedConv2dLayer(2,nCh(2),'Stride',2,'Name','d3'));
lgraph = addLayers(lgraph, reluLayer('Name','rd3'));
lgraph = addLayers(lgraph, depthConcatenationLayer(2,'Name','cat2'));
lgraph = addLayers(lgraph, [convolution2dLayer(3,nCh(2),'Padding','same','Name','d2'); reluLayer('Name','rd2')]);
lgraph = addLayers(lgraph, transposedConv2dLayer(2,nCh(1),'Stride',2,'Name','d2u'));
lgraph = addLayers(lgraph, reluLayer('Name','rd2u'));
lgraph = addLayers(lgraph, depthConcatenationLayer(2,'Name','cat1'));
lgraph = addLayers(lgraph, [convolution2dLayer(3,nCh(1),'Padding','same','Name','d1'); reluLayer('Name','rd1')]);
% 最終アップサンプリング 48×48 → 96×96
lgraph = addLayers(lgraph, transposedConv2dLayer(2,8,'Stride',2,'Name','d1u'));
lgraph = addLayers(lgraph, reluLayer('Name','rd1u'));
lgraph = addLayers(lgraph, convolution2dLayer(1,1,'Name','output'));

lgraph = connectLayers(lgraph,'input','e1');
lgraph = connectLayers(lgraph,'re1','e2');
lgraph = connectLayers(lgraph,'re2','e3');
lgraph = connectLayers(lgraph,'re3','d3');
lgraph = connectLayers(lgraph,'d3','rd3');
lgraph = connectLayers(lgraph,'rd3','cat2/in1');
lgraph = connectLayers(lgraph,'re2','cat2/in2');
lgraph = connectLayers(lgraph,'cat2','d2');
lgraph = connectLayers(lgraph,'rd2','d2u');
lgraph = connectLayers(lgraph,'d2u','rd2u');
lgraph = connectLayers(lgraph,'rd2u','cat1/in1');
lgraph = connectLayers(lgraph,'re1','cat1/in2');
lgraph = connectLayers(lgraph,'cat1','d1');
lgraph = connectLayers(lgraph,'rd1','d1u');
lgraph = connectLayers(lgraph,'d1u','rd1u');
lgraph = connectLayers(lgraph,'rd1u','output');

net = dlnetwork(lgraph,'Initialize',true);
fprintf("DIP-SUREネットワーク: %d 個の学習パラメータ\n", sum(cellfun(@numel, net.Learnables.Value)))
%%
%[text] ## DIP-SUREの学習
%[text] SURE損失: $\mathfrak{L}=\mathrm{MSE}(\mathbf{f}_\Theta(\mathbf{v}),\mathbf{v})+\frac{2\sigma_w^2}{N}\mathrm{div}_\mathbf{v}(\mathbf{f}_\Theta(\mathbf{v}))$

N = numel(V);
epsilon    = single(double(sigmaW) / 100);      % モンテカルロ近似用の小さな定数
sureCoeff  = single(2 * double(sigmaW)^2 / N);  % SURE損失係数 2σ²/N

V_dl = dlarray(V, 'SSCB');

% Adam状態（DIPより低い学習率・勾配クリッピングで安定化）
lr = 2e-4; beta1 = 0.9; beta2 = 0.999; eps_a = 1e-8;
gradClipNorm = 2.0;  % 勾配ノルムの上限（モンテカルロノイズ対策）
avgG_net = []; avgSqG_net = [];

nIters = 3000;
psnrs_sure  = zeros(nIters,1);
monitorStep = 100;

for iter = 1:nIters
    % モンテカルロ近似用の乱数ベクトル ζ（毎反復でサンプリング）
    zmc = randn(szOrg(1), szOrg(2), 1, 'single');
    zmc_dl = dlarray(zmc, 'SSCB');

    [loss, gradNet] = dlfeval(@dipSureLoss, net, V_dl, zmc_dl, epsilon, sureCoeff);

    % 勾配クリッピング（モンテカルロ推定のノイズによる発散を防ぐ）
    gradNorm = sqrt(sum(cellfun(@(g) sum(extractdata(g).^2, 'all'), gradNet.Value)));
    if gradNorm > gradClipNorm
        gradNet.Value = cellfun(@(g) g * (gradClipNorm/gradNorm), gradNet.Value, 'UniformOutput', false);
    end

    [net, avgG_net, avgSqG_net] = adamupdate(net, gradNet, avgG_net, avgSqG_net, iter, lr, beta1, beta2, eps_a);

    if mod(iter, monitorStep) == 0 || iter == 1
        x_hat = double(extractdata(predict(net, V_dl)));
        x_hat = min(max(x_hat, 0), 1);
        psnrs_sure(iter) = psnr(x_hat, double(X));
        fprintf("反復 %4d: PSNR = %.2f dB\n", iter, psnrs_sure(iter))
    end
end

X_sure = double(extractdata(predict(net, V_dl)));
X_sure = min(max(X_sure, 0), 1);
psnr_sure = psnr(X_sure, double(X));
fprintf("DIP-SURE 最終 PSNR: %.2f dB\n", psnr_sure)
%%
%[text] ## DIPとの比較（参照用）
%[text] 例10.5のDIPでは学習が進むにつれてノイズへの過適合が起こるが，
%[text] DIP-SUREでは発散項による正則化で安定した収束が期待される
%%
%[text] ## 結果の表示
fontSize = 14;

figure(1)
subplot(1,3,1); imshow(double(X)); title('原画像','FontSize',12)
subplot(1,3,2); imshow(double(V)); title(sprintf('観測 (%.2f dB)',psnr_noisy),'FontSize',12)
subplot(1,3,3); imshow(X_sure);    title(sprintf('DIP-SURE (%.2f dB)',psnr_sure),'FontSize',12)
imwrite(X_sure, fullfile(resfolder,'fig10-06a.png'))

figure(2)
iters_plot = monitorStep:monitorStep:nIters;
plot(iters_plot, psnrs_sure(monitorStep:monitorStep:end), 'k-', 'LineWidth', 1.5)
xlabel('反復数','FontSize',fontSize)
ylabel('PSNR [dB]','FontSize',fontSize)
title('DIP-SURE: PSNRの推移（安定した収束）')
set(gca,'FontSize',fontSize)
grid on
set(gcf,'PaperUnits','inches','PaperSize',[8.26 5.16],'PaperPosition',[0 0 8.26 5.16])
print(gcf, fullfile(resfolder,'fig10-06b.png'),'-dpng','-r96')

%%
%[text] ## 【関数定義】

function [loss, gradNet] = dipSureLoss(net, V, zmc, epsilon, sureCoeff)
%DIPSURE_LOSS  DIP-SUREの損失関数と勾配を計算する
%  SURE損失: MSE(f(v),v) + 2σ²/N * div_v(f(v))
%  発散のモンテカルロ近似: div_v(f) ≈ ζ^T*(f(v+ε*ζ)-f(v))/ε
f_V     = forward(net, V);
f_Vpert = forward(net, V + epsilon * zmc);

% 発散の近似 (スカラー)
div_v  = sum(zmc .* (f_Vpert - f_V), 'all') / epsilon;

% SURE損失: MSE + sureCoeff * div_v，  sureCoeff = 2σ²/N
mse_term = mean((V - f_V).^2, 'all');
loss     = mse_term + sureCoeff * div_v;

gradNet = dlgradient(loss, net.Learnables);
end

%[text] © Copyright, Shogo MURAMATSU, All rights reserved.

%[appendix]{"version":"1.0"}
