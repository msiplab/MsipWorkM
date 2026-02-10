%[text] # 例1.9（スペクトルノルム）
%[text] 村松正吾　「多次元信号・画像処理の基礎と展開」
%[text] 動作確認： MATLAB R2025b
%[text] ## 配列の生成
X = rand(2,3) %[output:3910cf53]

%%
%[text] ## 循環右シフト
Y = circshift(X,[0 1]) %[output:4cf3faea]

%%
%[text] ## 等長性の確認
disp("||T(x)||/||x|| = " + norm(Y(:),2)/norm(X(:),2)) %[output:0e3bf12e]
%%
%[text] © Copyright, Shogo MURAMATSU, All rights reserved.

%[appendix]{"version":"1.0"}
%---
%[metadata:view]
%   data: {"layout":"onright"}
%---
%[output:3910cf53]
%   data: {"dataType":"matrix","outputData":{"columns":3,"name":"X","rows":2,"type":"double","value":[["0.7655","0.1869","0.4456"],["0.7952","0.4898","0.6463"]]}}
%---
%[output:4cf3faea]
%   data: {"dataType":"matrix","outputData":{"columns":3,"name":"Y","rows":2,"type":"double","value":[["0.4456","0.7655","0.1869"],["0.6463","0.7952","0.4898"]]}}
%---
%[output:0e3bf12e]
%   data: {"dataType":"text","outputData":{"text":"||T(x)||\/||x|| = 1\n","truncated":false}}
%---
