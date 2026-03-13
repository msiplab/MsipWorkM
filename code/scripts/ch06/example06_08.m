close all
iFig = 1;
%% 
% パラメータ設定

J = 3;
M = 2^J;
Delta = 1/M;
R = [0 1]; % 表示範囲

%%
% φ のプロット
phi = @(x) fcn_chi(x,R);

figure(iFig)
fplot(@(x) phi(x),R)
grid on

iFig = iFig + 1;
%%
% φn の構成
phin = cell(M,1);
for n=0:M-1
    phin{n+1} = @(x) fcn_chi(x/Delta-n,R);
end

%%
% φn のプロット
figure(iFig)

for n=0:M-1
    subplot(M,1,n+1)
    fplot(@(x) phin{n+1}(x),R)
    axis([R -1 1])
    grid on
end
iFig = iFig + 1;

%%
% ψm の構成
f0 = [1 1]/sqrt(2);
f1 = [1 -1]/sqrt(2);
nmax = M/2;

phi0 = @(x,n) fcn_chi(x/Delta-n,R);
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
    nmax = nmax/2;
end

%%
% ψm のプロット
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
%---------------------------------------------
%%
function z = fcn_chi(x,y)
arguments (Input)
    x
    y
end

arguments (Output)
    z
end

z = (x>=y(1)).*(x<y(2));
end
