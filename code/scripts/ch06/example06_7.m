close all
clear all

%% 
J = 3;
M = 2^J;
Delta = 1/M;
R = [-0.1 1.1];

figure(1)
fplot(@(x) chi(x,1),R)

%%
phi0 = @(q) chi(q/Delta,1);

figure(2)
fplot(@(x) phi0(x),R)
hold on
for n=1:M-1
    phin = @(x) phi0(x-n*Delta);
    fplot(@(x) phin(x),R)
end
hold off

%%
phi0 = @(q,n) phi0(q-n*Delta);

figure(3)
fplot(@(x) phi0(x,0),R)
hold on
for n=1:M-1
    fplot(@(x) phi0(x,n),R)
end
hold off

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

    figure(3+j)
    fplot(@(x) phij{j}(x,0),[-0.1,1.1])
    hold on
    for n=1:nmax-1
        fplot(@(x) phij{j}(x,n),[-0.1,1.1])
    end
    hold off

    figure(4+j)
    fplot(@(x) psij{j}(x,0),[-0.1,1.1])
    hold on
    for n=1:nmax-1
        fplot(@(x) psij{j}(x,n),[-0.1,1.1])
    end
    hold off

    nmax = nmax/2;
end
%%

figure(4+J+1)
% m = 0
subplot(2^J,1,1)
fplot(@(x) phij{J}(x,0),R)
axis([R -1 1])
grid on
% m > 0
disp('---')
for m=1:2^J-1
    jm = J - floor(log2(m)); % 
    nm = m - 2^floor(log2(m)); 
    subplot(2^J,1,m+1)
    fplot(@(x) psij{jm}(x,nm),R)
    axis([R -1 1])
    grid on
end

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
