function download_img(isVerbose)
% DOWNLOAD_IMG
%

if nargin < 1
    isVerbose = true;
end

if exist('./data/','dir') == 7
    fnames = {'lena' 'baboon' 'goldhill' 'barbara'};
    for idx = 1:length(fnames)
        fname = [ fnames{idx} '.png' ];
        if exist(sprintf('./data/%s',fname),'file') ~= 2
            img = imread(...
                sprintf('http://homepages.cae.wisc.edu/~ece533/images/%s',...
                fname));
            imwrite(img,sprintf('./data/%s',fname));
            if isVerbose
                fprintf('Downloaded and saved %s in ./data\n',fname);
            end
        else
            if isVerbose
                fprintf('%s already exists in ./data\n',fname);
            end
        end
    end
else
    me = MException('MSIP:noSuchFolder', ...
        '%s folder does not exist','./data');
    throw(me)
end