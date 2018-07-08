srcdir = [ pwd '/livescripts/'];
dstdir = [ './scripts/' ];

file = 'ch01/example01_01';
sourceFileName = [ srcdir file '.mlx'];
destinationFile = [ dstdir file '.m'];

if exist(destinationFile,'file') ~= 2
    matlab.internal.liveeditor.openAndConvert(...
        sourceFileName, destinationFile);
else
    me = MException('MSIP:fileExists','%s exists',destinationFile);
    throw(me)
end