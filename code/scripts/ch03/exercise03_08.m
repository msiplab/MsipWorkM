import msip.arr2tex

v = [ 18 9 9 9; 27 9 9 9; 36 9 9 9]

u = medfilt2(v)

msip.arr2tex(u,"%d")