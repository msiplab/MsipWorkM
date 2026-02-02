%[text] # 例1.4（ベクトル化）
%[text] 村松正吾　「多次元信号・画像処理の基礎と展開」
%[text] 動作確認： MATLAB R2025b
%[text] ## $2\\times 3$配列の生成
V = rand(2,3)
size(V)
%%
%[text] ## 列ベクトル化
v = V(:)
size(v)
%%
%[text] ## 逆列ベクトル化
U = reshape(v,2,3)
size(U)

%[appendix]{"version":"1.0"}
%---
%[metadata:view]
%   data: {"layout":"onright"}
%---
