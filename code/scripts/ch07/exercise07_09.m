% 例題7.8 （固有直交分解）
%村松正吾　「多次元信号・画像処理の基礎と展開」
%動作確認： MATLAB R2025b
%準備
import msip.*
x(:,:,1) = [
    2 0
    1 1]
x(:,:,2) = [
    1 2 
    0 1 ]
x(:,:,3)  = [
    1 1
    2 0]
x(:,:,4) = [
    0 1
    1 2 ]

X = reshape(x,[],size(x,3))

arr2tex(X,'%d')

% Perform Singular Value Decomposition (SVD) on matrix X
[U, S, V] = svd(X);

arr2tex(-U)
arr2tex(S)
arr2tex(-V')

u = reshape(-U,size(x))

S = (S>S(3,3)).*S

X2 = U*S*V'

x2 = reshape(X2,size(x))
