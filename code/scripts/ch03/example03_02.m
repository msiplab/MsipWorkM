%[text] # 例3.2（ガウシアンフィルタ）
%[text] 村松正吾　「多次元信号・画像処理の基礎と展開」
%[text] 動作確認： MATLAB R2025b
%[text] ## 準備
isVerbose = false;
prj = matlab.project.currentProject;
prjroot = prj.RootFolder;
datfolder = fullfile(prjroot,"data");
resfolder = fullfile(prjroot,"results");
myfilename = "example03_02"; % mfilename

%%
f = fspecial("gaussian",[3 3],0.5) %[output:3a4f422e]

import msip.arr2tex
arr2tex(f,"%6.4f") %[output:8a132535]
%[text] © Copyright, Shogo MURAMATSU, All rights reserved.

%[appendix]{"version":"1.0"}
%---
%[metadata:view]
%   data: {"layout":"onright"}
%---
%[output:3a4f422e]
%   data: {"dataType":"matrix","outputData":{"columns":3,"name":"f","rows":3,"type":"double","value":[["0.0113","0.0838","0.0113"],["0.0838","0.6193","0.0838"],["0.0113","0.0838","0.0113"]]}}
%---
%[output:8a132535]
%   data: {"dataType":"textualVariable","outputData":{"name":"ans","value":"    \"\n     0.0113 & 0.0838 & 0.0113\\\\\n     0.0838 & 0.6193 & 0.0838\\\\\n     0.0113 & 0.0838 & 0.0113\n     \"\n"}}
%---
