import msip.arr2tex

v = [ 18 9 9 9; 27 9 9 9; 36 9 9 9]

f = flipud(fspecial('prewitt'))

vv = imfilter(v,f,"corr");

msip.arr2tex(vv,"%d")

f = f.'

vh = imfilter(v,f,"corr");

msip.arr2tex(vh,"%d")

umag = sqrt(vv.^2+vh.^2);

msip.arr2tex(umag,"%6.2f")
