%[text] # 例1.6（多次元配列の関係性）
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

%[text] ## 多次元配列の距離
norm(x(:)-y(:),2) %[output:737e792b]

%[text] ## 多次元配列のコサイン類似度
dot(x(:),y(:)) / (norm(x(:),2)*norm(y(:),2)) %[output:9d630948]
%%
%[text] © Copyright, Shogo MURAMATSU, All rights reserved.

%[appendix]{"version":"1.0"}
%---
%[metadata:view]
%   data: {"layout":"onright"}
%---
%[output:737e792b]
%   data: {"dataType":"textualVariable","outputData":{"name":"ans","value":"20.0749"}}
%---
%[output:9d630948]
%   data: {"dataType":"textualVariable","outputData":{"name":"ans","value":"-0.5000"}}
%---
