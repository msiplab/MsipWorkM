%% MATLABスクリプトからライブスクリプトへの変換
%
% Copyright (c) Shogo MURAMATSU, 2018
% All rights resereved

srcDir = './scripts/ch01/';
dstDir = fullfile(pwd,'/livescripts/ch01/');
isVerbose = true;
%% ファイルの指定
%%
fname = 'example01_01';
%% ファイルの変換
%%
msip.m2mlx(srcDir,fname,dstDir,isVerbose)
%% 変換後のスクリプトの内容
%%
open(fullfile(dstDir,[fname '.mlx']))