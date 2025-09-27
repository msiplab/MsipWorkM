%[text] # 例題1.2（動画像のデータ量）
%[text] 村松正吾　「多次元信号・画像処理の基礎と展開」
%[text] 動作確認： MATLAB R2017a
%[text] ## フレームの生成
frame = ones(4320,7680,3,'uint8');
%%
%[text] ## 1フレーム当たりの要素数（画素数×色成分数）
nS = numel(frame)
%%
%[text] ## 1フレーム当たりのビット数
B = 8*nS
%%
%[text] ## ビットレート
deltaT = 1/60;
R = B / deltaT

%[appendix]{"version":"1.0"}
%---
%[metadata:view]
%   data: {"layout":"onright"}
%---
