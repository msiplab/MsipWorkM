%% MATLAB�X�N���v�g���烉�C�u�X�N���v�g�ւ̕ϊ�
%
% Copyright (c) Shogo MURAMATSU, 2018
% All rights resereved

srcDir = './scripts/ch01/';
dstDir = fullfile(pwd,'/livescripts/ch01/');
isVerbose = true;
%% �t�@�C���̎w��
%%
fname = 'example01_01';
%% �t�@�C���̕ϊ�
%%
msip.m2mlx(srcDir,fname,dstDir,isVerbose)
%% �ϊ���̃X�N���v�g�̓��e
%%
open(fullfile(dstDir,[fname '.mlx']))