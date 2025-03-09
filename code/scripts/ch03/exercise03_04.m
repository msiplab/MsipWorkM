v = [18 9 9 9; 27 9 9 9; 36 9 9 9]

f = fspecial('unsharp',0)

u = imfilter(v,f)