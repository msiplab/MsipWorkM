%[text] # 例1.4（多次元配列の内積）
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

%[text] ## 多次元配列の内積の計算
dot(x(:),y(:)) %[output:1c434c31]
%%
%[text] © Copyright, Shogo MURAMATSU, All rights reserved.

%[appendix]{"version":"1.0"}
%---
%[metadata:view]
%   data: {"layout":"onright"}
%---
%[output:1c434c31]
%   data: {"dataType":"textualVariable","outputData":{"name":"ans","value":"-63"}}
%---
