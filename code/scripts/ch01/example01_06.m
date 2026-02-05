%[text] # 例1.6（多次元配列の関係性）
%[text] 村松正吾　「多次元信号・画像処理の基礎と展開」
%[text] 動作確認： MATLAB R2025b
%[text] ## \\$

x = [
    3 5 7
    7 8 0
    ];

y = [
    5 -2 -5
    1 -5 1
    ];

%[text] ## 多次元配列の距離
norm(x(:)-y(:),2)

%[text] ## 多次元配列のコサイン類似度
dot(x(:),y(:)) / (norm(x(:),2)*norm(y(:),2))

%[appendix]{"version":"1.0"}
%---
%[metadata:view]
%   data: {"layout":"onright"}
%---
