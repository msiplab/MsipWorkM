%[text] # 例1.2（標準基底による展開）
%[text] 村松正吾　「多次元信号・画像処理の基礎と展開」
%[text] 動作確認： MATLAB R2025b
%[text] ## $2\\times 3$ 配列の生成
V = rand(2,3) %[output:905b218e]
%%
%[text] ## 各配列要素の抽出
v0 = V(1,1) %[output:74b07627]
v1 = V(2,1) %[output:4cbf240a]
v2 = V(1,2) %[output:4ec45bf2]
v3 = V(2,2) %[output:8481c56a]
v4 = V(1,3) %[output:2cc32994]
v5 = V(2,3) %[output:58e17f25]
%%
%[text] ## $2\\times 3$配列の標準基底
B0 = [ 1 0 0 ;  %[output:group:07de2952] %[output:941b3b8c]
       0 0 0 ] %[output:group:07de2952] %[output:941b3b8c]
   
B1 = [ 0 0 0 ;  %[output:group:0a84b0cc] %[output:105ad30c]
       1 0 0 ] %[output:group:0a84b0cc] %[output:105ad30c]
   
B2 = [ 0 1 0 ;  %[output:group:20b26143] %[output:04717f4c]
       0 0 0 ] %[output:group:20b26143] %[output:04717f4c]
   
B3 = [ 0 0 0 ;  %[output:group:7626b6df] %[output:380daf1c]
       0 1 0 ] %[output:group:7626b6df] %[output:380daf1c]
   
B4 = [ 0 0 1 ;  %[output:group:39243442] %[output:2acccb2c]
       0 0 0 ] %[output:group:39243442] %[output:2acccb2c]
   
B5 = [ 0 0 0 ;  %[output:group:7d917a2d] %[output:5c86cf38]
       0 0 1 ] %[output:group:7d917a2d] %[output:5c86cf38]
%%
%[text] ## 標準基底による展開表現
v0*B0 + v2*B2 + v4*B4  ... %[output:group:275044cb] %[output:233c85a1]
    + v1*B1 + v3*B3 + v5*B5 %[output:group:275044cb] %[output:233c85a1]

%[appendix]{"version":"1.0"}
%---
%[metadata:view]
%   data: {"layout":"onright"}
%---
%[output:905b218e]
%   data: {"dataType":"matrix","outputData":{"columns":3,"name":"V","rows":2,"type":"double","value":[["0.8147","0.1270","0.6324"],["0.9058","0.9134","0.0975"]]}}
%---
%[output:74b07627]
%   data: {"dataType":"textualVariable","outputData":{"name":"v0","value":"0.8147"}}
%---
%[output:4cbf240a]
%   data: {"dataType":"textualVariable","outputData":{"name":"v1","value":"0.9058"}}
%---
%[output:4ec45bf2]
%   data: {"dataType":"textualVariable","outputData":{"name":"v2","value":"0.1270"}}
%---
%[output:8481c56a]
%   data: {"dataType":"textualVariable","outputData":{"name":"v3","value":"0.9134"}}
%---
%[output:2cc32994]
%   data: {"dataType":"textualVariable","outputData":{"name":"v4","value":"0.6324"}}
%---
%[output:58e17f25]
%   data: {"dataType":"textualVariable","outputData":{"name":"v5","value":"0.0975"}}
%---
%[output:941b3b8c]
%   data: {"dataType":"matrix","outputData":{"columns":3,"name":"B0","rows":2,"type":"double","value":[["1","0","0"],["0","0","0"]]}}
%---
%[output:105ad30c]
%   data: {"dataType":"matrix","outputData":{"columns":3,"name":"B1","rows":2,"type":"double","value":[["0","0","0"],["1","0","0"]]}}
%---
%[output:04717f4c]
%   data: {"dataType":"matrix","outputData":{"columns":3,"name":"B2","rows":2,"type":"double","value":[["0","1","0"],["0","0","0"]]}}
%---
%[output:380daf1c]
%   data: {"dataType":"matrix","outputData":{"columns":3,"name":"B3","rows":2,"type":"double","value":[["0","0","0"],["0","1","0"]]}}
%---
%[output:2acccb2c]
%   data: {"dataType":"matrix","outputData":{"columns":3,"name":"B4","rows":2,"type":"double","value":[["0","0","1"],["0","0","0"]]}}
%---
%[output:5c86cf38]
%   data: {"dataType":"matrix","outputData":{"columns":3,"name":"B5","rows":2,"type":"double","value":[["0","0","0"],["0","0","1"]]}}
%---
%[output:233c85a1]
%   data: {"dataType":"matrix","outputData":{"columns":3,"name":"ans","rows":2,"type":"double","value":[["0.8147","0.1270","0.6324"],["0.9058","0.9134","0.0975"]]}}
%---
