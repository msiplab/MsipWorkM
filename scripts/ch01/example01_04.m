%% 例1.4（静止画像のデータ量）
% 村松正吾　「多次元信号・画像処理の基礎と展開」
% 
% 動作確認： MATLAB R2017a
%% (1) 8ビット符号なし整数型（$\beta=8$[bits]）のグレースケール画像の場合

V = ones(2304,3456,'uint8');
dataInfo = whos('V');
disp(dataInfo)
%% (2) 倍精度実数型（$\beta=8$[bits]）のRGB画像の場合

V = ones(2304,3456,3,'double');
dataInfo = whos('V');
disp(dataInfo)