waveinfo('db')

% DB1 (Haar)
figure(1)
[~,~,f0,f1] = wfilters('db1')
subplot(1,2,1), zplane(f0)
subplot(1,2,2), zplane(f1)

% DB2
figure(2)
[~,~,f0,f1] = wfilters('db2')
subplot(1,2,1), zplane(f0)
subplot(1,2,2), zplane(f1)

%%
2^(-5/2)*conv(conv([1 1],[1 1]),[1+sqrt(3) 1-sqrt(3)])
2^(-5/2)*conv(conv([1 -1],[1 -1]),[1-sqrt(3) -1-sqrt(3)])

