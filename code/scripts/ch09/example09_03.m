%[text] # 例9.3（畳み込み辞書学習）
%[text] 村松正吾　「多次元信号・画像処理の基礎と展開」
%[text] 動作確認： MATLAB R2026a
%[text] ## 準備
prj = matlab.project.currentProject;
prjroot = prj.RootFolder;
datfolder = fullfile(prjroot,"data");
resfolder = fullfile(prjroot,"results");
myfilename = "example09_03"; % mfilename

imgname = "msipimg05";
imgfmt = "tiff";

rng(0)
close all
%%
%[text] ## 画像データの読込
szOrg = [96 96];

imgfile = fullfile(datfolder,imgname);
X = imresize(im2double(rgb2gray(imread(imgfile,imgfmt))),szOrg,'bilinear');
yorg = X;
d = dir(fullfile(datfolder, imgname + ".*"));
file_yorg = fullfile(datfolder, d(1).name);

figure(1) %[output:5ecaaadf]
subplot(2,3,1) %[output:5ecaaadf]
imshow(X) %[output:5ecaaadf]
title('原画像') %[output:5ecaaadf]
%%

isForceDesign = false; % 再設計フラグ（true: 強制再設計, false: 既存ファイルがあればスキップ） %[control:checkbox:48c8]{"position":[17,21]}

isCodegen = true; % コード生成 %[control:checkbox:53ff]{"position":[13,17]}
msip.saivdrSetup(isCodegen) %[output:6a0ad264]
%%
%[text] ### パラメータ設定
%[text] - ブロックサイズ
%[text] - 冗長度
%[text] - スパース度 \
% Block size
szBlk = [ 8 8 ];
nPatches = prod(floor(szOrg./szBlk));

% Redundancy ratio for RICA/K-SVD
redundancyRatio = 5/4; 

