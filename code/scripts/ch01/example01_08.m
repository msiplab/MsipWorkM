%[text] # 例1.8（線形写像の行列表現）
%[text] 村松正吾　「多次元信号・画像処理の基礎と展開」
%[text] 動作確認： MATLAB R2025b
%[text] ## $2\\times 3$配列の生成
X = rand(2,3) %[output:08fd16e0]

%%
%[text] ## 循環右シフト
Y = circshift(X,[0 1]) %[output:200ea916]

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
T %[output:32d9b24c]

%[appendix]{"version":"1.0"}
%---
%[metadata:view]
%   data: {"layout":"onright"}
%---
%[output:08fd16e0]
%   data: {"dataType":"matrix","outputData":{"columns":3,"name":"X","rows":2,"type":"double","value":[["0.7922","0.6557","0.8491"],["0.9595","0.0357","0.9340"]]}}
%---
%[output:200ea916]
%   data: {"dataType":"matrix","outputData":{"columns":3,"name":"Y","rows":2,"type":"double","value":[["0.8491","0.7922","0.6557"],["0.9340","0.9595","0.0357"]]}}
%---
%[output:32d9b24c]
%   data: {"dataType":"matrix","outputData":{"columns":6,"name":"T","rows":6,"type":"double","value":[["0","0","0","0","1","0"],["0","0","0","0","0","1"],["1","0","0","0","0","0"],["0","1","0","0","0","0"],["0","0","1","0","0","0"],["0","0","0","1","0","0"]]}}
%---
