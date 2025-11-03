function [subLL,subHL,subLH,subHH] = imadj53itrans(fullPicture)
%
% imadj53itrans
%
% Copyright (C) 2005-2025 Shogo MURAMATSU, All rights reserved
%
import msip.*

fullPicture = double(fullPicture);

% 垂直変換（インプレース演算）
fullPicture = adjpredictionStep(fullPicture,1/2);
fullPicture = adjupdateStep(fullPicture,-1/4);

% 水平変換（インプレース演算）
fullPicture = adjpredictionStep(fullPicture.',1/2);
fullPicture = adjupdateStep(fullPicture,-1/4).';

% 係数並べ替え
subLL = fullPicture(1:2:end,1:2:end,:);
subHL = fullPicture(1:2:end,2:2:end,:);
subLH = fullPicture(2:2:end,1:2:end,:);
subHH = fullPicture(2:2:end,2:2:end,:);

end
