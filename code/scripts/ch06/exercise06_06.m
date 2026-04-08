clear 

a = -1/2
b = 1/4
K = 1

J2 = fliplr(eye(2));

%%
pa(:,:,1) = [0 0; -a 0];
pa(:,:,2) = [1 0; -a 1];

Pa = msip.ppmatrix(pa)

%%
ub(:,:,1) = [1 -b; 0 1];
ub(:,:,2) = [0 -b; 0 0];

Ub = msip.ppmatrix(ub)

%%

R = J2*Pa*Ub 

%%
dm(:,:,1) = [1;0];
dm(:,:,2) = [0;1];
Dm = msip.ppmatrix(dm)
Dm.' % Para-conjugation

%%
F = Dm.'*upsample(R,2)

%%
F(1,1)
F(1,2)
