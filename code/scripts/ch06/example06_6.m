J = 3;
N = 2^J;
Delta = 1/N;

fplot(@(x) iota(x,1),[-0.1 1.1])

phi = @(q) iota(q/Delta,1)
fplot(@(x) phi(x),[-0.1 1.1])
hold on
for n=1:N-1
    fplot(@(x) phi(x-n*Delta),[-0.1 1.1])
end
hold off


phij_1 = @(q) iota(q,1);
phij = @(q) phij_1(2*q)/sqrt(2)+phij_1(2*q-1)/sqrt(2);
psij = @(q) phij_1(2*q)/sqrt(2)-phij_1(2*q-1)/sqrt(2);
fplot(@(q) phij(q),[-0.1 1.1])
hold on
fplot(@(q) psij(q),[-0.1 1.1])
hold off


function z = iota(x,y)
arguments (Input)
    x
    y
end

arguments (Output)
    z
end

z = (x>=0).*(x<y);
end
