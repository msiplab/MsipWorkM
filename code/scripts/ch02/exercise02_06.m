%% 例題2.6（大津法）
% 村松正吾　「多次元信号・画像処理の基礎と展開」
% 
% 動作確認： MATLAB R2025b

v = [
    2 2 3 1 2 4 1 1
    3 4 4 3 2 3 4 2
    4 4 4 3 4 5 5 4
    0 4 6 4 2 3 4 2
    2 2 2 3 5 1 3 3
    2 1 4 3 4 1 6 0
]



%% New

figure(1)
[H,edges] = histcounts(v(:),-0.5:1:7.5);
histogram(v,edges);
disp(H)
n0 = zeros(1,7);
n1 = zeros(1,7);
mu0 = nan(1,7);
mu1 = sum((0:7).*H)/numel(v);
sb2 = nan(1,7);

N = numel(v);
n0(1) = 0; 
n1(1) = N;
c0 = 0;
c1 = (0:7)*H(1:8).';
for t=1:7
    idx = t+1;
    n0(idx) = n0(idx-1)+H(idx-1);
    n1(idx) = N - n0(idx);
    c0 = c0 + (t-1)*H(idx-1);
    c1 = c1 - (t-1)*H(idx-1);
    mu0(idx) = c0/n0(idx);
    mu1(idx) = c1/n1(idx);
    sb2(idx) = n0(idx)*n1(idx)*(mu0(idx)-mu1(idx))^2/N^2;
end
import msip.arr2tex
disp(arr2tex(n0,"%d"))
disp(arr2tex(n1,"%d"))
disp(arr2tex(mu0,"%6.2f"))
disp(arr2tex(mu1,"%6.2f"))
disp(arr2tex(sb2,"%6.2f"))
%plot(0:6,sb2)

[~,idx] = max(sb2);
T = idx-1;
disp(['T = ' num2str(T) ]); 
    
YY = zeros(size(v));
YY(v>=T) = 1;
disp(arr2tex(YY,"%d"))

figure(2)
imshow(imresize(v/7,8))
figure(6)
imshow(imresize(YY,8))