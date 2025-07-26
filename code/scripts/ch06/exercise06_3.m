X = [
6 5 3 2
6 5 3 2
2 3 5 6
2 3 5 6
]
C = dctmtx(2)

Y = blockproc(X,[2 2],@(X) C*X.data*C.')


msip.arr2tex(Y)


R = blockproc(Y,[2 2],@(Y) C.'*Y.data*C)

msip.arr2tex(R)

%%
A1 = rand(2)
X  = rand(2)
A2 = rand(2)

Y = A1*X*A2

norm(Y(:)-kron(A2.',A1)*X(:))