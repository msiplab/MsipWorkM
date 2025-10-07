waveinfo('db')

% DB1 (Haar)
figure(1)
[~,~,f0,~] = wfilters('db1')
zplane(f0)

% DB2
figure(2)
[~,~,f0,~] = wfilters('db2')
zplane(f0)

