%[text] # 例1.10（引き戻しと随伴写像）
%[text] 村松正吾　「多次元信号・画像処理の基礎と展開」
%[text] 動作確認： MATLAB R2025b
%[text] ## $2\\times 3$配列の生成
X = rand(2,3) %[output:4b105ac9]

%%
%[text] ## 循環右シフト 
Y = circshift(X,[0 1]) % y = T(x) %[output:435a23a3]

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
T %[output:377c392f]

%%
%[text] ## 線形汎関数 h(y) の引き戻し
H = [-1 0 1; -1 0 1]; 
z1 = dot(H(:),Y(:)); % z = <H,Y> = h(T(x))
disp("h(T(x)) = " + z1) %[output:0a56672e]

%%
%[text] ## 随伴写像
z2 = (T'*H(:))'*X(:); %  z = <T'H,x>
disp("T*(h)(x) = " + z2) %[output:6db0c64b]
%%
%[text] © Copyright, Shogo MURAMATSU, All rights reserved.

%[appendix]{"version":"1.0"}
%---
%[metadata:view]
%   data: {"layout":"onright"}
%---
%[output:4b105ac9]
%   data: {"dataType":"matrix","outputData":{"columns":3,"name":"X","rows":2,"type":"double","value":[["0.7094","0.2760","0.6551"],["0.7547","0.6797","0.1626"]]}}
%---
%[output:435a23a3]
%   data: {"dataType":"matrix","outputData":{"columns":3,"name":"Y","rows":2,"type":"double","value":[["0.6551","0.7094","0.2760"],["0.1626","0.7547","0.6797"]]}}
%---
%[output:377c392f]
%   data: {"dataType":"matrix","outputData":{"columns":6,"name":"T","rows":6,"type":"double","value":[["0","0","0","0","1","0"],["0","0","0","0","0","1"],["1","0","0","0","0","0"],["0","1","0","0","0","0"],["0","0","1","0","0","0"],["0","0","0","1","0","0"]]}}
%---
%[output:0a56672e]
%   data: {"dataType":"text","outputData":{"text":"h(T(x)) = 0.13802\n","truncated":false}}
%---
%[output:6db0c64b]
%   data: {"dataType":"text","outputData":{"text":"T*(h)(x) = 0.13802\n","truncated":false}}
%---
