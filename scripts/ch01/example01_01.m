%% ��1.1�i�z��\���j
% ��������@�u�������M���E�摜�����̊�b�ƓW�J�v
% 
% ����m�F�F MATLAB R2017a
%% �摜�f�[�^�̃_�E�����[�h
%%
isVerbose = false;
msip.download_img(isVerbose)
%% (a) �O���[�X�P�[���摜
%%
fprintf('(a) �O���[�X�P�[���摜\n')
V = imread('./data/barbara.png');
fprintf('�z�񎟌��F D = %d\n',ndims(V))
imshow(V)
%% (b) RGB�摜
%%
fprintf('(b) RGB�摜\n')
V = imread('./data/lena.png');
fprintf('�z�񎟌��F D = %d\n',ndims(V))
imshow(V)
%% (c) ���摜
%%
fprintf('(c) RGB���摜\n')
vrObj = VideoReader('shuttle.avi');
V = zeros(vrObj.Height,vrObj.Width,3,2,'uint8');
V(:,:,:,1) = readFrame(vrObj);
V(:,:,:,2) = readFrame(vrObj);
fprintf('�z�񎟌��F D = %d\n',ndims(V))
imshow(V(:,:,:,1))
title('��0�t���[��')
imshow(V(:,:,:,2))
title('��1�t���[��')
%% (d) �{�����[���f�[�f�[�^
%%
fprintf('(d) �{�����[���f�[�^\n')
load mri
V = squeeze(D);
fprintf('�z�񎟌��F D = %d\n',ndims(V))
imshow(V(:,:,1))
title('��0�X���C�X(xy)')
imshow(V(:,:,2))
title('��1�X���C�X(xy)')