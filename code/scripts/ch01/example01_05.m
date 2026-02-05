%[text] # 例1.5（多次元配列のノルム）
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

%[text] ## 多次元配列のノルムの計算
norm(x(:),2)
norm(y(:),2)

%[appendix]{"version":"1.0"}
%---
%[metadata:view]
%   data: {"layout":"onright"}
%---
