%%
close all

%%
% 補間核
figure(1)
fmesh(@(x,y) eta(y,x),[-2 2 -2 2])
R = @(theta) [cos(theta) -sin(theta); sin(theta) cos(theta)]; 

%%
% 原画像
X = imresize(im2double(imread('cameraman.tif')),[96 96],'bilinear');
figure(2)
imshow(X)
title(num2str(size(X)))

%%
% 拡大縮小 
P = diag([0.5 2.5]);
Y = myresample(X,P);
figure
imshow(Y)
title(num2str(size(Y)))

%%
% 鏡映
P = diag([1 -1]);
Y = myresample(X,P);
figure
imshow(Y)
title(num2str(size(Y)))

% 回転
theta = pi/6;
P = R(theta);
Y = myresample(X,P);
figure
imshow(Y)
title(num2str(size(Y)))

%%
% せん断
% 鏡映
theta = pi/6;
P = eye(2) + tan(theta)*[0 1; 0 0];
Y = myresample(X,P);
figure
imshow(Y)
title(num2str(size(Y)))

% 回転
theta = pi/6;
P = eye(2) + tan(theta)*[0 0; 1 0]; 
Y = myresample(X,P);
figure
imshow(Y)
title(num2str(size(Y)))

%%
% 並進
H = [1 0 -48; 0 1 -48; 0 0 1]
Y = myproj(X,H);
figure
imshow(Y)
title(num2str(size(Y)))

% アフィン変換
theta = pi/6;
H = [1 0 -48; 0 1 -48; 0 0 1];
H(1:2,1:2) = R(theta);
Y = myproj(X,H);
figure
imshow(Y)
title(num2str(size(Y)))

% 射影変換
theta = pi/6;
H = eye(3);
H(1:2,1:2) = R(theta);
H(1:2,3) = [0;0];
H(3,:) = [1/400 1/200 1];
H = [1 0 48; 0 1 48; 0 0 1/0.64]*H*[1 0 -48; 0 1 -48; 0 0 1]
Y = myproj(X,H);
figure
imshow(Y)
title(num2str(size(Y)))

%%
% 再標本化関数
function y = myresample(x,P)
szX = size(x);
p = P*[0 0 szX(1) szX(1);0 szX(2) 0 szX(2)];
pvmin = min(p(1,:));
pvmax = max(p(1,:));
phmin = min(p(2,:));
phmax = max(p(2,:));
nRows = floor(pvmax - pvmin + 1);
nCols = floor(phmax - phmin + 1);
y = zeros(nRows, nCols); % Initialize the output array
size(y)
%
[mh,mv] = meshgrid(0:size(x,2)-1,0:size(x,1)-1);
nh = 1;
for ph = phmin:phmax
    nv = 1;
    for pv = pvmin:pvmax
        c = P\[pv;ph];
        qv = c(1) - mv;
        qh = c(2) - mh;
        y(nv,nh) = sum(x.*eta(qv,qh),'all');
        %
        nv = nv + 1;
    end
    nh = nh + 1;
end
end

% 射影変換
function y = myproj(x,H)
szX = size(x);
p = H*[0 0 szX(1) szX(1);0 szX(2) 0 szX(2); 1 1 1 1];
pvmin = min(p(1,:)./p(3,:));
pvmax = max(p(1,:)./p(3,:));
phmin = min(p(2,:)./p(3,:));
phmax = max(p(2,:)./p(3,:));
nRows = floor(pvmax - pvmin + 1);
nCols = floor(phmax - phmin + 1);
y = zeros(nRows, nCols); % Initialize the output array
size(y)
%
[mh,mv] = meshgrid(0:size(x,2)-1,0:size(x,1)-1);
nh = 1;
for ph = phmin:phmax
    nv = 1;
    for pv = pvmin:pvmax
        q = H\[pv;ph;1];
        c = q(1:2)/q(3);
        qv = c(1) - mv;
        qh = c(2) - mh;
        y(nv,nh) = sum(x.*eta(qv,qh),'all');
        %
        nv = nv + 1;
    end
    nh = nh + 1;
end
end
% 補間核
function y = eta(qv,qh)
yv = max(0,qv+1) - 2*max(0,qv) + max(0,qv-1);
yh = max(0,qh+1) - 2*max(0,qh) + max(0,qh-1);
y = yv.*yh;
end