%[text] # 例10.5（DIP：深層画像事前分布）
%[text] 村松正吾　「多次元信号・画像処理の基礎と展開」
%[text] 動作確認： MATLAB R2026a
%[text] ## 準備
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
X = imresize(im2single(rgb2gray(imread(imgfile,imgfmt))),szOrg,'bilinear');
%%
%[text] ## ノイズ付加
sigmaW = single(25/255);
V = X + sigmaW * randn(size(X),'single');
psnr_noisy = psnr(double(V), double(X));
fprintf("観測画像 PSNR: %.2f dB\n", psnr_noisy)
%%
%[text] ## DIPネットワークの構築
%[text] DIPの問題設定 （$\mathbf{H}=\mathbf{I}$ のノイズ除去）:
%[text]  $\hat{\mathbf{\Theta}}=\arg\min_{\mathbf{\Theta}}\frac{1}{2}\|\mathbf{v}-\mathbf{f}_{\mathbf{\Theta}}(\bm{\zeta})\|^2_2$
%[text]  $\hat{\mathbf{x}}=\mathbf{f}_{\hat{\mathbf{\Theta}}}(\bm{\zeta})$
%[text] ただし，$\bm{\zeta}$ は乱数画像（固定），$\mathbf{f}_\Theta(\cdot)$ は砂時計型(U-Net) CNN
%[text]
%[text] ### ネットワーク構造（符号化器・復号器 + スキップ接続）
nCh = [16 32 64];   % チャネル数（各スケール）

lgraph = layerGraph();

% 符号化器 (stride=2 ダウンサンプリング)
lgraph = addLayers(lgraph, imageInputLayer([szOrg 1],'Name','input','Normalization','none'));
lgraph = addLayers(lgraph, [convolution2dLayer(3,nCh(1),'Padding','same','Stride',2,'Name','e1'); reluLayer('Name','re1')]);
lgraph = addLayers(lgraph, [convolution2dLayer(3,nCh(2),'Padding','same','Stride',2,'Name','e2'); reluLayer('Name','re2')]);
lgraph = addLayers(lgraph, [convolution2dLayer(3,nCh(3),'Padding','same','Stride',2,'Name','e3'); reluLayer('Name','re3')]);

% 復号器 (stride=2 アップサンプリング + スキップ接続)
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

% 接続
lgraph = connectLayers(lgraph,'input','e1');
lgraph = connectLayers(lgraph,'re1','e2');
lgraph = connectLayers(lgraph,'re2','e3');
lgraph = connectLayers(lgraph,'re3','d3');
lgraph = connectLayers(lgraph,'d3','rd3');
lgraph = connectLayers(lgraph,'rd3','cat2/in1');
lgraph = connectLayers(lgraph,'re2','cat2/in2');   % スキップ
lgraph = connectLayers(lgraph,'cat2','d2');
lgraph = connectLayers(lgraph,'rd2','d2u');
lgraph = connectLayers(lgraph,'d2u','rd2u');
lgraph = connectLayers(lgraph,'rd2u','cat1/in1');
lgraph = connectLayers(lgraph,'re1','cat1/in2');   % スキップ
lgraph = connectLayers(lgraph,'cat1','d1');
lgraph = connectLayers(lgraph,'rd1','d1u');
lgraph = connectLayers(lgraph,'d1u','rd1u');
lgraph = connectLayers(lgraph,'rd1u','output');

net = dlnetwork(lgraph,'Initialize',true);
fprintf("DIPネットワーク: %d 個の学習パラメータ\n", sum(cellfun(@numel, net.Learnables.Value)))
%%
%[text] ## DIPの学習
%[text] - 入力: 乱数画像 $\bm{\zeta}$（固定）
%[text] - 損失: $\mathrm{MSE}(\mathbf{f}_\Theta(\bm{\zeta}),\mathbf{v})$

% 乱数入力画像 ζ（固定）
zeta = randn(szOrg(1), szOrg(2), 1, 'single') * 0.1;
zeta_dl = dlarray(zeta, 'SSCB');
V_dl    = dlarray(V, 'SSCB');

% 観測画像とζを保存
imwrite(double(V), fullfile(resfolder,'fig10-03_obs.png'))
zeta_disp = (zeta(:,:,1) - min(zeta(:))) / (max(zeta(:)) - min(zeta(:)));
imwrite(zeta_disp, fullfile(resfolder,'fig10-03_zeta.png'))

