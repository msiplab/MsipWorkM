%[text] # 例1.7（列ベクトル化）
%[text] 村松正吾　「多次元信号・画像処理の基礎と展開」
%[text] 動作確認： MATLAB R2025b
%[text] ## $2\\times 3$配列の生成
V = rand(2,3) %[output:9c538a63]
size(V) %[output:9384d7db]
%%
%[text] ## 列ベクトル化
v = V(:) %[output:5f0c3c65]
size(v) %[output:11ebf28b]
%%
%[text] ## 逆列ベクトル化
U = reshape(v,2,3) %[output:0e55eb9e]
size(U) %[output:7fa371a1]

%[appendix]{"version":"1.0"}
%---
%[metadata:view]
%   data: {"layout":"onright"}
%---
%[output:9c538a63]
%   data: {"dataType":"matrix","outputData":{"columns":3,"name":"V","rows":2,"type":"double","value":[["0.9572","0.8003","0.4218"],["0.4854","0.1419","0.9157"]]}}
%---
%[output:9384d7db]
%   data: {"dataType":"matrix","outputData":{"columns":2,"name":"ans","rows":1,"type":"double","value":[["2","3"]]}}
%---
%[output:5f0c3c65]
%   data: {"dataType":"matrix","outputData":{"columns":1,"name":"v","rows":6,"type":"double","value":[["0.9572"],["0.4854"],["0.8003"],["0.1419"],["0.4218"],["0.9157"]]}}
%---
%[output:11ebf28b]
%   data: {"dataType":"matrix","outputData":{"columns":2,"name":"ans","rows":1,"type":"double","value":[["6","1"]]}}
%---
%[output:0e55eb9e]
%   data: {"dataType":"matrix","outputData":{"columns":3,"name":"U","rows":2,"type":"double","value":[["0.9572","0.8003","0.4218"],["0.4854","0.1419","0.9157"]]}}
%---
%[output:7fa371a1]
%   data: {"dataType":"matrix","outputData":{"columns":2,"name":"ans","rows":1,"type":"double","value":[["2","3"]]}}
%---
