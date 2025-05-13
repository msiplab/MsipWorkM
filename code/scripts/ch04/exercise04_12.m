x = zeros(6,7);
x(1:3,1:4) = [ 18 9 9 9 ; 27 9 9 9; 36 9 9 9];

h = zeros(6,7);
h(1:3,1:3) = 1/9;
h = circshift(h,[-1 -1])

y = ifft2(fft2(x).*fft2(h))

msip.arr2tex(round(y,1),"%4d")