import msip.arr2tex

v = [ 18 9 9 9; 27 9 9 9; 36 9 9 9]

f = flipud(fspecial('prewitt'))

imfilter(v,f,"corr")

msip.arr2tex(imfilter(v,f),"%d")

f = f.'

imfilter(v,f,"corr")

msip.arr2tex(imfilter(v,f),"%d")