% Sparsity ratio
sparsityRatio = 1/16;
%%
%[text] ## 
%[text] 零平均化
%ymean = mean(y,"all");
%y = yorg - ymean;
meansubtract = @(x) x-mean(x,"all");
y = meansubtract(yorg);
%[text] ## 
%%
%[text] ## 2変量ラティス構造冗長フィルタバンク
%[text] 例として，（偶対称チャネルと奇対称チャネルが等しい）偶数チャネル、偶数のポリフェーズ次数をもつタイプI非分離冗長重複変換(NSOLT)
%[text]  $\\mathbf{E}(z\_1,z\_2)\n=\n\\left(\\prod\_{n\_2=1}^{\\zeta\_2/2}\n{\\mathbf{V}\_{2n\_2}^{\\{2\\}}}\\bar{\\mathbf{Q}}(z\_2){\\mathbf{V}\_{2n\_2-1}^{\\{2\\}}}{\\mathbf{Q}}(z\_2)\\right)\n%\n\\left(\\prod\_{n\_1=1}^{\\zeta\_1/2}{\\mathbf{V}\_{2n\_1}^{\\{1\\}}}\\bar{\\mathbf{Q}}(z\_1){\\mathbf{V}\_{2n\_1-1}^{\\{1\\}}}{\\mathbf{Q}}(z\_1)\\right)\n%\n\\mathbf{V}\_0\\mathbf{E}\_0,$
%[text]  $\\mathbf{R}(z\_1,z\_2)\n=\\mathbf{E}^\\textsf{T}(z\_1^{-1},z\_2^{-1}),$
%[text] を採用する．ただし，
%[text] - $\\mathbf{E}(z\_1,z\_2)$:  分析フィルタバンクのType-I ポリフェーズ行列
%[text] - $\\mathbf{R}(z\_1,z\_2)$: 合成フィルタバンクのType-II ポリフェーズ行列
%[text] - $z\_d\\in\\mathbb{C}, d\\in\\{1,2\\}$: Z-変換の変数
%[text] - $\\zeta\_d\\in \\mathbb{N}, d\\in\\{1,2\\}$:方向 $d$ のポリフェーズ次数(重複ブロック数)
%[text] - $\\mathbf{V}\_0=\\left(\\begin{array}{cc}\\mathbf{W}\_{0} & \\mathbf{O} \\\\\\mathbf{O} & \\mathbf{U}\_0\\end{array}\\right)\n%\n\\left(\\begin{array}{c}\\mathbf{I}\_{M/2} \\\\ \n\\mathbf{O} \\\\\n\\mathbf{I}\_{M/2} \\\\\n\\mathbf{O}\n\\end{array}\\right)\\in\\mathbb{R}^{P\\times M}$,$\\mathbf{V}\_n^{\\{d\\}}=\\left(\\begin{array}{cc}\\mathbf{I}\_{P/2} & \\mathbf{O} \\\\\\mathbf{O} & \\mathbf{U}\_n^{\\{d\\}}\\end{array}\\right)\\in\\mathbb{R}^{P\\times P}, d\\in\\{1,2\\}$, $\\mathbf{W}\_0, \\mathbf{U}\_0,\\mathbf{U}\_n^{\\{d\\}}\\in\\mathbb{R}^{P/2\\times P/2}$は直交行列
%[text] - $\\mathbf{Q}(z)=\\mathbf{B}\_{P}\\left(\\begin{array}{cc} \\mathbf{I}\_{P/2} &  \\mathbf{O} \\\\ \\mathbf{O} &  z^{-1}\\mathbf{I}\_{P/2}\\end{array}\\right)\\mathbf{B}\_{P}$, $\\bar{\\mathbf{Q}}(z)=\\mathbf{B}\_{P}\\left(\\begin{array}{cc} z\\mathbf{I}\_{P/2} &  \\mathbf{O} \\\\ \\mathbf{O} &  \\mathbf{I}\_{P/2}\\end{array}\\right)\\mathbf{B}\_{P}$, $\\mathbf{B}\_{P}=\\frac{1}{\\sqrt{2}}\\left(\\begin{array}{cc} \\mathbf{I}\_{P/2} &  \\mathbf{I}\_{P/2} \\\\ \\mathbf{I}\_{P/2} &  -\\mathbf{I}\_{P/2}\\end{array}\\right)$ \
%[text] 【References】 
%[text] - [Overview of Filter Banks - MATLAB & Simulink - MathWorks 日本](https://jp.mathworks.com/help/dsp/ug/overview-of-filter-banks.html)
%[text] - MATLAB SaivDr Package: [https://github.com/msiplab/SaivDr](https://github.com/msiplab/SaivDr)
%[text] - S. Muramatsu, K. Furuya and N. Yuki, "Multidimensional Nonseparable Oversampled Lapped Transforms: Theory and Design," in IEEE Transactions on Signal Processing, vol. 65, no. 5, pp. 1251-1264, 1 March1, 2017, doi: 10.1109/TSP.2016.2633240.
%[text] - S. Muramatsu, T. Kobayashi, M. Hiki and H. Kikuchi, "Boundary Operation of 2-D Nonseparable Linear-Phase Paraunitary Filter Banks," in IEEE Transactions on Image Processing, vol. 21, no. 4, pp. 2314-2318, April 2012, doi: 10.1109/TIP.2011.2181527.
%[text] - S. Muramatsu, M. Ishii and Z. Chen, "Efficient parameter optimization for example-based design of nonseparable oversampled lapped transform," 2016 IEEE International Conference on Image Processing (ICIP), Phoenix, AZ, 2016, pp. 3618-3622, doi: 10.1109/ICIP.2016.7533034.
%[text] - Furuya, K., Hara, S., Seino, K., & Muramatsu, S. (2016). Boundary operation of 2D non-separable oversampled lapped transforms. *APSIPA Transactions on Signal and Information Processing, 5*, E9. doi:10.1017/ATSIP.2016.3. \
%[text] ### 2次元画像の階層的分析
%[text] $R\_M^P(\\tau)$ をツリーレベル $\\tau$の階層構造フィルタバンクの冗長度とすると、
%[text]  $R\_M^P(\\tau)=\\left\\{\\begin{array}{ll} (P-1)\\tau + 1, & M=1, \\\\ \\frac{P-1}{M-1}-\\frac{P-M}{(M-1)M^\\tau}, & M\\geq 2.\\end{array}\\right.$
%[text] となる．
%[text] #### 
%[text] #### 構成パラメータ設定
%{
% Decimation factor (Strides)
decFactor = [2 2]; % [μ1 μ2]

% Number of channels ( sum(nChannels) >= prod(decFactors) )
nChannels = [3 3];

% Number of tree levels
nLevels = 3; 

% Polyphase Order
ppOrder = [4 4]; 
%}

%{
% Decimation factor (Strides)
decFactor =  [4 4]; % [μ1 μ2]

% Number of channels ( sum(nChannels) >= prod(decFactors) )
nChannels = [13 13]; % [Ps Pa] (Ps=Pa)

% Number of tree levels
nLevels = 2; 

% Polyphase Order
ppOrder = [2 2];
%}

%%{
% Decimation factor (Strides)
decFactor =  [8 8]; % [μ1 μ2]

% Number of channels ( sum(nChannels) >= prod(decFactors) )
nChannels = [40 40]; % [Ps Pa] (Ps=Pa)

% Number of tree levels
nLevels = 1; 

% Polyphase Order
ppOrder = [4 4];
%%}

% Redundancy
P = sum(nChannels);
M = prod(decFactor);
redundancyNsolt = ... %[output:group:5cf244e5] %[output:540f4f62]
    (prod(decFactor)==1)*((P-1)*nLevels+1) + ... %[output:540f4f62]
    (prod(decFactor)>1)*((P-1)/(M-1)-(P-M)/((M-1)*M^nLevels)) %[output:group:5cf244e5] %[output:540f4f62]
assert(redundancyNsolt<=redundancyRatio)

%[text] $L\_1\\times L\_2=\\left(\\mu\_1^{\\tau}+\\zeta\_1\\frac{\\mu\_1(\\mu\_1^{\\tau}-1)}{\\mu\_1-1}\\right) \\times\\left(\\mu\_2^{\\tau}+\\zeta\_2\\frac{\\mu\_2(\\mu\_2^{\\tau}-1)}{\\mu\_2-1}\\right)$
% Filter size [ Ly Lx ]
maxDecFactor = decFactor.^nLevels;
szFilters = maxDecFactor + ppOrder.*decFactor.*(maxDecFactor-1)./(decFactor-1) %[output:6a8e6d7a]

% 訓練パッチサイズ
% [設定解説]
%   szPatchTrn = szOrg          → 画像全体を1サンプルとして使用（現在の設定）
%   szPatchTrn = floor(szOrg/2) → 画像の 1/4 面積のパッチを抽出（下記 nSubImgs と組み合わせる）
%   条件: szPatchTrn >= szFilters（フィルタサイズ以上）を満たす必要がある
szPatchTrn = szOrg %[output:6409629c]
assert(all(szPatchTrn>=szFilters))

% 1画像あたりの訓練サンプル数
% [複数パッチ・ランダムパッチ抽出の解説]
%   szPatchTrn = szOrg の場合: パッチ = 画像全体なので有効サンプル数は常に 1
%   szPatchTrn < szOrg に設定した場合: 下記 randomPatchExtractionDatastore が
%   1画像から nSubImgs 枚をランダム位置で抽出し、多様な訓練データを生成できる
%   （例: szPatchTrn=floor(szOrg/2), nSubImgs=8, miniBatchSize=4, maxEpochs=50）
nSubImgs = 1 %[output:86c4735c]
assert(nSubImgs > 0)

% No DC-leakage
noDcLeakage = true %[control:checkbox:5c50]{"position":[15,19]} %[output:654e79de]
%%
%[text] #### 辞書の設定
import saivdr.dcnn.*
% 既存の設計ファイルを検索（パターン: example09_03_learnedNsolt_*.mat）
nsoltFiles = dir(fullfile(datfolder, myfilename + "_learnedNsolt_*.mat"));
[~, sortIdx] = sort([nsoltFiles.datenum],'descend');
nsoltFiles = nsoltFiles(sortIdx);
hasExistingFile = ~isempty(nsoltFiles);

% --- 学習パラメータ（isForceDesign=true の新規設計時のみ使用）---
% 外側ループ繰返し数
nItersNsolt = 20;

% Standard deviation of initial angles (新規設計時の初期化のみ使用)
stdInitAng = 1e-1;

% Mini batch size（単一画像学習: nSubImgs=1 なので miniBatchSize=1 固定）
% [解説] szPatchTrn < szOrg のランダムパッチ抽出を使う場合は
%        miniBatchSize = 4〜8 程度に増やすと勾配推定が安定する
miniBatchSize = 1;

% Number of Epochs = gradient steps per outer iteration
% （サンプル数=1, バッチ=1 のため 1 epoch = 1 gradient step）
% ある程度収束済みの状態からの微調整のため，多めのステップ数で探索
maxEpochs = 200;

% Number of gradient steps per outer iteration
maxIters = nSubImgs/miniBatchSize * maxEpochs %[output:218a272a]

% Training options
opts = trainingOptions('adam', ...
    'InitialLearnRate',1e-03,...
    'GradientDecayFactor',0.9,...
    'SquaredGradientDecayFactor',0.999,...
    'Epsilon',1e-08,...
    'LearnRateSchedule','piecewise',...
    'LearnRateDropFactor',0.5,...
    'LearnRateDropPeriod',160,...
    'MaxEpochs',maxEpochs,...
    'MiniBatchSize',miniBatchSize,...
    'Verbose',1,...
    'Plots','none',...
    'ResetInputNormalization',0);

%[text] ### 訓練画像の準備
%[text] 画像全体（$96\\times 96$画素）を1つの訓練サンプル（$S=1$）として使用する．
%[text] PCAに合わせて予め零平均化したデータで学習する．
imds = imageDatastore(file_yorg,"ReadFcn",@(x) meansubtract(im2single(imresize(rgb2gray(imread(x)),szOrg))));
% [ランダムパッチ抽出の解説]
% randomPatchExtractionDatastore は画像からランダム位置のパッチを抽出するデータストア。
% szPatchTrn = szOrg の場合: 抽出位置が1点のみ → 全画像を1サンプルとして使用するため
%   PatchesPerImage = 1 とする（nSubImgs を指定しても同一パッチが複製されるだけ）。
% ランダムパッチ抽出を有効にする場合:
%   szPatchTrn = floor(szOrg/2) 等に縮小し PatchesPerImage を nSubImgs に変更する。
patchds = randomPatchExtractionDatastore(imds,imds,szPatchTrn,'PatchesPerImage',nSubImgs);

if ~isForceDesign && hasExistingFile %[output:group:53cd444f]
    latestNsoltFile = fullfile(datfolder, nsoltFiles(1).name);
    fprintf("既存の設計ファイルを読み込み: %s\n", nsoltFiles(1).name);
    S = load(latestNsoltFile);
    assert(nLevels == S.nLevels, "nLevels が一致しません（期待: %d, ファイル: %d）", nLevels, S.nLevels)
    analysisnet = S.analysisnet;
    synthesisnet = S.synthesisnet;
    synthesislgraph = layerGraph(synthesisnet);
    analysislgraph = layerGraph(analysisnet);
    nItersRun = 0;
else
%[text] #### 層構造の構築
    import saivdr.dcnn.*
    analysislgraph = fcn_creatensoltlgraph2d([],...
        'InputSize',szPatchTrn,...
        'NumberOfChannels',nChannels,...
        'DecimationFactor',decFactor,...
        'PolyPhaseOrder',ppOrder,...
        'NumberOfLevels',nLevels,...
        'NumberOfVanishingMoments',noDcLeakage,...
        'Mode','Analyzer');
    synthesislgraph = fcn_creatensoltlgraph2d([],...
        'InputSize',szPatchTrn,...
        'NumberOfChannels',nChannels,...
        'DecimationFactor',decFactor,...
        'PolyPhaseOrder',ppOrder,...
        'NumberOfLevels',nLevels,...
        'NumberOfVanishingMoments',noDcLeakage,...
        'Mode','Synthesizer');

    figure
    subplot(1,2,1)
    plot(analysislgraph)
    title('Analysis NSOLT')
    subplot(1,2,2)
    plot(synthesislgraph)
    title('Synthesis NSOLT')

    % Construction of deep learning network.
    synthesisnet = dlnetwork(synthesislgraph);

    % Initialize
    nLearnables = height(synthesisnet.Learnables);
    for iLearnable = 1:nLearnables
        if synthesisnet.Learnables.Parameter(iLearnable)=="Angles"
            synthesisnet.Learnables.Value(iLearnable) = ...
                cellfun(@(x) x+stdInitAng*randn(size(x)), ...
                synthesisnet.Learnables.Value(iLearnable),'UniformOutput',false);
        end
    end

    % Copy the synthesizer's parameters to the analyzer
    synthesislgraph = layerGraph(synthesisnet);
    analysislgraph = fcn_cpparamssyn2ana(analysislgraph,synthesislgraph); %[output:9f758270]
    analysisnet = dlnetwork(analysislgraph);
%[text] #### 随伴関係（完全再構成）の確認
%[text] NSOLTはパーセバルタイト性を満たす．
    nOutputs = nLevels+1;
    x = rand(szPatchTrn,'single');
    dlx = dlarray(x,'SSCB');
    tmpS = cell(1,nOutputs);
    [tmpS{1:nOutputs}] = analysisnet.predict(dlx);
    dly = synthesisnet.predict(tmpS{:});
    display("MSE: " + num2str(mse(dlx,dly)))
%[text] #### アトム画像の初期状態
    figure
    atomicImagesNsolt = getatomicimages(synthesisnet, szFilters, 2^(nLevels-1));
    nAtomsN = size(atomicImagesNsolt,4);
    scaleAtom = @(x) x / (max(abs(x(:))) + eps);
    tmpCells = arrayfun(@(i) scaleAtom(atomicImagesNsolt(:,:,:,i)), 1:nAtomsN, 'UniformOutput', false);
    dispImgsNsolt = imresize(cat(4, tmpCells{:}) * 0.5 + 0.5, 8, 'nearest');
    montage(dispImgsNsolt, ...
        'BorderSize',[2 2],'Size',[ceil(nAtomsN/8) 8], ...
        'BackgroundColor','white','ThumbnailSize',[20 20]);
    title('Atomic images of initial NSOLT')
    drawnow

    nItersRun = nItersNsolt; % 新規設計の繰返し数
end %[output:group:53cd444f]

%[text] ### 畳み込み辞書学習
%[text] #### 問題設定（$S=1$）:
%[text]  $\\{\\hat{\\mathbf{\\theta}},\\hat{\\mathbf{x}}\\}=\\arg\\min\_{\\{\\mathbf{\\theta},\\mathbf{x}\\}}\\frac{1}{2}\\|\\mathbf{y}-\\mathbf{D}\_{\\mathbf{\\theta}}\\hat{\\mathbf{x}}\\|\_2^2,\\ \\quad\\mathrm{s.t.}\\ \\|\\mathbf{x}\\|\_0\\leq K$
%[text] ただし， $\\mathbf{D}\_{\\mathbf{\\theta}}$は設計パラメータベクトル $\\mathbf{\\theta}$をもつ畳み込み辞書（$\\mathbf{y}$：訓練画像）．
%[text] 
%[text] #### アルゴリズム:
%[text] スパース近似ステップと辞書更新ステップを繰返す．
%[text] - スパース近似ステップ \
%[text]  $\\hat{\\mathbf{x}}=\\arg\\min\_{\\mathbf{x}}\\frac{1}{2} \\|\\mathbf{y}-\\hat{\\mathbf{D}}\\mathbf{x}\\|\_2^2\\ \\quad \\mathrm{s.t.}\\ \\|\\mathbf{x}\\|\_0\\leq K$
%[text] - 辞書更新ステップ \
%[text]  $\\hat{\\mathbf{\\theta}}=\\arg\\min\_{\\mathbf{\\theta}}\\frac{1}{2}\\|\\mathbf{y}-\\mathbf{D}\_{\\mathbf{\\theta}}\\hat{\\mathbf{x}}\\|\_2^2$
%[text]  $\\hat{\\mathbf{D}}=\\mathbf{D}\_{\\hat{\\mathbf{\\theta}}}$
%[text] #### 採用するスパース近似と辞書更新の手法:
%[text] - スパース近似：（正規化なし）繰返しハード閾値処理(IHT)
%[text] - 辞書更新：Adam オプティマイザ \
if nItersRun > 0
%[text] #### 辞書学習の繰返し計算
    import saivdr.dcnn.*
    for iIter = 1:nItersRun

        % Sparse approximation (Applied to produce an object of TransformedDatastore)
        coefimgds = transform(patchds, @(x) iht4patchds(x,analysisnet,synthesisnet,sparsityRatio));

        % Synthesis dictionary update
        trainlgraph = synthesislgraph.replaceLayer('Lv1_Out',...
            regressionLayer('Name','Lv1_Out'));
        trainednet = trainNetwork(coefimgds,trainlgraph,opts);

        % Analysis dictionary update (Copy parameters from synthesizer to analyzer)
        trainedlgraph = layerGraph(trainednet);
        analysislgraph = fcn_cpparamssyn2ana(analysislgraph,trainedlgraph);
        analysisnet = dlnetwork(analysislgraph);

        % Check the adjoint relation (perfect reconstruction)
        checkadjointrelation(analysislgraph,trainedlgraph,nLevels,szPatchTrn);

        % Replace layer
        synthesislgraph = trainedlgraph.replaceLayer('Lv1_Out',...
            nsoltIdentityLayer('Name','Lv1_Out'));
        synthesisnet = dlnetwork(synthesislgraph);

    end
%[text] #### 訓練ネットワークの保存
    import saivdr.dcnn.*
    synthesislgraph = layerGraph(synthesisnet);
    analysislgraph = fcn_cpparamssyn2ana(analysislgraph,synthesislgraph);
    analysisnet = dlnetwork(analysislgraph);
    save(fullfile(datfolder,sprintf("example09_03_learnedNsolt_%s",datetime('now','Format','yyyyMMddHHmmssSSS'))),'analysisnet','synthesisnet','nLevels')
end
%%
analysislgraph = layerGraph(analysisnet);
synthesislgraph = layerGraph(synthesisnet);

figure
subplot(1,2,1)
plot(analysislgraph)
title('Analysis NSOLT')
subplot(1,2,2)
plot(synthesislgraph)
title('Synthesis NSOLT')
%[text] #### アトム画像の表示
figure
atomicImagesNsolt = getatomicimages(synthesisnet, szFilters, 2^(nLevels-1));
nAtomsN = size(atomicImagesNsolt,4);
scaleAtom = @(x) x / (max(abs(x(:))) + eps);
tmpCells = arrayfun(@(i) scaleAtom(atomicImagesNsolt(:,:,:,i)), 1:nAtomsN, 'UniformOutput', false);
dispImgsNsolt = imresize(cat(4, tmpCells{:}) * 0.5 + 0.5, 8, 'nearest');
Insolt = montage(dispImgsNsolt, ...
    'BorderSize',[2 2],'Size',[ceil(nAtomsN/8) 8], ...
    'BackgroundColor','white','ThumbnailSize',[20 20]);
title('Atomic images of trained NSOLT')
drawnow
imwrite(Insolt.CData,fullfile(resfolder,"fig09-03a.png"))
%[text] ### 推論用NSOLTネットワークの構築

% Assemble analyzer
analysislgraph4predict = analysislgraph;
analysislgraph4predict = analysislgraph4predict.replaceLayer('Image input',...
    imageInputLayer(szOrg,'Name','Image imput','Normalization','none'));
for iLayer = 1:height(analysislgraph4predict.Layers)
    layer = analysislgraph4predict.Layers(iLayer);
    if contains(layer.Name,"Lv"+nLevels+"_DcOut") || ...
            ~isempty(regexp(layer.Name,'^Lv\d+_AcOut','once'))
        analysislgraph4predict = analysislgraph4predict.replaceLayer(layer.Name,...
            regressionLayer('Name',layer.Name));
    end
end
analysisnet4predict = assembleNetwork(analysislgraph4predict);

% Assemble synthesizer
synthesislgraph4predict = synthesislgraph;
synthesislgraph4predict = synthesislgraph4predict.replaceLayer('Lv1_Out',...
    regressionLayer('Name','Lv1_Out'));
for iLayer = 1:height(synthesislgraph4predict.Layers)
    layer = synthesislgraph4predict.Layers(iLayer);
    if contains(layer.Name,'Ac feature input')
        iLv = str2double(layer.Name(3));
        sbSize = szOrg.*(decFactor.^(-iLv));
        newlayer = ...
            imageInputLayer([sbSize (sum(nChannels)-1)],'Name',layer.Name,'Normalization','none');
        synthesislgraph4predict = synthesislgraph4predict.replaceLayer(...
            layer.Name,newlayer);
    elseif contains(layer.Name,sprintf('Lv%0d_Dc feature input',nLevels))
        iLv = str2double(layer.Name(3));
        sbSize = szOrg.*(decFactor.^(-iLv));
        newlayer = ...
            imageInputLayer([sbSize 1],'Name',layer.Name,'Normalization','none');
        synthesislgraph4predict = synthesislgraph4predict.replaceLayer(...
            layer.Name,newlayer);
    end
end
synthesisnet4predict = assembleNetwork(synthesislgraph4predict);  
%[text] #### 随伴関係（完全再構成）の確認
%[text] NSOLTはパーセバルタイト性を満たす．
u = rand(szOrg,'single');
s = cell(1,nLevels+1);
[s{1:nLevels+1}] = analysisnet4predict.predict(u);
v = synthesisnet4predict.predict(s{1:nLevels+1});
assert(mse(u,v)<1e-9)
%[text] #### NSOLTによる合成処理とその随伴処理の定義
nsoltconfig.nLevels = nLevels;
szCoefs = zeros(nLevels+1,3);
for iLevel = 1:nLevels+1
    s_iLevel = s{iLevel};
    szCoefs(iLevel,1) = size(s_iLevel,1);
    szCoefs(iLevel,2) = size(s_iLevel,2);
    szCoefs(iLevel,3) = size(s_iLevel,3);
end
nsoltconfig.szCoefs = szCoefs;
% useConvImpl: true → dlconv/dltranspconv（cuDNN最適化），false → dlnetwork
useConvImpl = true; %[control:checkbox:3437]{"position":[15,19]}
if useConvImpl
    import saivdr.dcnn.*
    % パーセバルタイトフレーム: 合成フィルタバンク W_syn を分析・合成で共用
    W_syn    = single(getatomicimages(synthesisnet, szFilters, 2^(nLevels-1)));
    padSz    = (szFilters - decFactor) / 2;  % 円周パディング/クロッピング量（= (40-8)/2 = 16）
    nChsConv = size(W_syn, 4);
    szSub    = [szCoefs(1,1), szCoefs(1,2), nChsConv];
    if canUseGPU(); W_syn = gpuArray(W_syn); end
    adj_nsolt = @(y) analysisnsolt_conv(y, W_syn, decFactor, padSz);
    syn_nsolt = @(x) synthesisnsolt_conv(x, W_syn, decFactor, padSz, szSub);
else
    adj_nsolt = @(y) analysisnsolt(y, analysisnet, nsoltconfig);
    syn_nsolt = @(x) synthesisnsolt(x, synthesisnet, nsoltconfig);
end
%[text] #### 随伴関係の確認
xchk = double(gather(adj_nsolt(single(y))));
vchk = randn(size(xchk));
uchk = double(gather(syn_nsolt(single(vchk))));
assert(abs(dot(double(y(:)),uchk(:))-dot(xchk(:),vchk(:)))<1e-2)
%%
%[text] ## ブロック辞書の定義
% Block DCT
syn_blkdct = @(x) blockproc(x,szBlk,@(block_struct) idct2(block_struct.data));
adj_blkdct = @(x) blockproc(x,szBlk,@(block_struct) dct2(block_struct.data));
% Block PCA / RICA / K-SVD (example09_02 の学習済み辞書を使用)
D09 = load(fullfile(datfolder,"example09_02_learnedDicts.mat"));
Phi_pca  = D09.Phi_pca;
Phi_rica = D09.Phi_rica;
Phi_ksvd = D09.Phi_ksvd;
syn_blkpca  = @(x) col2im(Phi_pca *x, szBlk, szOrg, "distinct");
adj_blkpca  = @(y) Phi_pca.' *im2col(y, szBlk, "distinct");
syn_blkrica = @(x) col2im(Phi_rica*x, szBlk, szOrg, "distinct");
adj_blkrica = @(y) Phi_rica.'*im2col(y, szBlk, "distinct");
syn_blkksvd = @(x) col2im(Phi_ksvd*x, szBlk, szOrg, "distinct");
adj_blkksvd = @(y) Phi_ksvd.'*im2col(y, szBlk, "distinct");
%%
%[text] ## 繰返しハード閾値処理(IHT)によるスパース近似の比較
%[text] #### 辞書の準備
% {syn, adj, name, isNorm_, useGpu_, isParsevalFrame_}
% isNorm_: タイトフレーム(DCT,PCA,NSOLT)は false、RICA・K-SVD は true
% useGpu_: NSOLT のみ GPU（blockproc/im2col は gpuArray 非対応）
% isParsevalFrame_: true のとき adj(y) を事前計算し反復内 adjproc_ を省略（adj(syn(x))=x を利用）
blkdct  = { syn_blkdct,  adj_blkdct,  "Block DCT",   false, false,       false };
blkpca  = { syn_blkpca,  adj_blkpca,  "Block PCA",   false, false,       false };
blkrica = { syn_blkrica, adj_blkrica, "Block RICA",  true,  false,       false };
blkksvd = { syn_blkksvd, adj_blkksvd, "Block K-SVD", true,  false,       false };
nsolt   = { syn_nsolt,   adj_nsolt,   "NSOLT",       false, canUseGPU(), false };
dicset  = { blkdct, blkpca, blkrica, blkksvd, nsolt };
nDics   = length(dicset);
%[text] #### IHT
%[text]  $\\mathbf{x}^{(t+1)}\\leftarrow \\mathcal{H}\_{BK}\\left(\\mathbf{x}^{(t)}+\\mu^{(t)}\\hat{\\mathbf{D}}^\\textsf{T}\\left(\\mathbf{y}-\\hat{\\mathbf{D}}\\mathbf{x}^{(t)}\\right)\\right)$
%[text]  $t\\leftarrow t+1$
%[text] -  T. Blumensath and M. E. Davies, "Normalized Iterative Hard Thresholding: Guaranteed Stability and Performance," in IEEE Journal of Selected Topics in Signal Processing, vol. 4, no. 2, pp. 298-309, April 2010, doi: 10.1109/JSTSP.2010.2042411. \
nItersIht = 500;

% 平均値を引いた画像を用意（近似後に平均値を加算）
ymean = mean(yorg,"all");
y = yorg - ymean;
% 準備
c = 1e-3;
kappa = 1.1/(1-c);
nCoefs = floor(sparsityRatio*prod(szOrg));
psnrs  = zeros(nItersIht,nDics);
ssims  = zeros(nItersIht,nDics);
yaprxs = cell(1,nDics);
for iDic = 1:nDics
    dic_              = dicset{iDic};
    synproc_          = dic_{1};
    adjproc_          = dic_{2};
    dicname_          = dic_{3};
    isNorm_           = dic_{4};
    useGpu_           = dic_{5};
    isParsevalFrame_  = dic_{6};

    % GPU/CPU 切り替え（blockproc/im2col 非対応のためNSOLTのみGPU）
    if useGpu_
        yiht = gpuArray(single(y));
    else
        yiht = y;
    end
    yiht_cpu = double(gather(yiht));  % PSNR/SSIM 用 CPU リファレンス

    % 初期化
    % isParsevalFrame_=true のとき adj(y) を事前計算（反復内 adjproc_ 呼び出しを排除）
    if isParsevalFrame_
        adj_y_ = adjproc_(yiht);  % adj(y) を1回だけ計算
        xt     = zeros(size(adj_y_),'like',adj_y_);
        s      = adj_y_;  % suppt 計算用（isNorm_=false の場合は不使用）
    else
        s  = adjproc_(yiht);
        xt = zeros(size(s),'like',s);
    end
    suppt = [];
    maskt = [];
    if isNorm_
        suppt = find(hardthresh(s,nCoefs)); % Γ1 = supp(H_K(D^Ty))
        maskt = zeros(size(s),'like',s);
        maskt(suppt) = 1;
    end
    % 合成結果キャッシュ（初期: synproc(0)=0 と等価）
    yaprx_ = zeros(size(yiht),'like',yiht);
    psnrs_col = zeros(nItersIht,1);
    ssims_col = zeros(nItersIht,1);
    fprintf("IHT 開始: %s\n", dicname_);
    for iIter = 1:nItersIht
        % 勾配計算
        % isParsevalFrame_=true: adj(y-syn(xt)) = adj_y - xt （Parseval性：adj(syn(xt))=xt）
        % → adjproc_ の反復内呼び出しがゼロになる
        if isParsevalFrame_
            gt = adj_y_ - xt;
        else
            gt = adjproc_(yiht - yaprx_);
        end
        if ~isNorm_ % 正規化なし
            mu   = (1-c);
            xtp1 = hardthresh(xt+mu*gt,nCoefs);
        else        % 正規化あり
            ggt  = gt(suppt);
            ugt  = synproc_(maskt.*gt);
            mu   = (ggt.'*ggt)/(ugt(:).'*ugt(:));
            ttp1 = hardthresh(xt+mu*gt,nCoefs);
            supptp1 = find(ttp1);
            if length(supptp1)==length(suppt) && all(supptp1==suppt)
                xtp1 = ttp1;
            else
                dxt   = ttp1-xt;
                omega = (1-c)*(norm(dxt,'fro')/norm(synproc_(dxt),'fro'))^2;
                if mu <= omega
                    xtp1 = ttp1;
                else
                    while mu > omega
                        mu    = mu/(kappa*(1-c));
                        ttp1  = hardthresh(xt+mu*gt,nCoefs);
                        dxt   = ttp1-xt;
                        omega = (1-c)*(norm(dxt,'fro')/norm(synproc_(dxt),'fro'))^2;
                    end
                    supptp1 = find(ttp1);
                    xtp1    = ttp1;
                end
            end
            suppt = supptp1;
            maskt = zeros(size(maskt),'like',maskt);
            maskt(suppt) = 1;
        end
        xt = xtp1;
        assert(nnz(xt)/prod(szOrg) <= sparsityRatio)
        yaprx_        = synproc_(xt);  % 1回だけ合成：次イタレーション勾配・監視で共用
        yaprx_cpu     = double(gather(yaprx_));
        psnrs_col(iIter) = psnr(yaprx_cpu, yiht_cpu);
        ssims_col(iIter) = ssim(yaprx_cpu, yiht_cpu);
    end
    psnrs(:,iDic)  = psnrs_col;
    ssims(:,iDic)  = ssims_col;
    yaprxs{iDic}   = double(gather(yaprx_)) + ymean;
    fprintf("IHT 終了: %s  最終 PSNR = %.2f dB\n", dicname_, psnrs_col(end));
end
%%
%[text] ## 近似結果の表示
dicnames = [blkdct{3},blkpca{3},blkrica{3},blkksvd{3},nsolt{3}];
psnrtbl = array2table(psnrs,'VariableNames',dicnames);
psnrtbl = horzcat(table((1:nItersIht).','VariableNames',"Iterations"),psnrtbl);
ssimtbl = array2table(ssims,'VariableNames',dicnames);
ssimtbl = horzcat(table((1:nItersIht).','VariableNames',"Iterations"),ssimtbl);

% PSNR・SSIM データを保存
save(fullfile(datfolder,"example09_03_psnrssim.mat"),'psnrs','ssims','dicnames','nItersIht')

% 線スタイル設定（モノクロ印刷対応：全線黒・線種・マーカーで区別）
lineStyles = {'-',  '--', ':',  '-.',  '-' };
markers    = {'none','none','o', 's',  'd' };
markerStep = max(1, floor(nItersIht/10));
fontSize   = 14;

% PSNR のグラフ
figure
hold on
for iDic = 1:nDics
    plot(1:nItersIht, psnrs(:,iDic), lineStyles{iDic}, ...
        'Color', 'k', ...
        'LineWidth', 2, 'Marker', markers{iDic}, 'MarkerSize', 6, ...
        'MarkerIndices', 1:markerStep:nItersIht, ...
        'DisplayName', dicnames(iDic))
end
hold off
xlabel('Iterations', 'FontSize', fontSize)
ylabel('PSNR [dB]', 'FontSize', fontSize)
legend('Location','southeast', 'FontSize', fontSize-2)
grid on
set(gca, 'FontSize', fontSize)
xlim([0 nItersIht]) % 軸範囲を反復回数に固定（自動設定だと600まで伸びるため）
ylim([14 34])       % 目盛と凡例配置を安定させるため縦軸も固定
set(gcf, 'PaperUnits', 'inches', 'PaperSize', [8.26 5.16], 'PaperPosition', [0 0 8.26 5.16])
print(gcf, fullfile(resfolder,"fig09-03b.png"), '-dpng', '-r96')

% SSIM のグラフ
figure
hold on
for iDic = 1:nDics
    plot(1:nItersIht, ssims(:,iDic), lineStyles{iDic}, ...
        'Color', 'k', ...
        'LineWidth', 2, 'Marker', markers{iDic}, 'MarkerSize', 6, ...
        'MarkerIndices', 1:markerStep:nItersIht, ...
        'DisplayName', dicnames(iDic))
end
hold off
xlabel('Iterations', 'FontSize', fontSize)
ylabel('SSIM', 'FontSize', fontSize)
legend('Location','southeast', 'FontSize', fontSize-2)
grid on
set(gca, 'FontSize', fontSize)


%%
% 原画像の表示
figure
tiledlayout(2,ceil((nDics+1)/2))
nexttile
imshow(yorg)
title("Original image")
% 近似画像の表示
for idx = 1:nDics
    yaprx = yaprxs{idx};
    dicname = dicnames(idx)
    file_yaprx = fullfile(resfolder,"yaprx_" + replace(lower(dicname),' ','_') +".png");
    imwrite(yaprx,file_yaprx)
    %
    nexttile
    imshow(yaprxs{idx})
    title(dicname+" "+num2str(psnrs(end,idx))+" dB")
end

% 原画像と近似画像を fig09-04a.png 〜 fig09-04f.png として保存
imwrite(yorg, fullfile(resfolder, "fig09-04a.png"))
for idx = 1:nDics
    suffix = char('a' + idx);
    imwrite(yaprxs{idx}, fullfile(resfolder, "fig09-04" + suffix + ".png"))
end

%%
%[text] ## 【関数定義】
%[text] #### NSOLT合成処理関数
function y = synthesisnsolt(x,synthesisnet,config)
nLevels = config.nLevels;
szCoefs = config.szCoefs;
s = cell(1,nLevels+1);
sidx = 1;
for iLevel = 1:nLevels+1
    sz_iLevel = szCoefs(iLevel,:);
    eidx = sidx+prod(sz_iLevel)-1;
    x_iLevel = x(sidx:eidx);
    s{iLevel} = reshape(x_iLevel,sz_iLevel);
    sidx = eidx+1;
end
y = synthesisnet.predict(s{1:nLevels+1});
end

%[text] #### NSOLT分析処理関数
function x = analysisnsolt(y,analysisnet,config)
nLevels = config.nLevels;
szCoefs = config.szCoefs;
[s{1:nLevels+1}] = analysisnet.predict(y);
nCoefs = sum(prod(szCoefs,2),1);
%x = [];
x = zeros(nCoefs,1,'like',s{1});  % GPU 入力時は GPU 配列を維持
sidx = 1;
for iLevel = 1:nLevels+1
    %x = [x; s{iLevel}(:)];
    eidx = sidx - 1 + prod(szCoefs(iLevel,:));
    x(sidx:eidx) = s{iLevel}(:);
    sidx = eidx + 1;
end
end
%[text] #### ハード閾値処理
function y = hardthresh(x,K)
v = sort(abs(x(:)),'descend');
thk = v(K);
y = (abs(x)>thk).*x;
end
%[text] #### 深層学習配列に対する繰返しハード閾値処理(IHT)のバッチ処理
function newdata = iht4patchds(oldtbl,analyzer,synthesizer,sparsityRatio)
% IHT for InputImage in randomPatchExtractionDatastore
%
nInputs = length(synthesizer.InputNames);

% Apply IHT process for every input patch
restbl = removevars(oldtbl,'InputImage');
dlv = dlarray(cat(4,oldtbl.InputImage{:}),'SSCB');
[~,dlcoefs{1:nInputs}] = iht4dlarray(dlv,analyzer,synthesizer,sparsityRatio);
coefs = cellfun(@(x) permute(num2cell(extractdata(x),1:3),[4 1 2 3]),dlcoefs,'UniformOutput',false);
%
nImgs = length(oldtbl.InputImage);
coefarray = cell(nImgs,nInputs);
for iImg = 1:nImgs
    for iInput = 1:nInputs
        coefarray{iImg,iInput} = coefs{iInput}{iImg};
    end
end
% Output as a cell in order to make multiple-input datastore
newdata = [ coefarray table2cell(restbl) ];
end
%[text] #### 深層学習配列に対する繰返しハード閾値処理(IHT)
function [dly,varargout] = iht4dlarray(dlx,analyzer,synthesizer,sparsityRatio)
% IHT Iterative hard thresholding
%
nInputs = length(synthesizer.InputNames);
szBatch = size(dlx,4);

% Iterative hard thresholding w/o normalization
% (A Parseval tight frame is assumed)
gamma = (1.-1e-3);
nIters = 30;
nCoefs = floor(sparsityRatio*numel(dlx(:,:,:,1)));
[dlcoefs{1:nInputs}] = analyzer.predict(dlarray(zeros(size(dlx),'like',dlx),'SSCB'));
% IHT
for iter=1:nIters
    % Gradient descent
    dly = synthesizer.predict(dlcoefs{1:nInputs});
    [grad{1:nInputs}] = analyzer.predict(dlx-dly);
    dlcoefs = cellfun(@(x,y) x+gamma*y,dlcoefs,grad,'UniformOutput',false);
    % Hard thresholding
    coefvecs = cellfun(@(x) extractdata(reshape(x,[],szBatch)),dlcoefs,'UniformOutput',false);
    srtdabscoefs = sort(abs(cell2mat(coefvecs.')),1,'descend');
    thk = reshape(srtdabscoefs(nCoefs,:),1,1,1,szBatch);
    dlcoefs = cellfun(@(x) (abs(x)>thk).*x,dlcoefs,'UniformOutput',false);
    % Monitoring
    %checkSparsity =...
    %nnz(srtdabscoefs>srtdabscoefs(nCoefs,:))/numel(dlx)<=sparsityRatio;
    %assert(checkSparsity)
    %fprintf("IHT(%d) MSE: %6.4f\n",iter,mse(dlx,dly));
end
varargout = dlcoefs;
end
%[text] #### NSOLTネットワークの随伴関係の確認
function checkadjointrelation(analysislgraph,synthesislgraph,nLevels,szInput)
import saivdr.dcnn.*
x = rand(szInput,'single');
% Assemble analyzer
analysislgraph4predict = analysislgraph;
for iLayer = 1:length(analysislgraph4predict.Layers)
    layer = analysislgraph4predict.Layers(iLayer);
    if contains(layer.Name,"Lv"+nLevels+"_DcOut") || ...
            ~isempty(regexp(layer.Name,'^Lv\d+_AcOut','once'))
        analysislgraph4predict = analysislgraph4predict.replaceLayer(layer.Name,...
            regressionLayer('Name',layer.Name));
    end
end
analysisnet4predict = assembleNetwork(analysislgraph4predict);

% Assemble synthesizer
synthesislgraph4predict = synthesislgraph;
synthesisnet4predict = assembleNetwork(synthesislgraph4predict);

% Analysis and synthesis process
[s{1:nLevels+1}] = analysisnet4predict.predict(x);
if isvector(s{end-1})
    s{end-1} = permute(s{end-1},[1,3,2]);
end
y = synthesisnet4predict.predict(s{:});

% Evaluation
display("MSE: " + num2str(mse(x,y)))
end
%[text] #### NSOLTネットワークからのツリーレベル情報の抽出
function nLevels = extractnumlevels(nsoltnet)
import saivdr.dcnn.*

% Extraction of information
expidctlayer = '^Lv\d+_E0~?$';
nLevels = 0;
nLayers = height(nsoltnet.Layers);
for iLayer = 1:nLayers
    layer = nsoltnet.Layers(iLayer);
    if ~isempty(regexp(layer.Name,expidctlayer,'once'))
        nLevels = nLevels + 1;
    end
end
end
%[text] #### NSOLTネットワークからのストライド情報の抽出
function decFactor = extractdecfactor(nsoltnet)
import saivdr.dcnn.*

% Extraction of information
expfinallayer = '^Lv1_Cmp1+_V0~?$';
nLayers = height(nsoltnet.Layers);
for iLayer = 1:nLayers
    layer = nsoltnet.Layers(iLayer);
    if ~isempty(regexp(layer.Name,expfinallayer,'once'))
        decFactor = layer.DecimationFactor;
    end
end
end
%[text] #### NSOLTネットワークからのチャネル数情報の抽出
function nChannels = extractnumchannels(nsoltnet)
import saivdr.dcnn.*

% Extraction of information
expfinallayer = '^Lv1_Cmp1+_V0~?$';
nLayers = height(nsoltnet.Layers);
for iLayer = 1:nLayers
    layer = nsoltnet.Layers(iLayer);
    if ~isempty(regexp(layer.Name,expfinallayer,'once'))
        nChannels = layer.NumberOfChannels;
    end
end
end
%[text] #### NSOLTネットワークのアトム画像抽出
function [atomicImages, mRows, mCols] = getatomicimages(synthesisnet, patchsize, scale)
%GETATOMICIMAGES Compute atomic images from NSOLT synthesis network
import saivdr.dcnn.*
if nargin < 3 || isempty(scale)
    scale = 1;
end
expfinallayer = '^Lv1_Cmp1+_V0~?$';
expidctlayer = '^Lv\d+_E0~?$';
nLayers = height(synthesisnet.Layers);
nLevels = 0;
nComponents = 1;
for iLayer = 1:nLayers
    layer = synthesisnet.Layers(iLayer);
    if ~isempty(regexp(layer.Name,expfinallayer,'once'))
        nChannels = layer.NumberOfChannels;
        decFactor = layer.DecimationFactor;
    end
    if ~isempty(regexp(layer.Name,expidctlayer,'once'))
        nLevels = nLevels + 1;
        if nLevels == 1
            nComponents = layer.NumInputs;
        end
    end
end
nChsPerLv = sum(nChannels);
nChsTotal = nLevels*(nChsPerLv-1)+1;
DIMENSION = 2;
MARGIN = 2;
if nargin < 2 || isempty(patchsize)
    estPpOrder = floor([1 1]*sqrt(nLayers/(DIMENSION*nLevels)));
    estKernelExt = decFactor.*(estPpOrder+1);
    for iLv = 2:nLevels
        estKernelExt = (estKernelExt-1).*(decFactor+1)+1;
    end
    maxDecFactor = decFactor.^nLevels;
    patchsize = (ceil(estKernelExt./maxDecFactor)+MARGIN).*maxDecFactor;
end
atomicImages = zeros([patchsize 1 nChsTotal],'single');
dls = cell(nLevels+1,1);
for iRevLv = nLevels:-1:1
    if iRevLv == nLevels
        dls{nLevels+1} = dlarray(zeros([patchsize./(decFactor.^nLevels) nComponents],'single'),'SSC');
        dls{nLevels} = dlarray(zeros([patchsize./(decFactor.^nLevels) nComponents*(nChsPerLv-1)],'single'),'SSC');
    else
        dls{iRevLv} = dlarray(zeros([patchsize./(decFactor.^iRevLv) nComponents*(nChsPerLv-1)],'single'),'SSC');
    end
end
idx = 1;
dld = dls;
dld{nLevels+1}(round(end/2),round(end/2),1:nComponents) = ones(1,1,nComponents);
atomicImages(:,:,1:nComponents,idx) = extractdata(synthesisnet.predict(dld{:}));
idx = idx+1;
for iRevLv = nLevels:-1:1
    for iAtom = 1:nChsPerLv-1
        dld = dls;
        for iCmp = 1:nComponents
            dld{iRevLv}(round(end/2),round(end/2),(iCmp-1)*(nChsPerLv-1)+iAtom) = 1;
        end
        atomicImages(:,:,1:nComponents,idx) = extractdata(synthesisnet.predict(dld{:}));
        idx = idx+1;
    end
end
atomicImages = scale * atomicImages;
mRows = 2^(nextpow2(sqrt(nChsTotal))-1);
mCols = ceil(nChsTotal/mRows);
end
function y = synthesisnsolt_conv(x, W_syn, decFactor, padSz, szSub)
% NSOLT合成（転置畳み込み + 周期折り返し）
% x: [nCoefs 1]（gpuArray single 可）  W_syn: [szF_H szF_W 1 P]
x = cast(x,'like',W_syn);
x_3d  = reshape(x, szSub);
x_dl  = dlarray(x_3d, 'SSC');
bias_s = zeros(1,'like',W_syn);
y_full_dl = dltranspconv(x_dl, W_syn, bias_s, 'Stride', decFactor, 'Cropping', 0);
y_full = extractdata(y_full_dl);         % [H_full W_full 1]
% 周期折り返し（NSOLT の周期境界条件を再現）
p_H = padSz(1); p_W = padSz(2);
N_H = (szSub(1)-1)*decFactor(1) + size(W_syn,1) - 2*p_H;
N_W = (szSub(2)-1)*decFactor(2) + size(W_syn,2) - 2*p_W;
y   = y_full(p_H+1:p_H+N_H, p_W+1:p_W+N_W, 1);
y(end-p_H+1:end,:) = y(end-p_H+1:end,:) + y_full(1:p_H, p_W+1:p_W+N_W, 1);
y(1:p_H,:)         = y(1:p_H,:)         + y_full(p_H+N_H+1:end, p_W+1:p_W+N_W, 1);
y(:,end-p_W+1:end) = y(:,end-p_W+1:end) + y_full(p_H+1:p_H+N_H, 1:p_W, 1);
y(:,1:p_W)         = y(:,1:p_W)         + y_full(p_H+1:p_H+N_H, p_W+N_W+1:end, 1);
y(end-p_H+1:end,end-p_W+1:end) = y(end-p_H+1:end,end-p_W+1:end) + y_full(1:p_H, 1:p_W, 1);
y(end-p_H+1:end,1:p_W)         = y(end-p_H+1:end,1:p_W)         + y_full(1:p_H, p_W+N_W+1:end, 1);
y(1:p_H,end-p_W+1:end)         = y(1:p_H,end-p_W+1:end)         + y_full(p_H+N_H+1:end, 1:p_W, 1);
y(1:p_H,1:p_W)                 = y(1:p_H,1:p_W)                 + y_full(p_H+N_H+1:end, p_W+N_W+1:end, 1);
end

function x = analysisnsolt_conv(y, W_syn, decFactor, padSz)
% NSOLT分析（周期拡張 + dlconv）
% y: [H W] または [H W 1]（gpuArray 可）  W_syn: [szF_H szF_W 1 P]
y = cast(y,'like',W_syn);
if ismatrix(y); y = reshape(y,[size(y,1) size(y,2) 1]); end
p_H = padSz(1); p_W = padSz(2);
y_pad = padarray(y, [p_H p_W 0], 'circular', 'both');  % 周期拡張
y_dl  = dlarray(y_pad, 'SSC');
bias_a = zeros(size(W_syn,4),1,'like',W_syn);
x_dl  = dlconv(y_dl, W_syn, bias_a, 'Stride', decFactor, 'Padding', 0);
x     = extractdata(x_dl);
x     = x(:);
end

%[text] © Copyright, 2023-2026, Shogo MURAMATSU, All rights reserved.

%[appendix]{"version":"1.0"}
%---
%[metadata:view]
%   data: {"layout":"onright","rightPanelPercent":46.8}
%---
%[control:checkbox:48c8]
%   data: {"defaultValue":false,"label":"isForceDesign","run":"Section"}
%---
%[control:checkbox:53ff]
%   data: {"defaultValue":false,"label":"isCodegen","run":"Section"}
%---
%[control:checkbox:5c50]
%   data: {"defaultValue":true,"label":"noDcLeakage","run":"Section"}
%---
%[control:checkbox:3437]
%   data: {"defaultValue":true,"label":"useConvImpl","run":"Section"}
%---
%[output:5ecaaadf]
%   data: {"dataType":"image","outputData":{"dataUri":"data:image\/png;base64,iVBORw0KGgoAAAANSUhEUgAAAW0AAADcCAYAAAC74PBGAAAQAElEQVR4AezdB5AlVdnG8fPuZ8CMOSsYMWfFCAaCGREVs5ZZMeeAJVpWKVqCaIkSSkQkqChJopKUIChGxIRgQsyYs37zO5feZcEd1g2zt+88U3Omu0+f8J6np\/7nvW+f7rvkP\/mJAlEgCkSB0SiwpOUnCkSBKBAFRqNAoD2aSxVDo8AiUSDDnFeBQHteeXIyCkSBKDBdCgTa03U9Yk0UiAJRYF4FAu155Vl7J9\/\/\/ve38847r\/30pz9tD3nIQ9o\/\/\/nPtddZWp4yBWJOFFh1BQLtFWh3xzvesW277bZLE7De7W53W3rs3N57791+\/\/vfL5cn\/8EPfnC73\/3ud4n8L3\/5y7233\/3ud23fffdtV7va1dorX\/nKdpWrXKU95SlPafe6173arrvu2svkTxSIAlHgvymw5L9lJq+1q1\/96m3\/\/fdfmrbaaqv2jGc8Y+mxc0972tPaVa961eXy5D\/nOc9pj33sYy+RD\/q0PfDAA9vDH\/7w9uxnP7t961vfape\/\/OVltwsuuKAdf\/zxHfYmhJ6ZP1EgCkSBiygQaF9EjIvv\/vGPf2y3ve1tO0S\/8IUvtJNOOqnvb7755u3Nb37z0uJPf\/rT2znnnNPP8bT33HPP9ulPf7of87gV3GSTTWzab3\/72+5Nb7DBBm2jjTZqz3zmMzvc1eN1H3DAAR3mP\/7xj3v5kf6J2VEgCqwlBQLtFQj7f\/\/3fys4M382T\/tlL3tZD3fYv\/a1r71chVe\/+tXtRje6UbvMZS7T7nnPezZeN2CLce+zzz4d9O9+97uXq5ODKBAFosCgQKA9KLGCLY8YfC+aXv7yl6+gdOvQ3XnnndsA4F\/+8pfLlX3gAx\/YNttss563xRZbtLe+9a3tL3\/5S49nP\/rRj26gfuihh7bBM+8F8ycKRIEocKECgfaFQlx040ahWLW8c889t4OYNzyknXbaqTn33xK4z+dpP\/nJT15a7cUvfnE79dRTe6jlmGOOabe85S3bXnvt1V7wghc0oZmlBbMTBaJAFLhQgUD7QiEuujn\/\/PPbda5znXblK1+5hy9e+9rXtje96U3tGte4RvvIRz7SXvWqV3UP+aJ1hn1gn8\/THsrZ8qqvda1r9TZ32GGH9sUvfrGdffbZDfS33HJLRZKiQBSIAsspEGgvJ8fk4Ctf+Uq79a1v3cB7u+22a1e60pUmJ+b+\/vvf\/26f+tSn2vve9765o+V\/edkSr\/nEE0\/sNxjdwFy+1LKjz33uc+1mN7tZcyNzv\/32a\/oFcm0sK5W9KBAFosAyBVYM7WVlFt3eAFNL+njVt7rVrZZqcIUrXKG9973vbd\/4xjfaxz72saX5r3jFKy4RRtn2Iuu8L7jggqVlhx0rS8SvLe\/bfvvtm5ufYt5XvOIV2+te97qhWLZRIApEgaUKBNpLpZjs8KT\/\/ve\/t0033bS95S1vaQ996EP7FkRvfvObNz\/WVb\/nPe9pHsBxLDnmIa8orb\/++ootTf\/5z3\/aQQcd1F7ykpc0E8Hzn\/\/8tvXWW\/fzb3jDG9oTnvCEvp8\/USAKRIGLKhBoX1SNuf0lS5b0GLOHa+5zn\/vM5bQG3ocddlh\/erFnzP0R777DHe4wt9d6+Q033LDvr+jPCSecsPTUC1\/4wu6Vi5WbCN7xjnc03r0120Ohu9zlLsNutlEgCkwUyN85BQLtORHyGwWiQBQYiwKB9liuVOyMAlEgCswpEGjPiZDfKDAtCsSOKHBpCswMtM8444y+ZM6yua997Wvt+9\/\/fvvOd77TX8j07W9\/u5155pmXSF7WdNZZZ7UhKSep993vfrddPH3ve99rq5ou3pY+9CXpn33HH398s4pkhx12aHvttVf7+Mc\/3r761a92O6xUsWrFDcttttmmx8B322239pjHPKZZ5XLaaae1N77xjc1qlCc+8Yl9rfc97nGP9qhHPard4ha3uLT\/g5yPAlFgJArMDLSrqkvuRmJVtb\/+9a\/tH\/\/4R7NKw4qQfvLCP1XVqibpwqylx1Urzh\/KDtuqSdmq+bfKV12yzGBrVfVH2X\/zm9\/0N\/5tOHdT07I\/D9787Gc\/a3\/+85+bJYPOe+T9T3\/6U3+S0hLBjTfeuN3whjfsE486Xv\/685\/\/vN3gBjfQbZ+8aNAP8icKRIHRKzAz0AZAELOVqqpd7nKX6y9mqpoAU75UNTmummwvnueqVk3OVS2\/VXZIVcufq\/rvx\/+tvLyqarYem\/\/FL37RfvWrX3VoW3J4k5vcpJ1yyik9OWfiAeK\/\/e1v\/WlN7\/e+6U1v2oDcAzq24AzuHgxSzvu6AX6qHolv+YkCUWB1FFiyOpWnqW5VdXOqJlsA42n7Rhj7VZN8hapqOc96yBu2Vcufr1p2rIxUVTb\/U6qqpf2qWDU5\/sMf\/tC96dvf\/vZ97bfH5X\/wgx80bwisqv6JQZkLLrigP0p\/u9vdrq233nr9bYHKGCeA\/+QnP2mSvKpqlg16mtPkpb+kKBAFxq\/AzECbxypVVX+ycNi3laqqe7X2h1S1LK9qAscf\/vCHDTC919qj6lXLyqh30QnA8f+aqpa1V1Xdu+ZZ87J99ZjQBu\/YsTcEOud9J8I9173udfsj9V5i5ZWuRxxxRI\/Zn3766e3oo49uoG\/t+PWvf\/3+KcMnj8te9rL5KrOWnygwOwrMDLSrqkO5qpqfAaZVtdS7rZrsOy9Vlc3S84DpRqabg8ONw6pJmV5w7o93iQhbeBimqpbWrRr2l23nil\/it6p6XlX1urxk7zjxVkGvgZXEph3\/61\/\/6l+a8IAHPKBJPGahFF63JywB3YutPGYvPHLUUUc1YRHjsBX\/Nsl4EKh3mj9RIAqMXoGZgnbVBIRV1S9MVXUwVk22Mqsm+1XLb50DPslKDMDk2cqXqqrf1ARGXrjH1cWZq5Zvp2pyPNSpmhxXLds6JwHqjW984\/42wcEj5uW7+QjcwiG+OYcHzZM2mXiEHtDdcPRSKjcpedRCIerw1nnqvrvSqhRPXHpMXn9JUSAKjF+BmYV21fKQrFp2XLX8vsso\/GB5Ha8X8LxXxM3Az372s31lBu9WGR68sIVj5cXMqy7ZXtXyeVWlm56qaulkwnMWd\/ZtNrxu7WrT15KJbeuTTSYI9ni8HuzFtK0a8YnAV5OxyY1Hkw14f\/Ob3+xxby+l8i05veP8iQJRYPQKrAq0p3LQYFq1DIaOh8QTtT9s7Uve1Lf77ru3HXfcsb8\/BNyqqglRXPOa12znnHNOXw\/94Q9\/uEkf\/ehHGyj6sgI3A71PxMqMqmX9VlUP02h\/SFWT88OxLRgDK8+eZ827B+aq6rFpX0X2oAc9qMMdwIVBfv3rX\/e3C5os1GHLve997x4S4YFf73rXa25Iyr\/73e\/ebnOb27STTz65L39s+YkCUWAmFJgZaLsaVRM4Dvsr2lZNygkl8E7FioFUOEFI4rzzzmvCIG74gaMQhHMerOHhgqsQhHqgWDVpr2r5rf6lqmX5jiUgFnMGY5PJVa5ylaZNa7O1b0IQmzaRCG9stNFGTez6Tne6UxPL5o3zytnNE+exa1d57Yhj88jZbt+5pCgQBcavwExB2+WoWgbIqpK1NFVNjsEM2ED585\/\/fANv4QUeKmBWVQNBwBMqcd5aaQBXFygB075vmnFcVd0rrlq2vXg+Q6om5+0DtTIA7saipXrWYusbfPU9eP3KiHezA9hNNlaJWOKnDnucExsf2tK2Twza0V9SFJhZBRbRwGYG2lUTGFZVD09UTY6BS6qaHFdVfyxcLBi4AVLYwWPljsWJgY5Hu8kmmzRfSuBBFjFnkOTlConYWkniK8J22WWXHvcGR31dNPGih2P7QzJBaEeow0oPHj5bPIIPzqCs3o9+9KPmpqPH3H0CaHM\/+gF4D9VU1dK12wDvnE8A7LJ8kRcO4nPV8hsFosAMKDAz0B6uRdUyOFdVz66q7gU7qKoGvuLJQC0WzKsVDwZsMAZx7+2w5tl5cWdboBVq8MShcwOAedvet+39J\/oA26pJn1W13CRSNckX8hhuKgqRVFXjyetHGIQXzx7l5PkEoH9QBnsetnqgDNBs9i4Vx0I54M8jN9mo1\/ITBaLATCgwM9C+KCiHK1M1AaTj4447rr3+9a9vb3vb29rBBx\/c3\/UBzPe6173ane985x4v9uIlKzasxrAOm4cL7B50AUXw5hGDtHiz5XRCHOuvv34TluCdA7n+qiZ9V0227BtS1cQ7NnmIa4OtUI12ABts3VAUQ+c1g7utshKYC9l4+Ed5Ew07wV1Ix01NY3PD1I1KWzYljVmB2B4FJgrMDLQNp6pslnrV\/WDuD69VKAP4eKKgy3PlhQLgXe9617blllv2ddigV1V95Yibjo6FLeaa6aBX3zGAC1dUVe9PiOPrX\/96E1uumuRVTbbqXjxpG8SVt8qDHcIzlv9ZWWKSAGFespuO8nwiMBbjsPzPRME7V0\/\/+mCD8Vg9wk5ltOlcUhSIAuNXYKag7XJUlU0Had+Z++MGnRuNQgsgDHI8ZuuZxYaH0Aggy\/fwymabbdbflCcUwlMVigBNcOTtapOHywvXniSGrH5VLdd\/1eS4quasaf1cVfWnHb1Clrcshs3LB1rhD\/0BtATcoC6G7SvQwFwZoRM28fbBmfdvrbdYPLCz1aTA2275iQJRYCYUmBloV1WH4cWvCrB+6Utf6m\/7sw92YAawgMbrlkBdiEHMevPNN29CErxx5UFR6EMoRdgC1PUD3rxgSdsAbls1sYUnXTXZrypVuo1V1bcmEP2ZLHjt6gIyiAOyfXkquiFq3balf+xgQ1X1F0Txwk0WAA\/iwizsBntj5clrY8pTzIsCUWAlFJg5aFdVv\/EHeGAqli3UAGhADL48bCtEeLnAa99Ll0B66623bve97337QyxCDx4zB0UP2oh1gyXP3KPlltqBKw\/XjUExcI+aV02gXLX8FsSH1OZ+AHmLLbZoVoiAt8mhqvqXN5hEhDW0y05fjPDOd76z7bvvvv2BGbbxpk0iIM4WnwgA32Tgk4A4uZujljXOdZffKBAFZkCBmYG2a1FV\/Q1\/YMfb5Pm6mQd6PE9rnYFMmMTNPiEN7xcBc2AHYx6rsgDN++UFy1NHCEMbQA+MAO5movrALg\/Aq6q\/F9vEUbU8uKuq+TFBmFQAm3csT\/9i3c4Jc5hw9M8Ox\/pmh\/PCOiaU4Zy6JibhHHke+vFuEu3rR\/tJUSAKjF+BJeMfwmQEYCcBILjKtbZZrJfX6qajc6AGcL6Ca4MNNuiPjPNahUs81q4OsFsFAnZgbgvIPOOq6hMDrxi8ART4taddTzKqq1\/9VVUPhbTW2pCqJi+fEr4Ae+V4zRIPGZzZYsKxZpsNgGwMPhXwyvUr\/q1N5SWwduyVrZY0mlTckGSn\/KQoEAXGr8DMQBsw3bwDTO8Sec1rXtO\/L9GaZXFdYQbwBkP7oAtuPFJA5MECJoCDKc9WvarqK0IAG7gBHRytHgFNXrl95auqgSpwDyAGbzYNYZGqBnT7rgAAEABJREFUCcS1wx5JuEZ5YQzf+7jnnnv2MAjgCp884hGPaPa1bULSnk8JvPBhogJ\/k4dx+JTgX1MM\/P73v3\/\/EgXHSVEgCoxfgZmBNojxPo888sj+hQCWvgEwKAIrIAMb0ConvMCzFQPmSUvCIG5Geqc2GCqvnjZ4sjzequrvCHFOHJk3q66tYxMAQAuTgCogi3sDrX+Xqgm0hS1MCmwwgZgohDPcFAVebZqItCtVVffw9SuZJNQHe23bquNcm\/uxEgXkhWiUncvKbxSIAjOgwJqF9joURAgACHmpVoXwukELFEEPpIUVgFC8m+f8nOc8p2244Yb95VDgDMoeWvFgDVCDOMjbapvXzstWVh8mBvmgCJagCb577LFHf\/x9u+226zdFBxvEvk0G6ppk2Ky8GDzwAqzlebxrD\/oAPtvZog5P3zFv2+RgMjAO\/eqfbcpZw+1Yu2yzVHAdXpp0HQWiwBpUYGagDU5CDkDn4RLQBmqetGVyYs5WV\/CGxbLBEkB5t8IJvGNtOO+1qG7y+QIC3izP3HlgpT24CnvYB8nBqwZ3gNa2rRuhQKu+spI2eP5scDPUe020IbRhMtCv9qsmy\/nEpgHaOZ8AQJpnDtTy9WkCMBY2ybPVJj2MCcD1nRQFosD4FZgZaIMUSPIqwdBSOB4pAA7gBDMwraq+zM7j414cBYKgyYt9ylOe0ni74KeediQeuklAWVvw5YUDJg\/elqcOrmwZ7GATiIOnCcBWPX3x8sFXOEQ8Wz3l2cwrr6r+MijnxeHlC4Moxz6etsnEeD22rn1l2AfiPjXoC+jH\/6+aEUSBVVJg5irNDLTBCcSAC4DBkxcqtACavE0QFmce1lwDuO9e9FVdAK8e6PHW3VxU3ooNXrv3jPDWrYkGcf8JYK1PIFYWHPUDvPp1TsiCpw3OytmCrjLAzkZ9sWuYCNirLWC2esQnATFqYQ9tCKvox1OS+lBXP0CvfVvlh5i+suxNigJRYPwKzAy0veLUTUgwtC8EAbZgCuDyeZ5CGQAPfgANio7daLSe+9RTT23KiFVbBqgeMAI0qAMqmIqLg7dwCqCDvhiyNnnD4KlfX1umr6FeVTWThYdwwBrA\/Rupy2tWjtdulQt7lQF9L7UygWibHXe7290a23jsznuwxyQgn90mL9AWXlFeH0lRIAqMX4El4x\/CZATgB9AABsBCFWLSoCakAaLAKmYMtLxP3qzVIsoCs\/AJ4LnhqA1tAnRV9ZUbgAnW2pTvwRogBW2hDnmAKzzBax5gXVXNT1U1dugPpK3DFvaomuQLaainjK2wCG8adAFd2yCuHA9dyIad+jV2E4s+q6qvP3\/Ywx7WQNw49Z80mwpkVItLgZmBtteRAi8PWZwawMB1ABbwCRkAN\/gJJ\/CEedpi2zxS3jlQV1X\/LkjwFJoASjf1lBP2AFPlwNeEwOPlIetPH4DLmwb5Y445pmnDv1XV5Btx1AVXfbOVd26li7pCM9pShufsvSFs15d+hD6Mke0mCvFs4BYy8Sg+O\/VtjbbQj3ZNUPpPigJRYPwKzAy0edDAJdQBtoC59957N2D0JQFHH310s1LElwOAHwgCPaiDLWBLwgqADnxV1QAbQE0I4McL16a+ANLLqEBZPdA1WfCATQ5i0AceeGB77Wtf2yz\/41XzinnPbAR37zABXhA3mbAfaNUVEuH9K69tXr6QB\/vZoy6AgzxPnA3i284Jv7DVJwdjHP+\/akYQBaIABWYG2uLXwgYGBVLi00IG4CsPIAGQJyvPPsCCKM95OA98gD6A0BYIxbmVV055YRht6ANsgV1eVfW12aAOwMIgvGMe+gBbbekXuAFeGuwygYA2D1vbYKxf4RD9CPmIkwO9MA8b2tyPMbNLf9pS1iRjQpE3V2S8v7E8CkSBpQrMDLQ96CJGzGMFWitEQBHMgBYkgZV3zKMWUuD5Wi8N4sIcVAFb4OapD8AEQXW0qS1tSsqBLM8cPPUnD6CFPIDWBOCGIhALc7APTNkC8qDqBqoy2gBinrX+2aQ9N1YB3xjcKLVem4ft04O4utUvxiBZrqidwT5asMHYkqJAFBi\/AjMDbd4o4AKbywJ6HqYBS+ACW\/n2QZVXCqBAqw6IOgeSQ5462gRf+cqDNM8ZIJ0DW1uebVU15wEemOVpk8cM\/FXVv5YMrIFVPz4RALX4tZCK5HxV9Vi4cAhb9cdOfbnRqR8rTLQjXMNW9vmGHvFubctjq76NPSkKRIHxKzAz0AYqsBsST5enDLa24AaI9nmhLh24ghvPFgTVkZwDyKrqL1vSxpDEiO2LG2tT6EFYBpjl22ofMCWTydCWOlXVX9uqXyEQceuqasCsnDpV1b\/azL622cM+E4s8IDdZuHkqLATKYuDGbkKyZYOxKg\/42kiKAlFg\/AosGf8QJiPgdQo18GzBD6DBbfCSwQtUnQNAIOONg6XwRtUE0LxVLQIe+Nmvqr7kTx2wla9e1WQpn3a0zWuW2tyPG4di1TxuUBXfBlSglwY7bU0UPhFoX9tufmrf\/lxTDeyFSoxJW2xjpwlC6IP9blJqy\/jU0y\/I69fkpJ2kKBAFxq\/AzEAbtIDNJQEuYORBg6l9YJQvDSATlgBBIQeAB0LAG8rb16a68ni9UlX1d2QDuPa1CdImBrAEUw+7iLOzB3St5xY\/15Y2ttlmmwbCYtJuKvLIgdsKF\/X1DcI8ZltwHmDumF3WhwuVaFO8HZwlIRF68MJ9U49+2JEUBaLA+BVYKGivdaWAF+B4vRJQWfYmrgymAwRtwZZBVZMwBK+2qmR1GIMwb9ZWUsdW0pb6zoMlmFdVA1H9ygdf5UwCVZNXuYKqr\/5i49DOAHIhEvnDDUmfGLSjX963G5j60a82QR3ojRmYLXeUr0\/lAV4fg6evfB9c\/kSBKDB6BWYG2mLLvFXgBDiwFqoAM\/CTx0N1xYYtmAmfDMdV1dSXeMO8VfADQhCtqv4IuvOS87xofQh98LpNFmCqH2VMCNpX\/wMf+EA7+OCDnerLAnnOYvFWvYC6NnjKVoZoy0QAxMYFzsYoX5vG5xODfduhz6pqyrBZR7xuK0\/sJ0WBKDB+BZaMfwiTEVjKZ\/0zyAEkL5Mn7CyIAaItgAMxAAIeaMtTZygLwoDJgxV+8HpX0LQvX1mTAO9YeEVfYKtvSV\/CJMopA6BuYEqHHXZYnxi8s9s35+y1117tZS97WfvkJz\/ZlGUbL1o\/oM679iTm8BZA7QvF6Fd455BDDulvApRnEtGvm5TqA7ZxBtqubFIUuJgCIz2cGWjzagEPcIEOsMWLwZWn6vxwjewP8FPHsXLOV1Vf3QGIvGZv9hPGsHxQO8prm\/fsRh+wgq264O+8ZF8CUdCUJylvfbileZL14mxW3xprXw92hzvcoYPdpAL01mn7VMBmfVdVM6F446Ax8vbZqx0wNzkpq76+ldV+UhSIAuNXYMn4hzAZgXAGr9J3Q2622WaN58vzBF3JTUAeLBDzQoEOCAEX4CTwHs77TkZfUADW6ldV41Hb53kDOA9a78AM+trUhvPKAqxktUpV9dCKCcWnAuENdrBT+e23376Jbd\/udrdrbop69J6H7TF54Q+etLZA3vbMM89s++yzT3Oj0Zc+SOwwUfCwvSjKJCC+rS12JkWBKDB+BZaMfwiTEfAy11tvvWa9Mk8T6GxBEpjFfHm6oAq4aikDcvIHaNuqB6baBFyeNq\/Wag0hD0vs1DdJ8Gy1px7Ptqr68kDw17dz6oBum\/sBdpOFm5XCLVWTN\/KxgxfuBVJA69F5HraYN3u0P9jOXuPRvlDIscce2w4\/\/PC+ppxNt771rfu6b+0pUzW5yTrXfX4XlQIZ7CwqMDPQBmyAFHrgjYImEAIeSAL3AD5hDYAV4hguqnMSGAIxzxw8ecNCDMBbNXn7H69aUg4k1dM\/D1d\/YGlCUBf4tckr1x8Pm11i5CYCHrF+eNceT\/eY+kknndSfhlRWfbb6lKAf49IeGOtTm2L5JhLn5LMV7PWpvklnGGe2USAKjFuBmYG2G4pg7cYc71MsGOwAGvx4zkALsmAHgI6BF9xA3b7ldYDKmwVd8BWmsMJDOzxmUARDkwHgKiNkoW1tAad\/C3FmEAdZffHaedrK6Ec4xOQgaYOXzcM2FrabBLx+1StWtWNSqpqscNEGz1uoRVjEeJQBbzqwS2hFqEgIhT1JUSAKjF+BmYE27xXs3HQDXbAGQrAGwqpqVnWAGiCCMqDd5z736e8DATxQBkAw5fn6Zvedd965HXTQQW2\/\/fbrMWRhCJOCdgdQgzhvHMTB2b+F9rXHywV65b1fREjEeclj6NZkW5ro5U9veMMb2lve8pb25Cc\/uW266aaNbWLrwA3YPHgTQFU1nrfJxwTBw2a\/c\/owdhPGYJP6+pvBlCFFgUWnwMxAu2oCsnPPPbfxinnOQGkLqoDGO+U9O+YVg7wHcIAPgKuq38AEU3V5ujxYHm1VNRODss4BonMgbXIAaNDWB0iCNm\/XhKGssI2QhXwJZNnphiKbH\/3oRzf9nnDCCc2nBO2x2X+kPrRrK2ZvC8zOsaVqcpNUf1XV1l9\/\/b58kAfvxqnVKMomRYEoMH4FZgbaoOs908AFdqAGsGK+IAm4QhpV1Xji97jHPZqvGhMPVkZZgLcP5iDpZiGPFiSFNWx54toCdF69fwF9qScfmJXTB6iDNbDqG6irJm8CBHjvSwH0rbbaqmmPJ60OW0wEJhjH+tSHcbAJlJVhJ29bvolInk8R2tInO3jhHo1nZ1IUiALjV2BmoC18AG4gCF4ACqSSYwkoeb5AOjysAvbgBnpi2uDMQwVNENemrWP72lPOShIQlscT57mLWds\/++yzG3g7B\/7i18oqo642xJ3vd7\/7tWc961mNXerwsj10Y18cmm0mIKEaSwgtB3SzUkgFqE0ExstDl4yZ\/dqz3vsRj3hE48kL54z\/XzUjiAJRgAIzA23hBLFh8JUMDtiqJmGNqsmyt6pq8gEOjJUDR3nacAyqIC\/+DLTODXk8W3B2XnmAdF57IMoT1i4vePCOh7pArZwtT1y+m49eLuVBG179xhtv3HwKAF8ThbFoX8jEo+6OhUi8DItt+nJePtvl6YPXrm0TUtVk7M4nRYEoMG4FZgba4CXUseWWW\/bwByBWVV8zXTVZqgdm4Aauyre5HzcJgQ6MwRvknJPctBSfBlNJqAFsec4836rqYQ0Q5emryzP2lKIyyusTpKuqh2OAlBfOU1fWFxhI3q39wAc+sPHy2cKDFurwHpIh9n3KKaf0B298z6XEAzcW0DZeoRT19Gvp4KGHHtrcRDWuuaHmNwpEgRlQYN1Dew2JWDVZCgec66+\/fm+1qvpb+0BL2EImyNkHZaELCVSFL8SQebDCELxpbSmrHjBKwHrf+963gfkAWO1XVRMOAW8eeFX1x+HZAvT6BXDtATpPWH03CTfffPOmT166yUHfAAzaQ2xarN4xG8BeYlfVZIzatdLEihNj0raA3QsAABAASURBVB875LNP2aQoEAXGr8CS8Q9hMgKg4kUDlLDCJLf1FR9g6Rjw7As9ACegKQu0IAnSzoEdbxnInRfmAEEeOa\/4gAMOaG4iWlbHKwZQ5YBVGEMb2q6q3r92eMJV1WyBXB\/65KXf9ra3bR5lNxnwkoVceMwmAUn78m9605t2uIO9pYTGWlWG1j1+3xWpXWEd\/ThvbCajXih\/okAUGL0CMwNtgAJu4OSdujLAJYE1kIJyVTWhDWERAAc5dQYvVhmQExoRbuGFa0NZ0D755JObG3tuaHpyUX11lLF1DMaObR2zjT3akMS711tvvWYyUMa+tj0MYzLwMI8QisfRhVE22mij5h0ooM0e41HepwXtGjfwa0e\/8m1NDrx3SbmkKBAFVkqBqS40M9DmkYIVQAIWOIIbjxfUeKuOQbKqOjB5z7xzKzqUAW43Bb2ICbTliylrW3smgyc84QmNl+ump2+mcXOQV+w8j7qqmnNgrT9es1CI5YH6NhHox7I8k4VzJgFt+U\/RrzGYOMSttS95D8npp5\/eV4OA+lDeg0AeEgJ1Xj779asNenigSDvaTooCUWD8CswMtMGXp8uLtbLDpQFsoAQxecAKZsoAWlX1LyNQT\/6wtYLDsTKS\/KpqPFmQ1d4AfPu8eBMFGAuTyANtwGaXfvUpXzn5QAzQ2gF9IY1PfOITHfhnnXVWs7RPWe0MoFdOnnZMMsIk4O9Y37zwqupxfNBnt\/GLk7f8RIEoMBMKzAy0QUz8FryADbDkgZbtkECU5wxwYCdfGVAfIK8NoQX5rnLV5GvJrNY47rjjeniE564f50HbzUOgV4fHrT2w1r5j5fQnj\/cLwPe85z37zUqhFh4yQLNvsN0EIM\/EoZ6kHZOHG6GedlRWu9rTt1CIVFVNfXYai3pJUWBQINvxKjAz0AYscPOUI\/ABGwi7NPIBzxbgnJcPaFXVX2MK5LxeW20AN68amAFYWxI4u0kpLg7I8pS1P\/TJFp4zL1h577oWjwZYIRfb5z3vef3moVCH8MUxxxzTb1qaeNwkBV772lJHP+LwXh61xRZbtE022aQ\/ru5BG6tTeO9sshrFvjz987KVMd6kKBAFxq\/AzEDbpaiq5oVJ4AmWoOeGHU9YsgIDXMEZxAGRF6oMmAMjQFZVf0pROe0qax\/kxbXdQAR3IQje9ZDA2D7I29e+ejxeK030Y8LgJfPa2VhVTb6JgI2Aa3JRTjvs0gb4ArY68nnrQi7DePQl35OR8tmnrvP0MI6kKBAFxq\/AzEAbzEAZSIEKgIEPzKqqhyHAi+cMii6d85bwCUGArDrAB6LCIFXVeL2AajKwkgPUtakNMWlAFv4AUfnqg7p2xa0d61f4wgTBNnXcfPzQhz7UrEax9nurrbbq4Qze8YMe9KD+VKTwx4Mf\/OD2mMc8pj3sYQ9roM5W7buxyR71ePI8b98zyXPnkbPTpEUT32BjvIsqZbBRYEYVWDIr4wJO4OVl2gfVAdC24MnDFXZwbNzAB8ZCF0IL8tXj2QKkY7FvbfKAwZa3rX1lqiYP9GibV6u8fJPB0A6blHdsMhA2kWdd9u1vf\/v+WljHAAvC3vYH0B648ZSkSYP3rl82ePhHLNxNSCtG2GSZoElGOZMXL9vLs\/RRNVkrbrxJUSAKjF+BmYE2WIIm71c4AyhBDsDk83CBkfcKniDrHOAqywt2zIsdyvLaq6rxWnnL6vCmtaee8uoCqrAJLxg4JWXZIc++cmx0zCv3vY0mA5BVXlu8ahOL85Ya+vcCe+Ngu6WG1mxbKuiVskceeWTTDo\/ekkA2sdUEBPZV1fTxmc98RlNJUSAKzIACMwPtwbsFR1AFQVsABkWgFnpwg07IQAjB9QPAISwCvuoAMIiDJAACqzq8dAlA5YGxBMb6A2lt2retqsYe3jCg8trFsj04ow+rRkwM1nWrKx+wnVPPOXbrG7wBGKRB\/Pzzz2\/aHD4RsMmEog6PXXnt69ONTvYkRYEoMH4FZgbaLgXQ8TQBTOJtArXwAwgLGbgh6HFvTxACnDJCDV6T+vznP79ts802zStNxZmV9y0yHl4BcMAeygutDGEVAHfOBAHiwA+0Jouq6rFocXF5PHZti2mLe9vyrj3ObgIBWuu0edJWrwC4dkwoJgPjYN9zn\/vcZgXKm970pvaiF72o7b777k37IG9dt2\/C8a07e+yxR\/9yBfokRYEoMH4FZgbaw8uSvOXvSU96Ugead0oDMpCDtG+I2WuvvZp3Vnu6kNfLU\/XluqDpHduW+3naUJgFKL2VD1x58mLED3\/4w5tYs9UcoM9jN1kIe\/B0ecw8YMDlEasnnxcNus7xpi0TBHiTCtj6V6qqJizCO9auc9rmqYtli7+DthuPXt8qJm7iYAuwm1zEzHnZxjL0wSbtJ0WBKDB+BaYZ2v+TukDKy+RJg6CQg1ACKAMdb9gDLCAonAFyYAqOPGNfjADioCmccMYZZ\/R4McBbRud912LDIO4YhJUHZ0AF2KrqIQvtArLJQj+86yFP\/6CsT7AVrmEDO3nH+vA0JNCqy4OXgFjsGsCNTX0TgNCOdnyy4M2Li5t4eOj6JaKytklRIAqMX4GZgTbvFSgtodt\/\/\/3b4GkKNXgftfdygCUQAjug8YJ5y8IJhxxySNMG7xjklANYgBeyUFf44ogjjmi8cEv4hEOUBWwThjCM5BhIqyarS4RA\/Kvw+l\/zmte0pz71qc030whv8PJ59iYCNxnZZdLRL9CzZ999920f\/OAH22GHHdZAmc3i2+zVP3j7hhrevpdYmVhMVOzTnnb0nxQFosD4FZgZaPN6hT94ybxmsAOzquprtHmvvGgeMoB7SpDXCsYgzJsFcZ4rYMvn\/fKiebHyHQ8ABGflwdmKE8B0zLtWRrJvIrEVM7f+2hOLvHPnB8+Z7ezxaUE+u0HXUj62CdPI1ydQm0RMIMItVdXYCuK2bDEW3jvPm03j\/zfNCKLAlCgwBWYsmQIb1ogJ4MiDBryhQSEGQAQ04REQA2T5YAa4vFYPn4iJi1e7SXnnO9+5PfGJT+wPuChnBQkIKusYhPUhBAG22tcvr1f+0EdVNTcyef6Pe9zj+oM6zgOxtoAeeNnBJh6\/GPXQPu9d\/NqkYR+0xdW1zxM3Xi+ZEp8HcmMVRgF23r1PCo71od+kKBAFxq\/AzEDbAyfAzJsd1mIDLOCBIMjxcIULHFdVcyPP8jjABV8eOA9d6INnC8rKu8y2wAqetsCpHeDl3QIqb1w+LxnktQ2szgM7G4Q+eNRAqq+qavoDV5OFSUN5bbuRCMD6V1cCaTZIbPRpwSQA2CaNITSjbUmepI2kKBAFxq\/AzEBbKMEDJuDo5h7AgdUAWCEDKytAVKwXZHnethKgg5zygArYoAnoPFYglS8pK8wCmECtHxMG79m\/hPas9DB5KHvCCSc0CYDF1y0b1LevGNMu0KqnbxON5YWOtQn++pCvXXA3PsA2Vkkblg36qjHtbrDBBv17MuX7BCJpLykKXLoCKTHtCswMtN0gtOLjlFNOab4BZgAzyAE4CAtzWConHMEjBnFeMfgqA4YeDeeBg6FwBVAqWzW5qQiAICrObCuJdQ\/HPHLJEkNlJfAXb+bJH3XUUU2dE088sQlpAL44N7vYwE6eOE9baMUnh0033bQ\/lWkCAXTteMeIG5PaMAYxc3ZoW13jt6\/9qpr2\/8PYFwWiwEoqMDPQ5g0DFEgDrhuIAAdo4AWG1mLLB2IAF6rgyVpCB65gaImf7aGHHtp4xW5g8liBUD0xZ0D2gIwVICCvzapqvG9w9upUMXLfcmMScYNUCIQnzcsGX7Za8cHL5r37pGCfXeyxosQLoHbZZZcG5jxrkw3v2yTgEwPvWnmTjvHx9LUvXEIDnxyMayX\/F1IsCkSBESgwM9AWhgBMyT7P27pnIRPrlq0q8Va9V73qVc2aazDdbrvt2uMf\/\/gm\/9hjj23ywPLwww\/vD7nwYgEQuK3xdu6ggw5qBx54YNt77737lucsnXbaaU0flu699KUvbR7y2Xjjjdt+++3XPJVo2d673vWu9va3v72Buj59rdmOO+7Y2AHOnnJ83ete13bbbbe26667tp122qnXtWWDTxDKPvKRj2xuUG699dZt++23b9q1FHDbbbftDxVpy\/jB36cFYZkR\/C8ulInpJwqMWoGZgfaor0KMjwJRIAqspAKB9koKlWJRIApEgWlQINCehquwhm1Ic1EgCsyuAoH27F7bjCwKRIEZVCDQnsGLmiFFgSgwuwqME9qzez0ysigQBaLAvAoE2vPKk5NRIApEgelSINCerusRa6JAFBinAgtmdaC9YFKnoygQBaLA6isQaK++hmkhCkSBKLBgCgTaCyZ1OooC41Yg1k+HAoH2dFyHWBEFokAUWCkFAu2VkimFokAUiALToUCgPR3XIVZMgwKxIQqMQIFAewQXKSZGgSgQBQYFAu1BiWyjQBSIAiNQINAewUVacyampSgQBcauQKA99isY+6NAFFhUCgTai+pyZ7BRIAqMXYFZg\/bYr0fsjwJRIArMq0CgPa88ORkFokAUmC4FAu3puh6xJgpEgVlTYA2PJ9Bew4KmuSgQBaLA2lQg0F6b6qbtKBAFosAaViDQXsOCprkosPgUyIgXUoFAeyHVTl9RIApEgdVUINBeTQFTPQpEgSiwkAoE2gupdvoaqwKxOwpMjQKB9tRcihgSBaJAFLh0BQLtS9coJaJAFIgCU6NAoD01l2LdGpLeo0AUGIcCgfY4rlOsjAJRIAp0BQLtLkP+RIEoEAXGocDigfY4rkesjAJRIArMq0CgPa88ORkFokAUmC4FAu3puh6xJgpEgcWjwCqNNNBeJdlSKQpEgSiwbhQItNeN7uk1CkSBKLBKCgTaqyRbKkWBKLAyCqTMmlcg0F7zmqbFKBAFosBaUyDQXmvSpuEoEAWiwJpXINBe85qmxcWkQMYaBRZYgUB7gQVPd1EgCkSB1VEg0F4d9VI3CkSBKLDACgTaCyz4+LqLxVEgCkyTAoH2NF2N2BIFokAUuBQFAu1LESino0AUiALTpECg3do0XY\/YEgWiQBSYV4FAe155cjIKRIEoMF0KBNrTdT1iTRSIAlGgtXk0CLTnESenokAUiALTpkCgPW1XJPZEgSgQBeZRINCeR5ycigJRYG0pkHZXVYFAe1WVS70oEAWiwDpQINBeB6KnyygQBaLAqioQaK+qcqkXBeZXIGejwFpRINBeK7Km0SgQBaLA2lEg0F47uqbVKBAFosBaUSDQXiuyLo5GM8ooEAUWXoFAe+E1T49RIApEgVVWINBeZelSMQpEgSiw8AoE2vNpnnNRIApEgSlTINCesgsSc6JAFIgC8ykQaM+nTs5FgSgQBaZLgRZoT9kFiTlRIApEgfkUCLTnUyfnokAUiAJTpkCgPWUXJOZEgcWuQMY\/vwKB9vz65GwUiAJRYKoUCLSn6nLEmCgQBaLA\/AoE2vPrk7NRYM3U4B+qAAADM0lEQVQrkBajwGooEGivhnipGgWiQBRYaAUC7YVWPP1FgSgQBVZDgUB7NcRL1RUpkPwoEAXWlgKB9tpSNu1GgSgQBdaCAoH2WhA1TUaBKBAF1pYCgfaqKZtaUSAKRIF1okCgvU5kT6dRIApEgVVTINBeNd1SKwpEgSiwThRYIbTXiTXpNApEgSgQBeZVINCeV56cjAJRIApMlwKB9nRdj1gTBaLAChXICQoE2lRIigJRIAqMRIFAeyQXKmZGgSgQBSgQaFMhKQpMhwKxIgpcqgKB9qVKlAJRIApEgelRINCenmsRS6JAFIgCl6pAoH2pEqXAmlQgbUWBKLB6CgTaq6dfakeBKBAFFlSBQHtB5U5nUSAKRIHVUyDQXj39Llk7OVEgCkSBtahAoL0WxU3TUSAKRIE1rUCgvaYVTXtRIApEgbWowCpAey1ak6ajQBSIAlFgXgUC7XnlyckoEAWiwHQpEGhP1\/WINVEgCqyCAoupSqC9mK52xhoFosDoFQi0R38JM4AoEAUWkwKB9mK62hnreBWI5VHgQgUC7QuFyCYKRIEoMAYFAu0xXKXYGAWiQBS4UIFA+0IhslnXCqT\/KBAFVkaBQHtlVEqZKBAFosCUKBBoT8mFiBlRIApEgZVRINBeGZXWTJm0EgWiQBRYbQUC7dWWMA1EgSgQBRZOgUB74bROT1EgCkSB1VZgjUJ7ta1JA1EgCkSBKDCvAoH2vPLkZBSIAlFguhQItKfresSaKBAF1qgCs9dYoD171zQjigJRYIYVCLRn+OJmaFEgCsyeAoH27F3TjGhxKZDRLjIFAu1FdsEz3CgQBcatQKA97usX66NAFFhkCgTai+yCj3G4sTkKRIFlCgTay7TIXhSIAlFg6hUItKf+EsXAKBAFosAyBQLtZVqsu730HAWiQBRYSQUC7ZUUKsWiQBSIAtOgQKA9DVchNkSBKBAFVlKBBYL2SlqTYlEgCkSBKDCvAoH2vPLkZBSIAlFguhQItKfresSaKBAFFkiBsXYTaI\/1ysXuKBAFFqUCgfaivOwZdBSIAmNVINAe65WL3VHg0hTI+ZlUINCeycuaQUWBKDCrCvw\/AAAA\/\/\/ltTT6AAAABklEQVQDADv0HiG7reBDAAAAAElFTkSuQmCC","height":220,"width":365}}
%---
%[output:6a0ad264]
%   data: {"dataType":"text","outputData":{"text":"\/home\/shogo\/Workspace\/GitHub\/MsipWorkM\/code\/SaivDr-4.2.2.5 exits.\nMEX files exist.\n","truncated":false}}
%---
%[output:540f4f62]
%   data: {"dataType":"textualVariable","outputData":{"name":"redundancyNsolt","value":"1.2500"}}
%---
%[output:6a8e6d7a]
%   data: {"dataType":"matrix","outputData":{"columns":2,"name":"szFilters","rows":1,"type":"double","value":[["40","40"]]}}
%---
%[output:6409629c]
%   data: {"dataType":"matrix","outputData":{"columns":2,"name":"szPatchTrn","rows":1,"type":"double","value":[["96","96"]]}}
%---
%[output:86c4735c]
%   data: {"dataType":"textualVariable","outputData":{"name":"nSubImgs","value":"1"}}
%---
%[output:654e79de]
%   data: {"dataType":"textualVariable","outputData":{"header":"logical","name":"noDcLeakage","value":"   1\n"}}
%---
%[output:218a272a]
%   data: {"dataType":"textualVariable","outputData":{"name":"maxIters","value":"200"}}
%---
%[output:9f758270]
%   data: {"dataType":"text","outputData":{"text":"Copy angles from Lv1_Cmp1_V0~ to Lv1_Cmp1_V0\nCopy angles from Lv1_Cmp1_Vh1~ to Lv1_Cmp1_Vh1\nCopy angles from Lv1_Cmp1_Vh2~ to Lv1_Cmp1_Vh2\nCopy angles from Lv1_Cmp1_Vh3~ to Lv1_Cmp1_Vh3\nCopy angles from Lv1_Cmp1_Vh4~ to Lv1_Cmp1_Vh4","truncated":false}}
%---
