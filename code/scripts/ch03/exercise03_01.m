x = [18 9 9 9; 27 9 9 9; 36 9 9 9]

f = fspecial('average',3)

y = imfilter(x,f,'corr','same')