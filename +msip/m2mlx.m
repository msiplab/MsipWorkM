srcdir = './scripts/';
dstdir = [ pwd '/livescripts/'];

file = 'ch01/example01_01';
sourceFileName = [ srcdir file '.m'];
destinationFile = [ dstdir file '.mlx'];
matlab.internal.liveeditor.openAndSave(sourceFileName, destinationFile);
