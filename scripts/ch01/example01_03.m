%% 例1.3（ベクトル化）
% 村松正吾　「多次元信号・画像処理の基礎と展開」
% 
% 動作確認： MATLAB R2017a
%% $2\times 3$配列の生成

V = rand(2,3)
size(V)
%% 列ベクトル化

v = V(:)
size(v)
%% 逆列ベクトル化

U = reshape(v,2,3)
size(U)