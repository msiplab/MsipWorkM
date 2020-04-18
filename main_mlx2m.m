%% ライブスクリプトからMATLABスクリプトへの変換
%
% Copyright (c) Shogo MURAMATSU, 2020
% All rights resereved

subDirs = [
    'ch01' ;
    ];

%
isVerbose = true;
for diridx = 1:size(subDirs,1)
    dname = subDirs(diridx,:);
    srcDir = fullfile(pwd,['/livescripts/' dname '/']);    
    dstDir = ['./scripts/' dname '/'];
    % ファイルの取得
    list = ls([srcDir '*.mlx']);
    % ファイルの変換
    for fileidx = 1:size(list,1)
        % ファイル名の抽出
        [~,fname,~] = fileparts(list(fileidx,:));
        % ライブスクリプトへ変換
        msip.mlx2m(srcDir,fname,dstDir,isVerbose)
        % 変換後のスクリプトの内容
        %open(fullfile(dstDir,[fname '.m']))
    end
end