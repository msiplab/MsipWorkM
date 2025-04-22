omegac = 0.5*pi;

Delta = pi/omegac;
h = @(n) sinc(n/Delta)/Delta;

freqz(h(-2000:2000),1,4096,'whole')

