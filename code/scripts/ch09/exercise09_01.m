%% 例題9.1（k-平均値法）
% 村松正吾　「多次元信号・画像処理の基礎と展開」
% 
% 動作確認： MATLAB R2026a
X= [
    5.0000    5.0000    7.0000    6.0000    7.0000    2.0000
    6.0000    2.0000    3.0000    2.0000    7.0000    2.0000
    2.0000    2.0000    4.0000    4.0000    4.0000    6.0000
    4.0000    4.0000    4.0000    4.0000    1.0000    2.0000
  ]
% サイズとブロック数
[m,n] = size(X);
p = m/2;
q = n/2;

% 得られる B は 2 x 2 x (p*q)
Xb = reshape(X, 2, p, 2, q);   % -> 2 x p x 2 x q
Xb = permute(Xb, [1 3 2 4]);   % -> 2 x 2 x p x q
Xb = reshape(Xb, 2, 2, p*q);   % -> 2 x 2 x (p*q)

% k-means 初期化
c(:,:,1) = min(X(:))*ones(2)
c(:,:,2) = max(X(:))*ones(2)

nIter = 5;
B=size(Xb,3);

for iter = 1:nIter
    % クラスタリング
    I = cell(1, 2); % Initialize cell array for cluster indices
    for idx = 1:B
        e1 = norm(Xb(:,:,idx)-c(:,:,1),'fro');
        e2 = norm(Xb(:,:,idx)-c(:,:,2),'fro');
        if e1 <= e2
            I{1} = [I{1} idx];
        else
            I{2} = [I{2} idx];
        end
    end
    I

    % コードベクトルの更新
    c(:,:,1) = mean(Xb(:,:,I{1}),3);
    c(:,:,2) = mean(Xb(:,:,I{2}),3);
end
c

for icls = 1:2
    for idx = I{icls}
        Yb(:,:,idx) = c(:,:,icls);
    end
end
Yb = reshape(Yb,2,2,p,q);
Yb = ipermute(Yb,[1 3 2 4]);
Y = reshape(Yb,2*p,2*q);

msip.arr2tex(Y,"%4.1f")