%% ��1.4�i�Î~�摜�̃f�[�^�ʁj
% ��������@�u�������M���E�摜�����̊�b�ƓW�J�v
% 
% ����m�F�F MATLAB R2017a
%% (1) 8�r�b�g�����Ȃ������^�i$\beta=8$[bits]�j�̃O���[�X�P�[���摜�̏ꍇ
%%
V = ones(2304,3456,'uint8');
dataInfo = whos('V');
disp(dataInfo)
%% (2) �{���x�����^�i$\beta=8$[bits]�j��RGB�摜�̏ꍇ
%%
V = ones(2304,3456,3,'double');
dataInfo = whos('V');
disp(dataInfo)