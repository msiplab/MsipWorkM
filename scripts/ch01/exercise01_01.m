%% ���1.1�i���`�ʑ��ƍs��\���j
% ��������@�u�������M���E�摜�����̊�b�ƓW�J�v
% 
% ����m�F�F MATLAB R2017a
%% $2\times 3$�s��̐���
%%
V = rand(2,3)
%% ����V�t�g
%%
m = [0 1]; % �V�t�g��
U = circshift(V,m)
%% $2\times 3$�z��̕W�����
%%
B0 = [ 1 0 0 ; 
       0 0 0 ]
   
B1 = [ 0 0 0 ; 
       1 0 0 ]
   
B2 = [ 0 1 0 ; 
       0 0 0 ]
   
B3 = [ 0 0 0 ; 
       0 1 0 ]
   
B4 = [ 0 0 1 ; 
       0 0 0 ]
   
B5 = [ 0 0 0 ; 
       0 0 1 ]
%% �W�����z��ɑ΂��鏄��V�t�g�̌���
%%
U0 = circshift(B0,m)
U1 = circshift(B1,m)
U2 = circshift(B2,m)
U3 = circshift(B3,m)
U4 = circshift(B4,m)
U5 = circshift(B5,m)
%% ����V�t�g�̍s��\��
%%
t0 = U0(:);
t1 = U1(:);
t2 = U2(:);
t3 = U3(:);
t4 = U4(:);
t5 = U5(:);
T = [ t0 t1 t2 t3 t4 t5 ]
%% �s�񉉎Z�ɂ�鏄��V�t�g
%%
v = V(:);
u = T*v;
reshape(u,2,3)