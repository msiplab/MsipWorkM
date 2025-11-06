function fullPicture = im53itrans(subLL,subHL,subLH,subHH)
%
% im53itrans
%
% Copyright (C) 2005-2025 Shogo MURAMATSU, All rights reserved
%
import msip.*

% 配列の準備
fullSize = size(subLL) + size(subHH);
fullPicture = zeros(fullSize,'like',subLL);

% 係数並べ替え
fullPicture(1:2:end,1:2:end,:) = subLL;
fullPicture(1:2:end,2:2:end,:) = subHL;
fullPicture(2:2:end,1:2:end,:) = subLH;
fullPicture(2:2:end,2:2:end,:) = subHH;

% 水平変換（インプレース演算）
fullPicture = updateStep(fullPicture.',-1/4);
fullPicture = predictionStep(fullPicture,1/2).';

% 垂直変換（インプレース演算）
fullPicture = updateStep(fullPicture,-1/4);
fullPicture = predictionStep(fullPicture,1/2);

end
