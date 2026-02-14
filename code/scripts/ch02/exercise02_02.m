%% 例題2.2（標準化と最小最大正規化）
% 村松正吾　「多次元信号・画像処理の基礎と展開」
% 
% 動作確認： MATLAB R2024b

v = [
5     5     7     6     7     2
6     2     3     2     7     2
2     1     5     4     4     6
5     4     2     5     1     2
]

%% 標準化
mu = mean(v(:))
sigma2 = var(v(:))

u = (v - mu) / sqrt(sigma2)

msip.arr2tex(u)

%% 正規化
vmin = min(v(:))
vmax = max(v(:))

u = (v - vmin) / (vmax - vmin)

msip.arr2tex(u)

