%% 例題1.1（線形写像と行列表現）
% 村松正吾　「多次元信号・画像処理の基礎と展開」
% 
% 動作確認： MATLAB R2017a
%% $2\times 3$行列の生成
%%
V = rand(2,3)
%% 巡回シフト
%%
m = [0 1]; % シフト量
U = circshift(V,m)
%% $2\times 3$配列の標準基底
%%
B0 = [ 1 0 0 ; 
       0 0 0 ]
   
B1 = [ 0 0 0 ; 
       1 0 0 ]
   
B2 = [ 0 1 0 ; 
       0 0 0 ]
   
B3 = [ 0 0 0 ; 
       0 1 0 ]
   
B4 = [ 0 0 1 ; 
       0 0 0 ]
   
B5 = [ 0 0 0 ; 
       0 0 1 ]
%% 標準基底配列に対する巡回シフトの結果
%%
U0 = circshift(B0,m)
U1 = circshift(B1,m)
U2 = circshift(B2,m)
U3 = circshift(B3,m)
U4 = circshift(B4,m)
U5 = circshift(B5,m)
%% 巡回シフトの行列表現
%%
t0 = U0(:);
t1 = U1(:);
t2 = U2(:);
t3 = U3(:);
t4 = U4(:);
t5 = U5(:);
T = [ t0 t1 t2 t3 t4 t5 ]
%% 行列演算による巡回シフト
%%
v = V(:);
u = T*v;
reshape(u,2,3)