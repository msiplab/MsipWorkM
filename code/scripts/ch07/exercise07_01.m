% 4点DCT行列の生成
C4 = dctmtx(4)

C4.'*C4
%X = [6 5 3 2; 
 %    6 5 3 2; 
     %2 3 5 6; 
     %2 3 5 6]

X = [4 4 6 4; 
     4 6 4 2; 
     6 4 2 4; 
     4 2 4 4]


Y = C4 * X * C4.'

msip.arr2tex(Y)

%%

Yaprx = Z.*Y;

msip.arr2tex(Yaprx)

%%

Xaprx = C4.'*Yaprx*C4;

msip.arr2tex(Xaprx)

%%

%Xhat = round(Xaprx);

%msip.arr2tex(Xhat,"%d")

%%

msip.arr2tex(X-Xaprx)
