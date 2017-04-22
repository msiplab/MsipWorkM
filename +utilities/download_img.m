if exist('./data/','dir') == 7
    fnames = {'lena' 'baboon' 'goldhill' 'barbara'};
    for idx = 1:length(fnames)
        fname = [ fnames{idx} '.png' ];
        if exist(sprintf('./data/%s',fname),'file') ~= 2
            img = imread(...
                sprintf('http://homepages.cae.wisc.edu/~ece533/images/%s',...
                fname));
            imwrite(img,sprintf('./data/%s',fname));
            fprintf('Downloaded and saved %s in ./data\n',fname);
        else
            fprintf('%s already exists in ./data\n',fname);
        end
    end
else
    fprintf('./data folder does not exist\n');
end