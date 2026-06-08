%% 例題9.1（k-平均値法）
% 村松正吾　「多次元信号・画像処理の基礎と展開」
% 
% 動作確認： MATLAB R2026a
X= [
    5.0000    5.0000    7.0000    6.0000    7.0000    2.0000
    6.0000    2.0000    3.0000    2.0000    7.0000    2.0000
    2.0000    2.0000    4.0000    4.0000    4.0000    6.0000
    4.0000    4.0000    4.0000    4.0000    1.0000    2.0000
  ]

% サイズとブロック数
[m,n] = size(X);
p = m/2;
q = n/2;

% 得られる B は 2 x 2 x (p*q)
Xb = reshape(X, 2, p, 2, q);   % -> 2 x p x 2 x q
Xb = permute(Xb, [1 3 2 4]);   % -> 2 x 2 x p x q
Xb = reshape(Xb, 2*2, p*q);   % -> (2*2) x (p*q)

mux = mean(Xb,2);
msip.arr2tex(mux.',"%4.2f")

S =(Xb-mux)*(Xb-mux)'/(p*q)
msip.arr2tex(cov(Xb.',1),"%4.2f")

[V,D] = eig(S);
[Lamda,ind] = sort(diag(D),'descend')

Phi = V(:,ind);

msip.arr2tex(reshape(Phi(:,1),2,2),"%4.2f")
msip.arr2tex(reshape(Phi(:,2),2,2),"%4.2f")

Cb = Phi'*(Xb-mux); 
Yb = Phi(:,1:2)*Cb(1:2,:)+mux; % ゾーン符号化
Yb = reshape(Yb,2,2,p,q);
Yb = ipermute(Yb, [1 3 2 4]);
Y  = reshape(Yb, m, n);

msip.arr2tex(Y,"%4.2f")

