%% 例題1.1（線形写像と行列表現）
% 村松正吾　「多次元信号・画像処理の基礎と展開」
% 
% 動作確認： MATLAB R2025a
%% $
%%
N1 = 4320
N2 = 7680
N = N1 * N2

beta = 8

B = 3*beta*N1*N2

Dt = 1/60

format long

R = B/Dt 

