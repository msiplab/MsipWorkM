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

figure(1)
subplot(2,3,1)
imshow(X)
title('原画像')
%%

isForceDesign = true; % 再設計フラグ（true: 強制再設計, false: 既存ファイルがあればスキップ） %[control:checkbox:48c8]{"position":[17,21]}

isCodegen = true; % コード生成 %[control:checkbox:53ff]{"position":[13,17]}
msip.saivdrSetup(isCodegen)
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
redundancyNsolt = ...
    (prod(decFactor)==1)*((P-1)*nLevels+1) + ...
    (prod(decFactor)>1)*((P-1)/(M-1)-(P-M)/((M-1)*M^nLevels))
assert(redundancyNsolt<=redundancyRatio)

%[text] $L\_1\\times L\_2=\\left(\\mu\_1^{\\tau}+\\zeta\_1\\frac{\\mu\_1(\\mu\_1^{\\tau}-1)}{\\mu\_1-1}\\right) \\times\\left(\\mu\_2^{\\tau}+\\zeta\_2\\frac{\\mu\_2(\\mu\_2^{\\tau}-1)}{\\mu\_2-1}\\right)$
% Filter size [ Ly Lx ]
maxDecFactor = decFactor.^nLevels;
szFilters = maxDecFactor + ppOrder.*decFactor.*(maxDecFactor-1)./(decFactor-1)

% 訓練パッチサイズ
% [設定解説]
%   szPatchTrn = szOrg          → 画像全体を1サンプルとして使用（現在の設定）
%   szPatchTrn = floor(szOrg/2) → 画像の 1/4 面積のパッチを抽出（下記 nSubImgs と組み合わせる）
%   条件: szPatchTrn >= szFilters（フィルタサイズ以上）を満たす必要がある
szPatchTrn = szOrg
assert(all(szPatchTrn>=szFilters))

% 1画像あたりの訓練サンプル数
% [複数パッチ・ランダムパッチ抽出の解説]
%   szPatchTrn = szOrg の場合: パッチ = 画像全体なので有効サンプル数は常に 1
%   szPatchTrn < szOrg に設定した場合: 下記 randomPatchExtractionDatastore が
%   1画像から nSubImgs 枚をランダム位置で抽出し、多様な訓練データを生成できる
%   （例: szPatchTrn=floor(szOrg/2), nSubImgs=8, miniBatchSize=4, maxEpochs=50）
nSubImgs = 1
assert(nSubImgs > 0)

% No DC-leakage
noDcLeakage = true %[control:checkbox:5c50]{"position":[15,19]}
%%
%[text] #### 辞書の設定
% 既存の設計ファイルを検索（パターン: example09_03_nsoltdictionary_*.mat）
nsoltFiles = dir(fullfile(datfolder, myfilename + "_nsoltdictionary_*.mat"));
[~, sortIdx] = sort([nsoltFiles.datenum],'descend');
nsoltFiles = nsoltFiles(sortIdx);
hasExistingFile = ~isempty(nsoltFiles);

if ~isForceDesign && hasExistingFile
    latestNsoltFile = fullfile(datfolder, nsoltFiles(1).name);
    fprintf("既存の設計ファイルを読み込み: %s\n", nsoltFiles(1).name);
    S = load(latestNsoltFile);
    analysisnet = S.analysisnet;
    synthesisnet = S.synthesisnet;
    nLevels_ = extractnumlevels(analysisnet);
    decFactor_ = extractdecfactor(analysisnet);
    nChannels_ = extractnumchannels(analysisnet);

    assert(nLevels==nLevels_)
    assert(all(decFactor==decFactor_))
    assert(all(nChannels==nChannels_))
