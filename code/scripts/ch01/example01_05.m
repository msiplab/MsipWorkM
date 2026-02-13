%[text] # 例1.5（多次元配列のノルム）
%[text] 村松正吾　「多次元信号・画像処理の基礎と展開」
%[text] 動作確認： MATLAB R2025b
%[text] ## 配列の設定

x = [
    7 5 3 %3 5 7
    3 2 2%7 8 0
    ];

y = [
    -4 9 6 %5 -2 -5
    7 5 7 %1 -5 1
    ];

%[text] ## 多次元配列のノルムの計算
norm(x(:),2) %[output:7cac075c]
norm(y(:),2) %[output:042d4ebe]
%%
%[text] © Copyright, Shogo MURAMATSU, All rights reserved.

%[appendix]{"version":"1.0"}
%---
%[metadata:view]
%   data: {"layout":"onright"}
%---
%[output:7cac075c]
%   data: {"dataType":"textualVariable","outputData":{"name":"ans","value":"14"}}
%---
%[output:042d4ebe]
%   data: {"dataType":"textualVariable","outputData":{"name":"ans","value":"9"}}
%---
