%%
%X = [
%6 5 3 2 
%6 5 3 2
%2 3 5 6
%2 3 5 6
%]
X= [
  5  5  7  6  7  2;
  6  2  3  2  7  2;
  2  1  5  4  4  6;
  5  4  2  5  1  2;
  ]
C = dctmtx(2)

Y = blockproc(X,[2 2],@(X) C*X.data*C.')


msip.arr2tex(Y,"%.1f")


R = blockproc(Y,[2 2],@(Y) C.'*Y.data*C)

msip.arr2tex(R,"%.0f")

%%
A1 = rand(2)
X  = rand(2)
A2 = rand(2)

Y = A1*X*A2

norm(Y(:)-kron(A2.',A1)*X(:))