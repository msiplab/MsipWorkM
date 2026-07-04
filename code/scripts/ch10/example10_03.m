%[text] # 例題10.3（PnP-PG法・RED-GD法：ノイズ除去駆動型画像復元）
%[text] 村松正吾　「多次元信号・画像処理の基礎と展開」
%[text] 動作確認： MATLAB R2026a
%[text] ## 辞書の選択（変更可能）
%[text] 例題10.2で学習した辞書を選択する（先に例題10.2を実行すること）
dictType = 'tied';
% dictType = 'parseval';
% dictType = 'unitary';
%%
%[text] ## 準備
prj = matlab.project.currentProject;
prjroot = prj.RootFolder;
datfolder = fullfile(prjroot,"data");
resfolder = fullfile(prjroot,"results");
myfilename = "example10_03"; %#ok<NASGU>

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
%[text] ## 観測モデルの設定（ガウスぼかし + AWGN）
%[text]  $\mathbf{v} = \mathbf{H}\mathbf{x} + \mathbf{w}$，$\mathbf{H}$: $9\times 9$ ガウスぼかし（$\sigma_k=2$），$\sigma_w=5/255$
sigmaK = 2.0;
blurKernel = fspecial('gaussian', 9, sigmaK);
H_op  = @(x) imfilter(x, blurKernel, 'circular');
Ht_op = @(x) imfilter(x, rot90(blurKernel,2), 'circular');
sigmaW = 5/255;
V = H_op(X) + sigmaW * randn(size(X));
psnr_obs = psnr(V, X);
fprintf("観測 PSNR: %.2f dB\n", psnr_obs)
%%
%[text] ## ノイズ除去器の読込（例題10.2の学習結果）
%[text] PnP法・RED法ともに，AWGN除去器 $f(\cdot)$ をプラグインとして使用する。
%[text] **PnP-PG法**: 近接写像 $\mathrm{prox}_{\mu\mathfrak{R}}(\cdot)$ を $f(\cdot)$ で置き換え
%[text] **RED-GD法**: 正則化関数 $\mathfrak{R}_{\mathrm{RED}}(\mathbf{x})=\frac{1}{2}\mathbf{x}^\top(\mathbf{x}-f(\mathbf{x}))$ の勾配 $\mathbf{x}-f(\mathbf{x})$ を利用
denoiserFile = fullfile(datfolder, sprintf('example10_02_%s.mat', dictType));
if ~isfile(denoiserFile)
    error("先に例題10.2 (dictType='%s') を実行してください", dictType)
end
S = load(denoiserFile);
lambda_f = exp(double(extractdata(S.loglambda)));
denoiser = @(x) convTnrdDenoise(S.Wa, S.ba, S.bs, lambda_f, x);
fprintf("[%s] ノイズ除去器を読込 (λ=%.4f)\n", dictType, lambda_f)
%%
%[text] ## ウィナーフィルタ（比較基準）
H_freq = psf2otf(blurKernel, szOrg);
X_wiener = real(ifft2(fft2(V) .* conj(H_freq) ./ (abs(H_freq).^2 + sigmaW^2)));
X_wiener = min(max(X_wiener,0),1);
psnr_wiener = psnr(X_wiener, X);
fprintf("ウィナーフィルタ PSNR: %.2f dB\n", psnr_wiener)
%%
%[text] ## PnP-PG法による画像復元
%[text] **反復**:
%[text]  $\mathbf{x}^{(t+1)} \leftarrow f\!\left(\mathbf{x}^{(t)} - \mu\mathbf{H}^\top(\mathbf{H}\mathbf{x}^{(t)}-\mathbf{v})\right)$
%[text]
%[text] **収束条件（堅非拡大写像）**: $f(\cdot)$ が堅非拡大写像であれば PnP-PG は収束する。
%[text] TNRD（結合重み）では $\lambda \le 1 / \max_p \|\phi_p'\|_\infty$ のとき成立（例題10.3本文参照）。
mu_pnp = 0.9;
nIters = 200;
x_pnp = V;
psnrs_pnp = zeros(nIters,1);
for iter = 1:nIters
    x_pnp = denoiser(x_pnp - mu_pnp * Ht_op(H_op(x_pnp) - V));
    x_pnp = min(max(x_pnp,0),1);
    psnrs_pnp(iter) = psnr(x_pnp, X);
