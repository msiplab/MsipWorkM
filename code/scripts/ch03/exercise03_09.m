import msip.arr2tex

v = [ 18 9 9 9; 27 9 9 9; 36 9 9 9]

umax = ordfilt2(v,9,true(3))

msip.arr2tex(umax,"%d")

umin = ordfilt2(v,1,true(3))

msip.arr2tex(umin,"%d")