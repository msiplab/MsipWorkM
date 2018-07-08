%% ��1.5�i���k�����j
% ��������@�u�������M���E�摜�����̊�b�ƓW�J�v
% 
% ����m�F�F MATLAB R2017a
%% �摜�f�[�^�̃_�E�����[�h
%%
isVerbose = false;
msip.download_img(isVerbose)
%% �摜�f�[�^�̓Ǎ�
%%
V = imread('./data/barbara.png');
%% ���k�O�̃f�[�^��
%%
dataInfo = whos('V');
fprintf('���k�O�̃o�C�g���F %d [Bytes]\n',dataInfo.bytes)
fprintf('���k�O�̃r�b�g���F %6.2f [bpp]\n',8*dataInfo.bytes/prod(dataInfo.size))
%% ���k�O�̉摜�\��
%%
figure(1)
imshow(V)
title('���摜')
%% JPEG���k
%%
qFactor = 50; % �i������ [0,100]
imwrite(V,'./data/barbara.jpg','Quality',qFactor)
%% ���k��̃f�[�^��
%%
fileInfo = dir('./data/barbara.jpg');
fprintf('���k��̃o�C�g���F %d [Bytes]\n',fileInfo.bytes)
fprintf('���k��̃r�b�g���F %6.2f [bpp]\n',8*fileInfo.bytes/prod(dataInfo.size))
%% ���k��̉摜�\��
%%
U = imread('./data/barbara.jpg');
figure(2)
imshow(U)
title('JPEG���k�摜')
%% ���k�O��̍����摜�\��
%%
Y = imadjust(imabsdiff(U,V));
figure(3)
imshow(Y)
title('�����摜')
%% �s�[�N�M���ΎG����ɂ��덷�]��
%%
fprintf('PSNR:  %6.2f [dB]\n',psnr(V,U))