else
    % Number of outer iterations (IHT + dictionary update)
    nItersNsolt = 20;

    % Standard deviation of initial angles
    stdInitAng = 1e-1; %pi/6;

    % Mini batch size
    % [解説] szPatchTrn = szOrg の場合: 有効サンプル数 = 1 なので miniBatchSize = 1
    %        szPatchTrn < szOrg でランダムパッチ抽出を有効にした場合は
    %        miniBatchSize = 4 程度に増やして複数パッチを同時に勾配計算できる
    miniBatchSize = 1;

    % Number of Epochs
    % szPatchTrn = szOrg の場合: 1 epoch = 1 gradient step（サンプル数=1, バッチ=1）
    % 100 epochs → 100 gradient steps per outer iteration
    % [解説] ランダムパッチ抽出（nSubImgs=8, miniBatchSize=4）に切り替えた場合:
    %        1 epoch = nSubImgs/miniBatchSize = 2 steps なので maxEpochs = 50 が等価
    maxEpochs = 100;

    % Number of gradient steps per outer iteration
    maxIters = nSubImgs/miniBatchSize * maxEpochs

    % Training options (Adam optimizer)
    opts = trainingOptions('adam', ... % Adam (Adaptive Moment Estimation)
        'InitialLearnRate',1.0e-03,...  % Adam 標準の学習率
        'GradientDecayFactor',0.9,...   % β1
        'SquaredGradientDecayFactor',0.999,... % β2
        'Epsilon',1e-08,...
        'LearnRateSchedule','piecewise',...
        'LearnRateDropFactor',0.5,...
        'LearnRateDropPeriod',50,...    % maxEpochs の半分で学習率半減
        'L2Regularization',0.0,...
        'MaxEpochs',maxEpochs,...
        'MiniBatchSize',miniBatchSize,...
        'Verbose',1,...
        'Plots','none',...
        'ResetInputNormalization',0);
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
            layerName = synthesisnet.Learnables.Layer(iLearnable);
            synthesisnet.Learnables.Value(iLearnable) = ...
                cellfun(@(x) x+stdInitAng*randn(size(x)), ...
                synthesisnet.Learnables.Value(iLearnable),'UniformOutput',false);
        end
    end

    % Copy the synthesizer's parameters to the analyzer
    synthesislgraph = layerGraph(synthesisnet);
    analysislgraph = fcn_cpparamssyn2ana(analysislgraph,synthesislgraph);
    analysisnet = dlnetwork(analysislgraph);
%[text] #### 随伴関係（完全再構成）の確認
%[text] NSOLTはパーセバルタイト性を満たす．
    nOutputs = nLevels+1;
    x = rand(szPatchTrn,'single');
    s = cell(1,nOutputs);
    dlx = dlarray(x,'SSCB'); % Deep learning array (SSCB: Spatial,Spatial,Channel,Batch)
    [s{1:nOutputs}] = analysisnet.predict(dlx);
    dly = synthesisnet.predict(s{:});
    display("MSE: " + num2str(mse(dlx,dly)))
%[text] #### 要素画像の初期状態
    figure
    atomicImagesNsolt = getatomicimages(synthesisnet, [], 2^(nLevels-1));
    nAtomsN = size(atomicImagesNsolt,4);
    scaledImgsNsolt = imresize(atomicImagesNsolt,8,'nearest');
    scaleAtom = @(x) x / (max(abs(x(:))) + eps);
    tmpCells = arrayfun(@(i) scaleAtom(scaledImgsNsolt(:,:,:,i)), 1:nAtomsN, 'UniformOutput', false);
    dispImgsNsolt = cat(4, tmpCells{:}) * 0.5 + 0.5;
    montage(dispImgsNsolt, ...
        'BorderSize',[2 2],'Size',[ceil(nAtomsN/8) 8], ...
        'BackgroundColor','white','ThumbnailSize',[20 20]);
    title('Atomic images of initial NSOLT')
    drawnow
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
    figure
    minibatch = preview(patchds);
    responses = minibatch.ResponseImage;
    responses = cellfun(@(x) x + 0.5,responses,'UniformOutput',false);
    figure
    montage(responses,'Size',[1 1]);
    drawnow
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
%[text] - 辞書更新：GD法（Adamオプティマイザ） \
    % Check if IHT works for dlarray
    %x = dlarray(randn(szPatchTrn,'single'),'SSCB');
    %[y,coefs{1:nOutputs}] = iht(x,analysisnet,synthesisnet,sparsityRatio);
%[text] #### 辞書学習の繰返し計算
    import saivdr.dcnn.*
    %profile on
    for iIter = 1:nItersNsolt

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
    %profile off
    %profile viewer
