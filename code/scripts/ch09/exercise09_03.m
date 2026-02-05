x1 = [6 5;6 5];
x2 = [2 3;2 3];
x3 = [3 2;3 2];
x4 = [5 6;5 6];

X = [ x1(:) x2(:) x3(:) x4(:)]

mux = mean(X,2)

S =(X-mux)*(X-mux)'/4;
cov(X.',1)

[V,D] = eig(S)
[~,ind] = sort(diag(D),'descend')

Lambda = D(ind,ind)
Phi = V(:,ind)

Phi'*X