%[text] # 例1.8（線形写像の行列表現）
%[text] 村松正吾　「多次元信号・画像処理の基礎と展開」
%[text] 動作確認： MATLAB R2025b
%[text] ## $2\\times 3$配列の生成
X = rand(2,3)

%%
%[text] ## 循環右シフト
Y = circshift(X,[0 1])

%%
%[text] ## 行列表現
T = [];
for iCol = 1:size(X,2)
    for iRow = 1:size(X,1)
        delta = zeros(size(X));
        delta(iRow,iCol) = 1;
        t = circshift(delta,[0 1]);
        T = [T t(:)];
    end
end
T

%[appendix]{"version":"1.0"}
%---
%[metadata:view]
%   data: {"layout":"onright"}
%---
