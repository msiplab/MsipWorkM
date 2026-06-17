%% 例題9.4（ブロック k-SVD）
% 村松正吾　「多次元信号・画像処理の基礎と展開」
%
% 動作確認： MATLAB R2026a

X = [
    5 5 7 6 7 2;
    6 2 3 2 7 2;
    2 2 4 4 4 6;
    4 4 4 4 1 2
]

szBlk = [2 2];
[m, n] = size(X);
p = m / szBlk(1);  % 行方向ブロック数
q = n / szBlk(2);  % 列方向ブロック数

%% ブロック分割 (2×2 非重複ブロック)
Xb = reshape(X, szBlk(1), p, szBlk(2), q);  % 2 x 2 x 2 x 3
Xb = permute(Xb, [1 3 2 4]);                 % 2 x 2 x 2 x 3
Xb = reshape(Xb, prod(szBlk), p*q);          % 4 x 6
disp('パッチ行列 Xb (各列が 2×2 パッチのベクトル表現):')
disp(Xb)

%% 中心化
mux = mean(Xb, 2)
Xb_ = Xb - mux;

%% パラメータ設定
rng(0)
nDims  = prod(szBlk);   % M = 4
nAtoms = nDims + 1;     % P = M+1 = 5（冗長辞書）
nCoefs = 1;             % K = 1（スパース度）
nIters = 10;            % k-SVD 繰り返し数

%% DCT 基底画像による辞書の初期化（残りはランダム）
basisDct = zeros(szBlk(1), szBlk(2), nDims);
iBasis = 1;
for iRow = 1:szBlk(1)
    for iCol = 1:szBlk(2)
        E = zeros(szBlk);
        E(iRow, iCol) = 1;
        basisDct(:,:,iBasis) = idct2(E);
        iBasis = iBasis + 1;
    end
end
Phi = randn(nDims, nAtoms);
Phi = Phi / norm(Phi, 'fro');
for iAtom = 1:nDims
    Phi(:, iAtom) = reshape(basisDct(:,:,iAtom), nDims, 1);
end
disp('初期辞書 Phi（DCT 基底）:')
disp(Phi)

%% k-SVD の繰り返し
nSamples = size(Xb_, 2);
cost = zeros(1, nIters);
for iIter = 1:nIters
    % スパース近似ステップ（OMP）
    Y = zeros(nAtoms, nSamples);
    for iSample = 1:nSamples
        Y(:, iSample) = omp(Xb_(:, iSample), Phi, nCoefs);
    end
    % 辞書更新ステップ
    for iAtom = 1:nAtoms
        idxset = setdiff(1:nAtoms, iAtom);
        yp     = Y(iAtom, :);
        suppp  = find(yp);
        Epred  = Xb_(:, suppp) - Phi(:, idxset) * Y(idxset, suppp);
        if ~isempty(suppp)
            [U, S, V] = svd(Epred, 'econ');
            Phi(:, iAtom)   = U(:, 1);
            Y(iAtom, suppp) = S(1,1) * V(:, 1).';
        end
    end
    cost(iIter) = norm(Xb_ - Phi * Y, 'fro')^2 / (2 * nSamples);
end

disp('学習後の辞書 Phi:')
disp(Phi)
disp('スパース係数行列 Y（各列がパッチに対応）:')
disp(Y)
fprintf('最終コスト: %.6f\n', cost(end))

%% コスト履歴
figure(1)
plot(cost, '-o')
xlabel('繰り返し回数')
ylabel('コスト')
title('k-SVD コスト履歴')
grid on
drawnow

%% 再構成
Xb_hat = Phi * Y + mux;                      % 中心化の逆写像
Xb_hat = reshape(Xb_hat, szBlk(1), szBlk(2), p, q);
Xb_hat = ipermute(Xb_hat, [1 3 2 4]);
X_hat  = reshape(Xb_hat, m, n)

%% LaTeX 出力
try
    msip.arr2tex(X_hat, "%6.4f")
catch
    disp('(msip.arr2tex はプロジェクト内でのみ利用可能)')
    disp(X_hat)
end

%% OMP 関数（直交マッチング追跡）
function x = omp(y, Phi, nCoefs)
nDims  = size(Phi, 1);
nAtoms = size(Phi, 2);
e = ones(nAtoms, 1);
a = zeros(nAtoms, 1);
g = zeros(nAtoms, 1);
x = zeros(nAtoms, 1);
v = zeros(nDims, 1);
r = y - v;
supp = [];
k = 0;
while k < nCoefs
    rr = r.' * r;
    for m_ = setdiff(1:nAtoms, supp)
        d     = Phi(:, m_);
        g(m_) = d.' * r;
        a(m_) = g(m_) / (d.' * d);
        e(m_) = rr - g(m_) * a(m_);
    end
    [~, mmin] = min(e);
    supp = union(supp, mmin);
    subPhi  = Phi(:, supp);
    x(supp) = subPhi \ y;
    v = Phi * x;
    r = y - v;
    k = k + 1;
end
end
