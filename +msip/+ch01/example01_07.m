%% ��1.7�i�F�������j
% ��������@�u�������M���E�摜�����̊�b�ƓW�J�v
% 
% ����m�F�F MATLAB R2017a
% 
% �ȉ��̃c�[���{�b�N�X���K�v
% 
% * Neural Network Toolbox
% 
% �\�߃T�|�[�g�p�b�P�[�W
% 
% * Neural Network Toolbox Importer for Caffe Models
% 
% �𓱓����邱��
% 
% �Q�l�T�C�g
% 
% * <https://jp.mathworks.com/help/nnet/ref/importcaffenetwork.html importCaffeNetwork>
% * <https://jp.mathworks.com/help/nnet/examples/create-simple-deep-learning-network-for-classification.html 
% ���ޗp�̃V���v���Ȑ[�w�w�K�l�b�g���[�N�̍쐬>
%% �摜�f�[�^�̓Ǎ��ƒ��o
% ImageDatastore �I�u�W�F�N�g�Ƃ��Đ����T���v���f�[�^��ǂݍ���
%%
digitDatasetPath = fullfile(matlabroot,'toolbox','nnet','nndemos', ...
        'nndatasets','DigitDataset');
digitData = imageDatastore(digitDatasetPath, ...
        'IncludeSubfolders',true,'LabelSource','foldernames');
%% �f�[�^�Z�b�g����ꕔ�̕����摜�������_�����o

figure
[nRows, nCols] = size(readimage(digitData,1));
nSamples = 20;
testImg = zeros(nRows,nCols,1,nSamples,'uint8');
perm = randperm(10000,20);
for idx = 1:20
    subplot(4,5,idx);
    testImg(:,:,1,idx) = readimage(digitData,perm(idx));
    imshow(testImg(:,:,1,idx));
end
%print('fig01-04a','-dpng')
%% ���O�w�K�ς݂�CNN���f���� Caffe ����C���|�[�g

% �C���|�[�g�t�@�C���̎w�� 
protofile = 'digitsnet.prototxt'; 
datafile = 'digits_iter_10000.caffemodel';
% �l�b�g���[�N�̃C���|�[�g
net = importCaffeNetwork(protofile,datafile);
disp(net.Layers)
%% �􍞂ݑw(conv1)�̏d�݌W����[0,1]�ɐ��K�����ĕ\��
%%
figure
weights = squeeze(net.Layers(2).Weights);
for idx = 1:20
    filter = weights(:,:,idx);
    mx = max(filter(:));
    mn = min(filter(:));
    filter = (filter-mn)/(mx-mn);
    subplot(4,5,idx);
    imshow(filter);
end
%print('fig01-04b','-dpng')
%% �����摜�̕��ރf��
%%
figure
labelList = categories(digitData.Labels);
answers = classify(net,testImg);
classList = categories(answers);
answers = renamecats(answers,classList,labelList);
for idx = 1:20
    subplot(4,5,idx);
    text(0.4,0.5,string(answers(idx)),'FontSize',20)
    ax = gca;
    ax.Box = 'on';
    ax.XTick = [];
    ax.YTick = [];
end
%print('fig01-04c','-dpng')
%% ���ސ��x�̌v�Z
%%
refdata = digitData.Labels(perm);
accuracy = sum(refdata == answers)/numel(answers)