%[text] # 例題1.1（動画像のビットレート）
%[text] 村松正吾　「多次元信号・画像処理の基礎と展開」
%[text] 動作確認： MATLAB R2025b
%[text] ## フレームの生成
frame = ones(4320,7680,3,'uint8');
%%
%[text] ## 1フレーム当たりの要素数（画素数×色成分数）
nS = numel(frame) %[output:53eb58fe]
%%
%[text] ## 1フレーム当たりのビット数
B = 8*nS %[output:7bc5b52e]
%%
%[text] ## ビットレート
deltaT = 1/60;
R = B / deltaT %[output:7cc613d3]
%%
%[text] © Copyright, Shogo MURAMATSU, All rights reserved.

%[appendix]{"version":"1.0"}
%---
%[metadata:view]
%   data: {"layout":"onright"}
%---
%[output:53eb58fe]
%   data: {"dataType":"textualVariable","outputData":{"name":"nS","value":"99532800"}}
%---
%[output:7bc5b52e]
%   data: {"dataType":"textualVariable","outputData":{"name":"B","value":"796262400"}}
%---
%[output:7cc613d3]
%   data: {"dataType":"textualVariable","outputData":{"name":"R","value":"4.7776e+10"}}
%---
