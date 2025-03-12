import msip.arr2tex

v = [ 18 9 9 9; 27 9 9 9; 36 9 9 9]

% 零値拡張
msip.arr2tex(padarray(v,[2 2]),"%d")

% 周期拡張
msip.arr2tex(padarray(v,[2 2],"circular"),"%d")


% 複製拡張
msip.arr2tex(padarray(v,[2 2],"replica"),"%d")


% 対称拡張(HS)
msip.arr2tex(padarray(v,[2 2],"symmetric"),"%d")

% 対称拡張(WS)
y = padarray(v,[3 3],"symmetric")
y = [y(:,1:2) y(:,4:7) y(:,9:10)]
y = [y(1:2,:);y(4:6,:); y(8:9,:)]
msip.arr2tex(y,"%d")