end
psnr_pnp = psnrs_pnp(nIters);
fprintf("PnP-PG PSNR: %.2f dB\n", psnr_pnp)
%%
%[text] ## RED-GD法による画像復元
%[text] **反復**:
%[text]  $\mathbf{x}^{(t+1)} \leftarrow \mathbf{x}^{(t)} - \mu\!\left[\mathbf{H}^\top(\mathbf{H}\mathbf{x}^{(t)}-\mathbf{v}) + \lambda_r(\mathbf{x}^{(t)}-f(\mathbf{x}^{(t)}))\right]$
%[text]
%[text] **ヤコビ行列の対称性**: RED法の正則化が意味を持つ（対応する正則化関数が存在する）ための条件。
%[text] Tied TNRD は結合重みにより理論上ゼロ。
mu_red  = 0.5;
lambda_r = 0.1;
x_red = V;
psnrs_red = zeros(nIters,1);
for iter = 1:nIters
    grad_data = Ht_op(H_op(x_red) - V);
    grad_reg  = x_red - denoiser(x_red);
    x_red = x_red - mu_red * (grad_data + lambda_r * grad_reg);
    x_red = min(max(x_red,0),1);
    psnrs_red(iter) = psnr(x_red, X);
end
psnr_red = psnrs_red(nIters);
fprintf("RED-GD PSNR: %.2f dB\n", psnr_red)
%%
%[text] ## 比較まとめ
fprintf("\n=== 復元結果の比較 [%s] ===\n", dictType)
fprintf("  観測          : %.2f dB\n", psnr_obs)
fprintf("  ウィナーフィルタ: %.2f dB\n", psnr_wiener)
fprintf("  PnP-PG       : %.2f dB\n", psnr_pnp)
fprintf("  RED-GD       : %.2f dB\n", psnr_red)
%%
%[text] ## 結果の表示
fontSize = 12;
figure(1)
subplot(1,5,1); imshow(X);        title('原画像','FontSize',fontSize)
subplot(1,5,2); imshow(V);        title(sprintf('観測\n(%.2f dB)',psnr_obs),'FontSize',fontSize)
subplot(1,5,3); imshow(X_wiener); title(sprintf('ウィナー\n(%.2f dB)',psnr_wiener),'FontSize',fontSize)
subplot(1,5,4); imshow(x_pnp);   title(sprintf('PnP-PG\n(%.2f dB)',psnr_pnp),'FontSize',fontSize)
subplot(1,5,5); imshow(x_red);   title(sprintf('RED-GD\n(%.2f dB)',psnr_red),'FontSize',fontSize)
imwrite(x_pnp, fullfile(resfolder,sprintf('fig10-03a_pnp_%s.png',dictType)))
imwrite(x_red, fullfile(resfolder,sprintf('fig10-03b_red_%s.png',dictType)))

figure(2)
plot(1:nIters, psnrs_pnp,'b-','LineWidth',1.5,'DisplayName','PnP-PG')
hold on
plot(1:nIters, psnrs_red,'r-','LineWidth',1.5,'DisplayName','RED-GD')
yline(psnr_wiener,'k--','LineWidth',1.5,'Label','ウィナー')
hold off
xlabel('反復数','FontSize',fontSize)
ylabel('PSNR [dB]','FontSize',fontSize)
title(sprintf('PnP-PG vs RED-GD [%s]',dictType),'FontSize',fontSize)
legend('Location','southeast','FontSize',10)
grid on
set(gcf,'PaperUnits','inches','PaperSize',[8.26 5.16],'PaperPosition',[0 0 8.26 5.16])
print(gcf, fullfile(resfolder,sprintf('fig10-03c_%s.png',dictType)),'-dpng','-r96')

%%
%[text] ## 【関数定義】

function x_out = convTnrdDenoise(Wa, ba, bs, lambda_f, x_in)
V_dl  = dlarray(single(x_in),'SSCB');
Y     = dlconv(V_dl, Wa, ba, 'Padding','same');
G     = dltranspconv(tanh(Y), Wa, bs, 'Cropping','same');
x_out = double(x_in) - lambda_f * double(extractdata(G));
x_out = min(max(x_out,0),1);
end

%[text] © Copyright, Shogo MURAMATSU, All rights reserved.

%[appendix]{"version":"1.0"}
