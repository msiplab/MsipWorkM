clear 

a = -1/2
b = 1/4
K = 1

J2 = fliplr(eye(2));
%%
pa(:,:,1) = [1 0; -a 1];
pa(:,:,2) = [0 0; -a 0];

Pa = msip.ppmatrix(pa)

%%
pb(:,:,1) = [0 -b; 0 0];
pb(:,:,2) = [1 -b; 0 1];

Pb = msip.ppmatrix(pb)

%%

R = J2*Pa*Pb 

%%
dm(:,:,1) = [0;1];
dm(:,:,2) = [1;0];
Dm = msip.ppmatrix(dm)

%%
F = Dm.'*upsample(R,2)

%%
F(1,1)
F(1,2)