%[text] #### 訓練ネットワークの保存
    import saivdr.dcnn.*
    synthesislgraph = layerGraph(synthesisnet);
    analysislgraph = fcn_cpparamssyn2ana(analysislgraph,synthesislgraph);
    analysisnet = dlnetwork(analysislgraph);
    save(fullfile(datfolder,sprintf("example09_03_nsoltdictionary_%s",datetime('now','Format','yyyyMMddHHmmssSSS'))),'analysisnet','synthesisnet','nLevels')
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
%[text] #### 要素画像の表示
figure
atomicImagesNsolt = getatomicimages(synthesisnet, [], 2^(nLevels-1));
nAtomsN = size(atomicImagesNsolt,4);
scaledImgsNsolt = imresize(atomicImagesNsolt,8,'nearest');
scaleAtom = @(x) x / (max(abs(x(:))) + eps);
tmpCells = arrayfun(@(i) scaleAtom(scaledImgsNsolt(:,:,:,i)), 1:nAtomsN, 'UniformOutput', false);
dispImgsNsolt = cat(4, tmpCells{:}) * 0.5 + 0.5;
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
syn_nsolt = @(x) synthesisnsolt(x,synthesisnet4predict,nsoltconfig);
adj_nsolt = @(y) analysisnsolt(y,analysisnet4predict,nsoltconfig);
%[text] #### 随伴関係の確認
x = adj_nsolt(y);
v = randn(size(x));
u = syn_nsolt(v);
assert(abs(dot(y(:),u(:))-dot(x(:),v(:)))<1e-3)
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
blkdctwon  = { syn_blkdct,  adj_blkdct,  "Block DCTwoN", false };
blkdct  = { syn_blkdct,  adj_blkdct,  "Block DCT", true };
blkpcawon  = { syn_blkpca,  adj_blkpca,  "Block PCAwoN", false };
blkpca  = { syn_blkpca,  adj_blkpca,  "Block PCA", true };
blkrica = { syn_blkrica, adj_blkrica, "Block RICA", true };
blkksvd = { syn_blkksvd, adj_blkksvd, "Block K-SVD", true };
nsoltwon   = { syn_nsolt,   adj_nsolt,   "NSOLTwoN", false };
nsolt = { syn_nsolt,   adj_nsolt,   "NSOLT", true };
dicset  = { blkdctwon, blkdct, blkpcawon, blkpca, blkrica, blkksvd, nsoltwon, nsolt };
nDics   = length(dicset);
%[text] #### IHT
%[text]  $\\mathbf{x}^{(t+1)}\\leftarrow \\mathcal{H}\_{BK}\\left(\\mathbf{x}^{(t)}+\\mu^{(t)}\\hat{\\mathbf{D}}^\\textsf{T}\\left(\\mathbf{y}-\\hat{\\mathbf{D}}\\mathbf{x}^{(t)}\\right)\\right)$
%[text]  $t\\leftarrow t+1$
%[text] -  T. Blumensath and M. E. Davies, "Normalized Iterative Hard Thresholding: Guaranteed Stability and Performance," in IEEE Journal of Selected Topics in Signal Processing, vol. 4, no. 2, pp. 298-309, April 2010, doi: 10.1109/JSTSP.2010.2042411. \
nItersIht = 2000;

% 平均値を引いた画像を用意（近似後に平均値を加算）
ymean = mean(yorg,"all");
y = yorg - ymean;
% 準備
c = 1e-3;
kappa = 1.1/(1-c);
nCoefs = floor(sparsityRatio*prod(szOrg));
psnrs = zeros(nItersIht,nDics);
ssims = zeros(nItersIht,nDics);
yaprxs = cell(1,nDics);
% 繰り返し処理
for iDic = 1:nDics
    dic_ = dicset{iDic};
    synproc = dic_{1};
    adjproc = dic_{2};
    dicname = dic_{3};
    isStepSizeNormalized = dic_{4};
    % IHT
    display(dicname)
    s = adjproc(y); % D^Ty
    xt = zeros(size(s),'like',s); % x1 = 0;
    if isStepSizeNormalized % 正規化あり
        suppt = find(hardthresh(s,nCoefs)); % Γ1 = supp(H_K(D^Ty))
        maskt = (abs(s)~=0);
    end
    for iIter=1:nItersIht
        % Gradient descent
        gt = adjproc(y-synproc(xt)); % g = D^T(y-Dxn)
        if ~isStepSizeNormalized % 正規化なし
            mu = (1-c);
            xtp1 = hardthresh(xt+mu*gt,nCoefs);
        else % 正規化あり
            ggt = gt(suppt); % g_Γn
            ugt = synproc(maskt.*gt); % D_Γn^T g_Γn
            mu = (ggt.'*ggt)/(ugt(:).'*ugt(:));
            ttp1 = hardthresh(xt+mu*gt,nCoefs); % ~xn+1 = H_K(xn + μn gn)
            supptp1 = find(ttp1); % Γn+1 = supp(~xn+1)
            if length(supptp1)==length(suppt) && all(supptp1==suppt)
                xtp1 = ttp1; % xn+1 = ~xn+1
            else
                dxt = ttp1-xt; % ~xn+1 - xn
                omega = (1-c)*(norm(dxt,'fro')/norm(synproc(dxt),'fro'))^2;
                if mu <= omega
                    xtp1 = ttp1; % xn+1 = ~xn+1
                else
                    while mu > omega
                        mu = mu/(kappa*(1-c));
                        ttp1 = hardthresh(xt+mu*gt,nCoefs); % ~xn+1 = H_K(xn + μn gn)
                        dxt = ttp1-xt; % ~xn+1 - xn
                        omega = (1-c)*(norm(dxt,'fro')/norm(synproc(dxt),'fro'))^2;
                    end
                    supptp1 = find(ttp1);  % Γn+1 = supp(~xn+1)
                    xtp1 = ttp1; % xn+1 = ~xn+1
                end
            end
            % Update
            suppt = supptp1;
            maskt = zeros(size(maskt),'like',maskt);
            maskt(suppt) = 1;
        end
        xt = xtp1;
        % Monitoring
        checkSparsity = nnz(xt)/prod(szOrg)<=sparsityRatio;
        assert(checkSparsity)
        yaprx_ = synproc(xt);
        psnr_ = psnr(cast(yaprx_,'like',y),y);
        ssim_ = ssim(cast(yaprx_,'like',y),y);
        psnrs(iIter,iDic) = psnr_;
        ssims(iIter,iDic) = ssim_;
        %fprintf("IHT(%d) PSNR: %6.4f\n",iIter,psnr_);
    end
    yaprxs{iDic} = yaprx_ + ymean;
