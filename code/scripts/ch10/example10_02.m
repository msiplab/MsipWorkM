%[text] # 例題10.2（ノイズ除去ネットワーク：辞書選択型TNRD）
%[text] 村松正吾　「多次元信号・画像処理の基礎と展開」
%[text] 動作確認： MATLAB R2026a
%[text] ## 辞書の選択（変更可能）
%[text] | dictType | 辞書 | P | パーセバルタイト条件 | 維持方法 |
%[text] |----------|------|---|-------------------|---------|
%[text] | `'tied'` | 結合重みTNRD | 32 | ×（学習依存） | — |
%[text] | `'parseval'` | パーセバルタイト枠TNRD | 32 | ✓（$P>N$） | SVD射影 |
%[text] | `'unitary'` | ユニタリフィルタバンクTNRD | 25 | ✓（$P=N$） | SVD射影 |
dictType = 'tied';
% dictType = 'parseval';
% dictType = 'unitary';
%%
%[text] ## 準備
prj = matlab.project.currentProject;
prjroot = prj.RootFolder;
datfolder = fullfile(prjroot,"data");
resfolder = fullfile(prjroot,"results");
myfilename = "example10_02"; %#ok<NASGU>

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
%[text] ## 学習済みパラメータの読込または学習
%[text] ### TNRD の残差除去器
%[text]  $\mathbf{f}_{\bmTheta}(\mathbf{v}) = \mathbf{v} - \lambda\,\mathbf{g}_{\bmTheta}(\mathbf{v})$
%[text]  $\mathbf{g}_{\bmTheta}(\mathbf{v}) = \mathbf{D}_{\bmtheta} \phi(\mathbf{E}_{\bmtheta}\,\mathbf{v})$，  $\mathbf{E}_{\bmtheta} \overset{\text{def}}{=} \mathbf{D}_{\bmtheta}^\top$（結合重み）
%[text]
%[text] 辞書 $\mathbf{D}_{\bmtheta}$ の選択により，異なる拘束条件（パーセバルタイト，ユニタリ，NSOLT）を実現する。
dataFile = fullfile(datfolder, sprintf('example10_02_%s.mat', dictType));
X_dl = dlarray(X,'SSCB');

if isfile(dataFile)
    fprintf("[%s] 学習済みパラメータを読込: %s\n", dictType, dataFile)
    S = load(dataFile);