% 0回目：学習前の初期出力
x_init = double(extractdata(predict(net, zeta_dl)));
x_init = min(max(x_init, 0), 1);
imwrite(x_init, fullfile(resfolder,'fig10-03_dip_000.png'))
fprintf("0回目（学習前）: PSNR = %.2f dB\n", psnr(x_init, double(X)))

% Adam状態
lr = 1e-3; beta1 = 0.9; beta2 = 0.999; eps_a = 1e-8;
avgG_net = []; avgSqG_net = [];

nIters = 3000;
psnrs_dip  = zeros(nIters,1);
monitorStep = 100;
saveIters = [1, 2, 3];  % 1〜3回目の保存タイミング
X_best = []; psnr_best_run = 0;

for iter = 1:nIters
    [loss, gradNet] = dlfeval(@dipLoss, net, zeta_dl, V_dl);
    [net, avgG_net, avgSqG_net] = adamupdate(net, gradNet, avgG_net, avgSqG_net, iter, lr, beta1, beta2, eps_a);

    if mod(iter, monitorStep) == 0 || ismember(iter, saveIters)
        x_hat = double(extractdata(predict(net, zeta_dl)));
        x_hat = min(max(x_hat, 0), 1);
        psnrs_dip(iter) = psnr(x_hat, double(X));
        fprintf("反復 %4d: PSNR = %.2f dB\n", iter, psnrs_dip(iter))
        if ismember(iter, saveIters)
            k = find(saveIters == iter, 1);
            imwrite(x_hat, fullfile(resfolder, sprintf('fig10-03_dip_%03d.png', k)))
            fprintf("  → %d回目の復元画像を保存 (反復%d)\n", k, iter)
        end
        if psnrs_dip(iter) > psnr_best_run
            psnr_best_run = psnrs_dip(iter);
            X_best = x_hat;
            iter_best_run = iter;
        end
    end
end
% 最良結果を保存
imwrite(X_best, fullfile(resfolder,'fig10-03_dip_best.png'))
fprintf("最良 PSNR: %.2f dB (反復%d) → fig10-03_dip_best.png\n", psnr_best_run, iter_best_run)
% 最終結果
X_dip = double(extractdata(predict(net, zeta_dl)));
X_dip = min(max(X_dip, 0), 1);
psnr_dip = psnr(X_dip, double(X));
fprintf("DIP 最終 PSNR: %.2f dB\n", psnr_dip)
%%
%[text] ## 早期停止の確認
%[text] 反復回数が多くなるとノイズへの過適合が起こる
[psnr_best, iter_best] = max(psnrs_dip(psnrs_dip > 0));
iter_best_full = iter_best * (psnrs_dip(1) == 0) + iter_best;  % 補正
fprintf("最高 PSNR: %.2f dB (反復 %d)\n", psnr_best, iter_best*monitorStep)
%%
%[text] ## 結果の表示
fontSize = 14;

figure(1)
subplot(1,3,1); imshow(double(X)); title('原画像','FontSize',12)
subplot(1,3,2); imshow(double(V)); title(sprintf('観測 (%.2f dB)',psnr_noisy),'FontSize',12)
subplot(1,3,3); imshow(X_dip);    title(sprintf('DIP (%.2f dB)',psnr_dip),'FontSize',12)
imwrite(X_dip, fullfile(resfolder,'fig10-03a.png'))

figure(2)
iters_plot = monitorStep:monitorStep:nIters;
plot(iters_plot, psnrs_dip(monitorStep:monitorStep:end), 'k-', 'LineWidth', 1.5)
xlabel('反復数','FontSize',fontSize)
ylabel('PSNR [dB]','FontSize',fontSize)
title('DIP: PSNRの推移（過適合の確認）')
set(gca,'FontSize',fontSize)
grid on
set(gcf,'PaperUnits','inches','PaperSize',[8.26 5.16],'PaperPosition',[0 0 8.26 5.16])
print(gcf, fullfile(resfolder,'fig10-03b.png'),'-dpng','-r96')

%%
%[text] ## 【関数定義】

function [loss, gradNet] = dipLoss(net, zeta, V)
%DIPLOSS  DIPの損失関数と勾配を計算する
%  問題設定: min_Θ MSE(f_Θ(ζ), v)
X_hat   = forward(net, zeta);
loss    = mean((V - X_hat).^2, 'all');
gradNet = dlgradient(loss, net.Learnables);
end

%[text] © Copyright, Shogo MURAMATSU, All rights reserved.

%[appendix]{"version":"1.0"}
