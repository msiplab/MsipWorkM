%% 例題2.5（ヒストグラム均等化）
% 村松正吾　「多次元信号・画像処理の基礎と展開」
% 
% 動作確認： MATLAB R2025b

v = [
    2 2 3 1 2 4 1 1
    3 4 4 3 2 3 4 2
    4 4 4 3 4 5 5 4
    0 4 6 4 2 3 4 2
    2 2 2 3 5 1 3 3
    2 1 4 3 4 1 6 0
]

figure(1)
h = histogram(v(:), 0:7);
hv = zeros(1,8);
hv(1:length(h.Values)) = h.Values

pv = hv / numel(v);
cv = cumsum(pv)

round(cv * 7)

phi = dictionary(h.BinEdges, round(cv * 7))

u = phi(v)

msip.arr2tex(u,"%d")

figure(2)
histogram(u(:), 0:7)