else
    fprintf("[%s] 学習を開始します...\n", dictType)
    switch dictType
        %%
        %[text] ### `'tied'`：結合重みTNRD（パーセバルタイト条件なし，P=32）
        %[text] 分析行列 $\mathbf{W}_a \in \mathbb{R}^{32 \times 25}$ を学習パラメータとし，
        %[text] $\mathbf{g} = \mathbf{W}_a^\top \tanh(\mathbf{W}_a \mathbf{v})$（転置畳み込みで結合重みを実現）
        case 'tied'
            P = 32; fs = 5; N = fs*fs;
            Wa = dlarray(randn(fs, fs, 1, P, 'single') / sqrt(P*N));
            ba = dlarray(zeros(P, 1, 'single'));
            bs = dlarray(zeros(1, 1, 'single'));
            loglambda = dlarray(log(single(1.0)));
            lr = 1e-3; beta1=0.9; beta2=0.999; eps_a=1e-8;
            avgG_Wa=[]; avgSqG_Wa=[]; avgG_ba=[]; avgSqG_ba=[];
            avgG_bs=[]; avgSqG_bs=[]; avgG_lam=single(0); avgSqG_lam=single(0);
            for epoch = 1:1000
                V_dl = dlarray(X + sigmaW*randn(size(X),'single'),'SSCB');
                [~,gWa,gba,gbs,glam] = dlfeval(@convTnrdLoss,Wa,ba,bs,loglambda,V_dl,X_dl);
                [Wa,avgG_Wa,avgSqG_Wa] = adamupdate(Wa,gWa,avgG_Wa,avgSqG_Wa,epoch,lr,beta1,beta2,eps_a);
                [ba,avgG_ba,avgSqG_ba] = adamupdate(ba,gba,avgG_ba,avgSqG_ba,epoch,lr,beta1,beta2,eps_a);
                [bs,avgG_bs,avgSqG_bs] = adamupdate(bs,gbs,avgG_bs,avgSqG_bs,epoch,lr,beta1,beta2,eps_a);
                [loglambda,avgG_lam,avgSqG_lam] = adamupdate(loglambda,glam,avgG_lam,avgSqG_lam,epoch,lr,beta1,beta2,eps_a);
                if mod(epoch,200)==0
                    lf = exp(double(extractdata(loglambda)));
                    Xh = convTnrdDenoise(Wa,ba,bs,lf,V);
                    fprintf("  epoch %4d: PSNR=%.2f dB, λ=%.4f\n",epoch,psnr(Xh,double(X)),lf)
                end
            end
            S = struct('Wa',Wa,'ba',ba,'bs',bs,'loglambda',loglambda,'dictType',dictType);
            %%
            %[text] ### `'parseval'`：パーセバルタイト枠TNRD（シュティーフェル多様体，P=32>N=25）
            %[text] **条件**: $\mathbf{W}_a^\top \mathbf{W}_a = \mathbf{I}_N$（過完備パーセバルタイト枠，$P > N$）
            %[text] **維持**: 各エポック後にSVD射影 $\mathbf{W}_a \leftarrow \mathbf{U}\mathbf{V}^\top$
        case 'parseval'
            P = 32; fs = 5; N = fs*fs;
            D1 = single(dctmtx(fs));
            D2 = kron(D1,D1);
            [U0,~,V0] = svd([D2; randn(P-N,N,'single')],'econ');
            Wa = dlarray(permute(reshape(single(U0*V0'),P,fs,fs,1),[2,3,4,1]));
            ba = dlarray(zeros(P,1,'single'));
            bs = dlarray(zeros(1,1,'single'));
            loglambda = dlarray(log(single(0.1)));
            lr = 2e-3; beta1=0.9; beta2=0.999; eps_a=1e-8;
            avgG_Wa=[]; avgSqG_Wa=[]; avgG_ba=[]; avgSqG_ba=[];
            avgG_bs=[]; avgSqG_bs=[]; avgG_lam=single(0); avgSqG_lam=single(0);
            for epoch = 1:2000
                V_dl = dlarray(X + sigmaW*randn(size(X),'single'),'SSCB');
                [~,gWa,gba,gbs,glam] = dlfeval(@convTnrdLoss,Wa,ba,bs,loglambda,V_dl,X_dl);
                [Wa,avgG_Wa,avgSqG_Wa] = adamupdate(Wa,gWa,avgG_Wa,avgSqG_Wa,epoch,lr,beta1,beta2,eps_a);
                [ba,avgG_ba,avgSqG_ba] = adamupdate(ba,gba,avgG_ba,avgSqG_ba,epoch,lr,beta1,beta2,eps_a);
                [bs,avgG_bs,avgSqG_bs] = adamupdate(bs,gbs,avgG_bs,avgSqG_bs,epoch,lr,beta1,beta2,eps_a);
                [loglambda,avgG_lam,avgSqG_lam] = adamupdate(loglambda,glam,avgG_lam,avgSqG_lam,epoch,lr,beta1,beta2,eps_a);
                if mod(epoch,10)==0  % シュティーフェル射影（10エポックごと）
                    Wa_m = reshape(permute(single(extractdata(Wa)),[4,1,2,3]),P,N);
                    [Ue,~,Ve] = svd(Wa_m,'econ');
                    Wa = dlarray(permute(reshape(single(Ue*Ve'),P,fs,fs,1),[2,3,4,1]));
                end
                if mod(epoch,400)==0
                    lf = exp(double(extractdata(loglambda)));
                    Xh = convTnrdDenoise(Wa,ba,bs,lf,V);
                    Wa_m = reshape(permute(single(extractdata(Wa)),[4,1,2,3]),P,N);
                    err = norm(Wa_m'*Wa_m-eye(N),'fro');
                    fprintf("  epoch %4d: PSNR=%.2f dB, λ=%.4f, ||W^TW-I||=%.2e\n",...
                        epoch,psnr(Xh,double(X)),lf,err)
                end
            end
            S = struct('Wa',Wa,'ba',ba,'bs',bs,'loglambda',loglambda,'dictType',dictType);
            %%
            %[text] ### `'unitary'`：ユニタリフィルタバンクTNRD（P=N=25，正規直交）
            %[text] **条件**: $\mathbf{W}_a^\top \mathbf{W}_a = \mathbf{W}_a \mathbf{W}_a^\top = \mathbf{I}_N$（正方直交行列）
            %[text] パーセバルタイト枠の重みの最初のN行を取り出してSVD直交化
        case 'unitary'
            fs = 5; N = fs*fs; P = N;
            ptFile = fullfile(datfolder,'example10_02_parseval.mat');
            if ~isfile(ptFile)
                error("先に dictType='parseval' を実行してください（%s が必要）", ptFile)
            end
            Spt = load(ptFile);
            Wa_pt  = single(extractdata(Spt.Wa));
            Wa_mat = reshape(permute(Wa_pt,[4,1,2,3]),32,N);
            [Uu,~,Vu] = svd(Wa_mat(1:N,:));
            Wa = dlarray(permute(reshape(single(Uu*Vu'),P,fs,fs,1),[2,3,4,1]));
            ba_tmp = single(extractdata(Spt.ba));
            ba = dlarray(ba_tmp(1:P));
            bs = Spt.bs;
            loglambda = Spt.loglambda;
            S = struct('Wa',Wa,'ba',ba,'bs',bs,'loglambda',loglambda,'dictType',dictType);
    end
    save(dataFile, '-struct', 'S')
    fprintf("[%s] 保存完了: %s\n", dictType, dataFile)
end
%%
%[text] ## AWGN除去の評価
lambda_f = exp(double(extractdata(S.loglambda)));
X_hat = convTnrdDenoise(S.Wa, S.ba, S.bs, lambda_f, V);
psnr_result = psnr(X_hat, double(X));
fprintf("[%s] AWGN除去 PSNR: %.2f dB (λ=%.4f)\n", S.dictType, psnr_result, lambda_f)
%%
%[text] ## 比較（利用可能な全辞書タイプ）
fprintf("\n=== AWGN除去 PSNR 比較 ===\n")
fprintf("  観測 PSNR: %.2f dB\n", psnr_noisy)
dictTypes = {'tied','parseval','unitary'};
labels    = {'結合重み (P=32)','パーセバルタイト枠 (P=32)','ユニタリ (P=25)'};
for i = 1:numel(dictTypes)
    f = fullfile(datfolder, sprintf('example10_02_%s.mat', dictTypes{i}));
    if isfile(f)
        Si = load(f);
        li = exp(double(extractdata(Si.loglambda)));
        Xhi = convTnrdDenoise(Si.Wa, Si.ba, Si.bs, li, V);
        fprintf("  %-22s: %.2f dB\n", labels{i}, psnr(Xhi,double(X)))
    end
end
%%
%[text] ## 結果の表示
figure(1)
subplot(1,3,1); imshow(double(X));   title('原画像','FontSize',11)
subplot(1,3,2); imshow(double(V));   title(sprintf('観測\n(%.2f dB)',psnr_noisy),'FontSize',11)
subplot(1,3,3); imshow(X_hat);       title(sprintf('[%s]\n(%.2f dB)',S.dictType,psnr_result),'FontSize',11)
imwrite(X_hat, fullfile(resfolder,sprintf('fig10-02a_%s.png',S.dictType)))

%%
%[text] ## 【関数定義】

function [loss, gWa, gba, gbs, glam] = convTnrdLoss(Wa, ba, bs, loglambda, V, X_star)
Y = dlconv(V, Wa, ba, 'Padding','same');
G = dltranspconv(tanh(Y), Wa, bs, 'Cropping','same');
lam = exp(loglambda);
loss = mean((X_star - (V - lam*G)).^2, 'all');
[gWa, gba, gbs, glam] = dlgradient(loss, Wa, ba, bs, loglambda);
end

function x_out = convTnrdDenoise(Wa, ba, bs, lambda_f, x_in)
V_dl  = dlarray(single(x_in),'SSCB');
Y     = dlconv(V_dl, Wa, ba, 'Padding','same');
G     = dltranspconv(tanh(Y), Wa, bs, 'Cropping','same');
x_out = double(x_in) - lambda_f * double(extractdata(G));
x_out = min(max(x_out,0),1);
end

%[text] © Copyright, Shogo MURAMATSU, All rights reserved.

%[appendix]{"version":"1.0"}
