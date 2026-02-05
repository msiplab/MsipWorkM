%[text] # 例1.9（スペクトルノルム）
%[text] 村松正吾　「多次元信号・画像処理の基礎と展開」
%[text] 動作確認： MATLAB R2025b
%[text] ## $2\\times 3$配列の生成
X = rand(2,3)

%%
%[text] ## 循環右シフト
Y = circshift(X,[0 1])

%%
%[text] ## 等長性の確認
disp("||T(x)||/||x|| = " + norm(Y(:),2)/norm(X(:),2))

%[appendix]{"version":"1.0"}
%---
%[metadata:view]
%   data: {"layout":"onright"}
%---
