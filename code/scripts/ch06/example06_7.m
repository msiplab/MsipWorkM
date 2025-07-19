close all
iFig = 1;
%% 
J = 3;
M = 2^J;
Delta = 1/M;
R = [0 1];

figure(iFig)
fplot(@(x) chi(x,1),R)
iFig = iFig + 1;

%%
phi0 = @(q,n) chi(q/Delta-n,1);

figure(iFig)
fplot(@(x) phi0(x,0),R)
hold on
for n=1:M-1
    fplot(@(x) phi0(x,n),R)
end
hold off
iFig = iFig+1;
%%

f0 = [1 1]/sqrt(2);
f1 = [1 -1]/sqrt(2);
nmax = M/2;

phij = cell(J,1);
psij = cell(J,1);

for j=1:J
    if j==1
        phij{j} = @(q,p) f0(1)*phi0(q,2*p)+f0(2)*phi0(q,1+2*p);
        psij{j} = @(q,p) f1(1)*phi0(q,2*p)+f1(2)*phi0(q,1+2*p);
    else
        phij{j} = @(q,p) f0(1)*phij{j-1}(q,2*p)+f0(2)*phij{j-1}(q,1+2*p);
        psij{j} = @(q,p) f1(1)*phij{j-1}(q,2*p)+f1(2)*phij{j-1}(q,1+2*p);
    end

    figure(iFig)
    fplot(@(x) phij{j}(x,0),[-0.1,1.1])
    hold on
    for n=1:nmax-1
        fplot(@(x) phij{j}(x,n),[-0.1,1.1])
    end
    hold off
    iFig = iFig+1;

    figure(iFig)
    fplot(@(x) psij{j}(x,0),[-0.1,1.1])
    hold on
    for n=1:nmax-1
        fplot(@(x) psij{j}(x,n),[-0.1,1.1])
    end
    hold off
    iFig = iFig + 1;
    nmax = nmax/2;
end
%%

figure(iFig)
% m = 0
subplot(2^J,1,1)
fplot(@(x) phij{J}(x,0),R)
axis([R -1 1])
grid on
% m > 0

for m=1:2^J-1
    jm = J - floor(log2(m)); % 
    nm = m - 2^floor(log2(m)); 
    subplot(2^J,1,m+1)
    fplot(@(x) psij{jm}(x,nm),R)
    axis([R -1 1])
    grid on
end
iFig = iFig + 1;
%%
function z = chi(x,y)
arguments (Input)
    x
    y
end

arguments (Output)
    z
end

z = (x>=0).*(x<y);
end
