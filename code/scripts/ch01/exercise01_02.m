%% 例題1.2（動画像のデータ量）
% 村松正吾　「多次元信号・画像処理の基礎と展開」
% 
% 動作確認： MATLAB R2017a
%% フレームの生成
%%
frame = ones(4320,7680,3,'uint8');
%% 1フレーム当たりの要素数（画素数×色成分数）
%%
nS = numel(frame)
%% 1フレーム当たりのビット数
%%
B = 8*nS
%% ビットレート
%%
deltaT = 1/60;
R = B / deltaT