%% á1.5i³kj
% º¼³á@u½³MEæÌîbÆWJv
% 
% ®ìmFF MATLAB R2017a
%% æf[^Ì_E[h
%%
isVerbose = false;
msip.download_img(isVerbose)
%% æf[^ÌÇ
%%
V = imread('./data/barbara.png');
%% ³kOÌf[^Ê
%%
dataInfo = whos('V');
fprintf('³kOÌoCgF %d [Bytes]\n',dataInfo.bytes)
fprintf('³kOÌrbgF %6.2f [bpp]\n',8*dataInfo.bytes/prod(dataInfo.size))
%% ³kOÌæ\¦
%%
figure(1)
imshow(V)
title('´æ')
%% JPEG³k
%%
qFactor = 50; % i¿§ä [0,100]
imwrite(V,'./data/barbara.jpg','Quality',qFactor)
%% ³kãÌf[^Ê
%%
fileInfo = dir('./data/barbara.jpg');
fprintf('³kãÌoCgF %d [Bytes]\n',fileInfo.bytes)
fprintf('³kãÌrbgF %6.2f [bpp]\n',8*fileInfo.bytes/prod(dataInfo.size))
%% ³kãÌæ\¦
%%
U = imread('./data/barbara.jpg');
figure(2)
imshow(U)
title('JPEG³kæ')
%% ³kOãÌ·ªæ\¦
%%
Y = imadjust(imabsdiff(U,V));
figure(3)
imshow(Y)
title('·ªæ')
%% s[NMÎG¹äÉæéë·]¿
%%
fprintf('PSNR:  %6.2f [dB]\n',psnr(V,U))