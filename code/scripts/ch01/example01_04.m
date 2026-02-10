%[text] # 例1.4（多次元配列の内積）
%[text] 村松正吾　「多次元信号・画像処理の基礎と展開」
%[text] 動作確認： MATLAB R2025b
%[text] ## 配列の設定

x = [
    3 5 7
    7 8 0
    ];

y = [
    5 -2 -5
    1 -5 1
    ];

%[text] ## 多次元配列の内積の計算
dot(x(:),y(:)) %[output:1c434c31]

%[appendix]{"version":"1.0"}
%---
%[metadata:view]
%   data: {"layout":"onright"}
%---
%[output:1c434c31]
%   data: {"dataType":"textualVariable","outputData":{"name":"ans","value":"-63"}}
%---
