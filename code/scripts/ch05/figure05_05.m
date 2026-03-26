fmesh(@(x,y) eta(y,x),[-2 2 -2 2])
%%
X = imresize(im2double(imread('cameraman.tif')),[96 96]);
imshow(X)
%%
P = [cos(pi/6) -sin(pi/6); sin(pi/6) cos(pi/6)]; %diag([1.5 2.5]);
Y = myresample(X,P);
imshow(Y)

%[output:8fd65f93]
%%
function y = myresample(x,P)
szX = size(x);
p = P*[0 0 szX(1)-1 szX(1)-1;0  szX(2)-1 0 szX(2)-1];
pvmin = floor(min(p(1,:)));
pvmax = ceil(max(p(1,:)));
phmin = floor(min(p(2,:)));
phmax = ceil(max(p(2,:)));
nRows = pvmax - pvmin + 1;
nCols = phmax - phmin + 1;
y = zeros(nRows, nCols); % Initialize the output array
nh = 1;
for ph = phmin:phmax
    nv = 1;
    for pv = pvmin:pvmax
        c = P\[pv;ph];
        for mh = 1:size(x,2)
            for mv = 1:size(x,1)
                q = c - [mv;mh];
                y(nv,nh) = y(nv,nh) + x(mv,mh)*eta(q(1),q(2));
            end
        end
        nv = nv + 1;
    end
    nh = nh + 1;
end
end

function y = eta(qv,qh)
yv = max(0,qv+1) - 2*max(0,qv) + max(0,qv-1);
yh = max(0,qh+1) - 2*max(0,qh) + max(0,qh-1);
y = yv.*yh;
end

%[appendix]{"version":"1.0"}
%---
%[metadata:view]
%   data: {"layout":"onright","rightPanelPercent":40}
%---
%[output:8fd65f93]
%   data: {"dataType":"error","outputData":{"errorType":"runtime","text":"次を使用中のエラー: <a href=\"matlab:matlab.lang.internal.introspective.errorDocCallback('profile>iExecuteProfileCLIAction', 'C:\\Program Files\\MATLAB\\R2025b\\toolbox\\matlab\\codetools\\profile.m', 250)\" style=\"font-weight:bold\">profile>iExecuteProfileCLIAction<\/a> (<a href=\"matlab: opentoline('C:\\Program Files\\MATLAB\\R2025b\\toolbox\\matlab\\codetools\\profile.m',250,0)\">行 250<\/a>)\nアクション VIEW はプロファイラーで不明です。\n\nエラー: <a href=\"matlab:matlab.lang.internal.introspective.errorDocCallback('profile', 'C:\\Program Files\\MATLAB\\R2025b\\toolbox\\matlab\\codetools\\profile.m', 203)\" style=\"font-weight:bold\">profile<\/a> (<a href=\"matlab: opentoline('C:\\Program Files\\MATLAB\\R2025b\\toolbox\\matlab\\codetools\\profile.m',203,0)\">行 203<\/a>)\n[varargout{1:nargout}] = iExecuteProfileCLIAction(profilerService, action);\n^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^"}}
%---