end
%%
%[text] ## 近似結果の表示
dicnames = [blkdctwon{3},blkdct{3},blkpcawon{3},blkpca{3},blkrica{3},blkksvd{3},nsoltwon{3},nsolt{3}];
psnrtbl = array2table(psnrs,'VariableNames',dicnames);
psnrtbl = horzcat(table((1:nItersIht).','VariableNames',"Iterations"),psnrtbl);
ssimtbl = array2table(ssims,'VariableNames',dicnames);
ssimtbl = horzcat(table((1:nItersIht).','VariableNames',"Iterations"),ssimtbl);

% 線スタイル設定（線種 × マーカーの組み合わせで8系列を識別）
lineStyles = {'-', '--', ':', '-.', '-',  '--', ':',  '-.'};
markers    = {'none','none','none','none','o',  's',  '^', 'd' };
markerStep = max(1, floor(nItersIht/10));

% PSNR のグラフ
figure
hold on
for iDic = 1:nDics
    plot(1:nItersIht, psnrs(:,iDic), lineStyles{iDic}, ...
        'LineWidth', 2, 'Marker', markers{iDic}, 'MarkerSize', 6, ...
        'MarkerIndices', 1:markerStep:nItersIht, ...
        'DisplayName', dicnames(iDic))
end
hold off
xlabel('Iterations')
ylabel('PSNR [dB]')
legend('Location','best')

% SSIM のグラフ
figure
hold on
for iDic = 1:nDics
    plot(1:nItersIht, ssims(:,iDic), lineStyles{iDic}, ...
        'LineWidth', 2, 'Marker', markers{iDic}, 'MarkerSize', 6, ...
        'MarkerIndices', 1:markerStep:nItersIht, ...
        'DisplayName', dicnames(iDic))
end
hold off
xlabel('Iterations')
ylabel('SSIM')
legend('Location','best')


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
%%
%[text] ## 【関数定義】
%[text] #### NSOLT合成処理関数
function y = synthesisnsolt(x,synthesisnet4predict,config)
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
y = synthesisnet4predict.predict(s{1:nLevels+1});
end

%[text] #### NSOLT分析処理関数
function x = analysisnsolt(y,analysisnet4predict,config)
nLevels = config.nLevels;
szCoefs = config.szCoefs;
[s{1:nLevels+1}] = analysisnet4predict.predict(y);
nCoefs = sum(prod(szCoefs,2),1);
%x = [];
x = zeros(nCoefs,1);
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
%[text] #### NSOLTネットワークの要素画像抽出
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
%[text] © Copyright, 2023-2026, Shogo MURAMATSU, All rights reserved.

%[appendix]{"version":"1.0"}
%---
%[metadata:view]
%   data: {"layout":"inline","rightPanelPercent":31.4}
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
