X = [ 6 5 3 2
    6 5 3 2
    2 3 5 6
    2 3 5 6];

% X: (2*p) x (2*q)
[m,n] = size(X);
p = m/2;
q = n/2;

% 得られる B は 2 x 2 x (p*q)
B = reshape(X, 2, p, 2, q);   % -> 2 x p x 2 x q
B = permute(B, [1 3 2 4]);    % -> 2 x 2 x p x q
B = reshape(B, 2, 2, p*q);    % -> 2 x 2 x (p*q)

% k-means 初期化
c(:,:,1) = 2*ones(2);
c(:,:,2) = 6*ones(2);

for iter = 1:2
    % クラスタリング
    I = cell(1, 2); % Initialize cell array for cluster indices
    for idx = 1:4
        e1 = norm(B(:,:,idx)-c(:,:,1),'fro');
        e2 = norm(B(:,:,idx)-c(:,:,2),'fro');
        if e1 < e2
            I{1} = [I{1} idx];
        else
            I{2} = [I{2} idx];
        end
    end
    I

    % コードベクトルの更新
    c(:,:,1) = mean(B(:,:,I{1}),3)
    c(:,:,2) = mean(B(:,:,I{2}),3)
end

