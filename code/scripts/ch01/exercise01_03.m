%[text] # 例題1.3（線形写像と行列表現）
%[text] 村松正吾　「多次元信号・画像処理の基礎と展開」
%[text] 動作確認： MATLAB R2025aa
%[text] ## $2\\times 3$行列の生成
V = rand(2,3) %[output:734697b8]
%%
%[text] ## 巡回シフト
m = [0 1]; % シフト量
U = circshift(V,m) %[output:9d92d2fb]
%%
%[text] ## $2\\times 3$配列の標準基底
B0 = [ 1 0 0 ;  %[output:group:9155b8f1] %[output:226b0814]
       0 0 0 ] %[output:group:9155b8f1] %[output:226b0814]
   
B1 = [ 0 0 0 ;  %[output:group:2b7f7e5e] %[output:880a1f32]
       1 0 0 ] %[output:group:2b7f7e5e] %[output:880a1f32]
   
B2 = [ 0 1 0 ;  %[output:group:4637a95c] %[output:0cd1f8b4]
       0 0 0 ] %[output:group:4637a95c] %[output:0cd1f8b4]
   
B3 = [ 0 0 0 ;  %[output:group:862f7151] %[output:35aebdc8]
       0 1 0 ] %[output:group:862f7151] %[output:35aebdc8]
   
B4 = [ 0 0 1 ;  %[output:group:56338a53] %[output:120d5f0b]
       0 0 0 ] %[output:group:56338a53] %[output:120d5f0b]
   
B5 = [ 0 0 0 ;  %[output:group:66555ed8] %[output:6408646d]
       0 0 1 ] %[output:group:66555ed8] %[output:6408646d]
%%
%[text] ## 標準基底配列に対する巡回シフトの結果
U0 = circshift(B0,m) %[output:2960d07a]
U1 = circshift(B1,m) %[output:060db6c4]
U2 = circshift(B2,m) %[output:46abf3c9]
U3 = circshift(B3,m) %[output:963c3101]
U4 = circshift(B4,m) %[output:94f731b5]
U5 = circshift(B5,m) %[output:0006ffc0]
%%
%[text] ## 巡回シフトの行列表現
t0 = U0(:);
t1 = U1(:);
t2 = U2(:);
t3 = U3(:);
t4 = U4(:);
t5 = U5(:);
T = [ t0 t1 t2 t3 t4 t5 ] %[output:37d84cd9]
%%
%[text] ## 行列演算による巡回シフト
v = V(:);
u = T*v;
reshape(u,2,3) %[output:741b3bd9]
%%
%[text] © Copyright, Shogo MURAMATSU, All rights reserved.

%[appendix]{"version":"1.0"}
%---
%[metadata:view]
%   data: {"layout":"onright"}
%---
%[output:734697b8]
%   data: {"dataType":"matrix","outputData":{"columns":3,"name":"V","rows":2,"type":"double","value":[["0.2785","0.9575","0.1576"],["0.5469","0.9649","0.9706"]]}}
%---
%[output:9d92d2fb]
%   data: {"dataType":"matrix","outputData":{"columns":3,"name":"U","rows":2,"type":"double","value":[["0.1576","0.2785","0.9575"],["0.9706","0.5469","0.9649"]]}}
%---
%[output:226b0814]
%   data: {"dataType":"matrix","outputData":{"columns":3,"name":"B0","rows":2,"type":"double","value":[["1","0","0"],["0","0","0"]]}}
%---
%[output:880a1f32]
%   data: {"dataType":"matrix","outputData":{"columns":3,"name":"B1","rows":2,"type":"double","value":[["0","0","0"],["1","0","0"]]}}
%---
%[output:0cd1f8b4]
%   data: {"dataType":"matrix","outputData":{"columns":3,"name":"B2","rows":2,"type":"double","value":[["0","1","0"],["0","0","0"]]}}
%---
%[output:35aebdc8]
%   data: {"dataType":"matrix","outputData":{"columns":3,"name":"B3","rows":2,"type":"double","value":[["0","0","0"],["0","1","0"]]}}
%---
%[output:120d5f0b]
%   data: {"dataType":"matrix","outputData":{"columns":3,"name":"B4","rows":2,"type":"double","value":[["0","0","1"],["0","0","0"]]}}
%---
%[output:6408646d]
%   data: {"dataType":"matrix","outputData":{"columns":3,"name":"B5","rows":2,"type":"double","value":[["0","0","0"],["0","0","1"]]}}
%---
%[output:2960d07a]
%   data: {"dataType":"matrix","outputData":{"columns":3,"name":"U0","rows":2,"type":"double","value":[["0","1","0"],["0","0","0"]]}}
%---
%[output:060db6c4]
%   data: {"dataType":"matrix","outputData":{"columns":3,"name":"U1","rows":2,"type":"double","value":[["0","0","0"],["0","1","0"]]}}
%---
%[output:46abf3c9]
%   data: {"dataType":"matrix","outputData":{"columns":3,"name":"U2","rows":2,"type":"double","value":[["0","0","1"],["0","0","0"]]}}
%---
%[output:963c3101]
%   data: {"dataType":"matrix","outputData":{"columns":3,"name":"U3","rows":2,"type":"double","value":[["0","0","0"],["0","0","1"]]}}
%---
%[output:94f731b5]
%   data: {"dataType":"matrix","outputData":{"columns":3,"name":"U4","rows":2,"type":"double","value":[["1","0","0"],["0","0","0"]]}}
%---
%[output:0006ffc0]
%   data: {"dataType":"matrix","outputData":{"columns":3,"name":"U5","rows":2,"type":"double","value":[["0","0","0"],["1","0","0"]]}}
%---
%[output:37d84cd9]
%   data: {"dataType":"matrix","outputData":{"columns":6,"name":"T","rows":6,"type":"double","value":[["0","0","0","0","1","0"],["0","0","0","0","0","1"],["1","0","0","0","0","0"],["0","1","0","0","0","0"],["0","0","1","0","0","0"],["0","0","0","1","0","0"]]}}
%---
%[output:741b3bd9]
%   data: {"dataType":"matrix","outputData":{"columns":3,"name":"ans","rows":2,"type":"double","value":[["0.1576","0.2785","0.9575"],["0.9706","0.5469","0.9649"]]}}
%---
