%[text] # 例1.3（静止画像のデータ量）
%[text] 村松正吾　「多次元信号・画像処理の基礎と展開」
%[text] 動作確認： MATLAB R2025b
%[text] ## パラメータ設定
N1 = 2304 %[output:4976b5ae]
N2 = 3456 %[output:303ab174]
N = N1 * N2 %[output:9559e675]

%%
%[text] ## (1) 8ビット符号なし整数型（\\$\\beta=8\\$\[bits\]）のグレースケール画像の場合
beta = 8;
B = beta*N1*N2;
fprintf("8ビット符号なし整数型\n"); %[output:74a9c631]
fprintf(" ビット数 = %d bits\n", B); %[output:32f8fff1]
fprintf(" バイト数 = %d bytes\n", B/8); %[output:9eeaafe6]
I=zeros(N1,N2,'uint8');
dataInfo = whos('I');
disp(dataInfo) %[output:02043ee7]

%%
%[text] ## (2) 倍精度実数型（\\$\\beta=8\\$\[bits\]）のRGB画像の場合
beta = 64;
B = 3*beta*N1*N2;
fprintf("倍精度実数型\n"); %[output:161fe9a8]
fprintf(" ビット数 = %d bits\n", B); %[output:74c39b18]
fprintf(" バイト数 = %d bytes\n", B/8); %[output:44538800]
J=zeros(N1,N2,3,'double');
dataInfo = whos('J');
disp(dataInfo) %[output:2eacf2d5]
%%
%[text] © Copyright, Shogo MURAMATSU, All rights reserved.

%[appendix]{"version":"1.0"}
%---
%[metadata:view]
%   data: {"layout":"onright"}
%---
%[output:4976b5ae]
%   data: {"dataType":"textualVariable","outputData":{"name":"N1","value":"2304"}}
%---
%[output:303ab174]
%   data: {"dataType":"textualVariable","outputData":{"name":"N2","value":"3456"}}
%---
%[output:9559e675]
%   data: {"dataType":"textualVariable","outputData":{"name":"N","value":"7962624"}}
%---
%[output:74a9c631]
%   data: {"dataType":"text","outputData":{"text":"8ビット符号なし整数型\n","truncated":false}}
%---
%[output:32f8fff1]
%   data: {"dataType":"text","outputData":{"text":" ビット数 = 63700992 bits\n","truncated":false}}
%---
%[output:9eeaafe6]
%   data: {"dataType":"text","outputData":{"text":" バイト数 = 7962624 bytes\n","truncated":false}}
%---
%[output:02043ee7]
%   data: {"dataType":"text","outputData":{"text":"          name: 'I'\n          size: [2304 3456]\n         bytes: 7962624\n         class: 'uint8'\n        global: 0\n        sparse: 0\n       complex: 0\n       nesting: [1×1 struct]\n    persistent: 0\n\n","truncated":false}}
%---
%[output:161fe9a8]
%   data: {"dataType":"text","outputData":{"text":"倍精度実数型\n","truncated":false}}
%---
%[output:74c39b18]
%   data: {"dataType":"text","outputData":{"text":" ビット数 = 1528823808 bits\n","truncated":false}}
%---
%[output:44538800]
%   data: {"dataType":"text","outputData":{"text":" バイト数 = 191102976 bytes\n","truncated":false}}
%---
%[output:2eacf2d5]
%   data: {"dataType":"text","outputData":{"text":"          name: 'J'\n          size: [2304 3456 3]\n         bytes: 191102976\n         class: 'double'\n        global: 0\n        sparse: 0\n       complex: 0\n       nesting: [1×1 struct]\n    persistent: 0\n\n","truncated":false}}
%---
