% 例題7.8 （低ランク近似）
%村松正吾　「多次元信号・画像処理の基礎と展開」
%動作確認： MATLAB R2025b
%準備
import msip.*
X = [
     6     4     6     6     4     4
     6     2     6     4     6     2
     2     2     2     6     6     6
     6     4     6     2     6     6
] % 2*randi(3,4,6)

arr2tex(X,'%d')

% Perform Singular Value Decomposition (SVD) on matrix X
[U, S, V] = svd(X);

arr2tex(U)
arr2tex(S)
arr2tex(V')

norm(X - U*S*V','fro')

thd = S(3,3) 

S2 = (S>thd).*S

X2 = U*S2*V'

arr2tex(X2)

arr2tex(X-X2)

norm(X-X2,'fro')^2


sum(diag(S - S2).^2)