clear 

a = -1/2
b = 1/4
K = 1

%%
pa(:,:,1) = [1 -a; 0 1];
pa(:,:,2) = [0 -a; 0 0];

Pa = msip.ppmatrix(pa)

%%
pb(:,:,1) = [0 0; -b 0];
pb(:,:,2) = [1 0; -b 1];

Pb = msip.ppmatrix(pb)

%%

R = Pa*Pb 

%%
dm(:,:,1) = [0;1];
dm(:,:,2) = [1;0];
Dm = msip.ppmatrix(dm)

%%
F = Dm.'*upsample(R,2)

%%
F(1,1)
F(1,2)
