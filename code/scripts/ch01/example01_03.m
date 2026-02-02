%[text] # 例1.3（線形写像と行列表現）
%[text] 村松正吾　「多次元信号・画像処理の基礎と展開」
%[text] 動作確認： MATLAB R2025b
%[text] ## \\$
N1 = 2304
N2 = 3456
N = N1 * N2

%[text] 8ビット符号なし整数型
beta = 8;
B = beta*N1*N2;
fprintf("8ビット符号なし整数型\n");
fprintf(" ビット数 = %d bits\n", B);
fprintf(" バイト数 = %d bytes\n", B/8);
I=zeros(N1,N2,'uint8');
whos I

%[text] 倍精度実数型
beta = 64;
B = 3*beta*N1*N2;
fprintf("倍精度実数型\n");
fprintf(" ビット数 = %d bits\n", B);
fprintf(" バイト数 = %d bytes\n", B/8);
J=zeros(N1,N2,3,'double');
whos J

%[appendix]{"version":"1.0"}
%---
%[metadata:view]
%   data: {"layout":"onright"}
%---
