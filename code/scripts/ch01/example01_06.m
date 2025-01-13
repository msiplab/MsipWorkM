%% ��1.6�i���������j
% ��������@�u�������M���E�摜�����̊�b�ƓW�J�v
% 
% ����m�F�F MATLAB R2017a
%% �摜�f�[�^�̃_�E�����[�h
%%
isVerbose = false;
msip.download_img(isVerbose)
%% �摜�f�[�^�̓Ǎ�
%%
X = im2double(rgb2gray(imread('./data/lena.png')));
%% �򉻑O�̉摜�\��
%%
figure(1)
imshow(X)
title('���摜')
%% �򉻉ߒ�
%%
hsigma  = 4;                    % �K�E�X�J�[�l�����U
hsize   = 2*ceil(2*hsigma)+1;   % �K�E�X�J�[�l���T�C�Y
nvar    = (10/255)^2;            % ���@�����F�K�E�X�m�C�Y���U
gaussfilt = fspecial('gaussian',hsize,hsigma);             % �K�E�X�J�[�l��
linproc = @(x) imfilter(x,gaussfilt,'conv','circular'); % ���`�ϑ��ߒ�
U = linproc(X);                 % ���`�ϑ�
V = imnoise(U,'gaussian',0,nvar);  % ���@�����F�K�E�X�m�C�Y
%% �򉻌�̉摜�\��
%%
figure(2)
imshow(V)
title('�򉻉摜')
%% �򉻌�̕i��
%%
fprintf('�򉻌�̕i��(PSNR)�F %6.2f [dB]\n',psnr(V,X))
%% �����O����
%%
adjproc = @(x) imfilter(x,gaussfilt,'corr','circular'); %�@�����ϑ��ߒ�
vpst = rand(size(V),'like',V);
lpre = 1.0;
err_ = Inf;
while ( err_ >  1e-5 ) % �ׂ���@
    % vpst = (P.'*P)*vupre
    vpre = vpst/norm(vpst(:));
    u    = linproc(vpre); % P
    vpst = adjproc(u);    % P.'
    n    = (vpst(:).'*vpst(:));
    d    = (vpst(:).'*vpre(:));
    lpst = n/d;
    err_ = norm(lpst-lpre);
    lpre = lpst;
end
frameBound = 1; % �t���[�����E
L = frameBound*lpst ;  
%fprintf('L = %g\n',L);
%% *��������(FISTA)*
%%
lambda  = 5e-4;
nLevels = 5;
nItrs   = 25;
isFista = true;
%
[Cpre,S]= msip.nshaarwtdec2(adjproc(V),nLevels);
tpre = 1;
%
Y = msip.nshaarwtrec2(Cpre,S);
R = linproc(Y)-V;
for iItr = 1:nItrs
    D = (1/L)*msip.nshaarwtdec2(adjproc(R),nLevels);
    C = softthresh(Cpre-D,lambda/L);
    if isFista % FISTA
        W = C;
        t = (1+sqrt(1+4*tpre^2))/2;
        C = W+(tpre-1)/t*(W-Cpre);
        tpre = t;
    end
    Y = msip.nshaarwtrec2(C,S);
    R = linproc(Y)-V;
    Cpre = C;
end
%% ������̉摜�\��
%%
figure(3)
imshow(Y)
title('�����摜')
%% ������̕i��
%%
fprintf('������̕i��(PSNR)�F %6.2f [dB]\n',psnr(Y,X))
%% �֐���`
% �\�t�g臒l����
%%
function y = softthresh(x,thresh)
    v = abs(x)-thresh;
    y = sign(x).*(v+abs(v))/2;
end