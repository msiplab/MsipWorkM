M = 4
rho = 0.95

row = 1;

for idx = 1:M-1
    row = [row rho^idx];
end

Sx = toeplitz(row);

C = dctmtx(M);

Sy = C*Sx*C.';

import msip.*


arr2tex(C,'% 6.4f')
arr2tex(Sx,'% 6.4f')
arr2tex(C.','% 6.4f')

arr2tex(Sy,'% 6.4f')


nom = mean(diag(Sy))

den = prod(diag(Sy))^(1/M)


nom/den