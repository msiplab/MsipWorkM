close all
iFig = 1;
%% 
% パラメータ設定

K = 4;
M = 2*K;
Delta = 2/M;
R = [-1 1]; % 表示範囲

%%
% φ のプロット
phi = @(x) fcn_phin(x,0,K,0,0);

figure(iFig)
fplot(@(x) phi(x),R)
grid on

iFig = iFig + 1;

%%
% φn の構成
xmin = -1;
theta0 = 1/(2*K);

phin = cell(M,1);
for n=0:M-1
    phin{n+1} = @(x) fcn_phin(x,n,K,xmin,theta0);
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
psim = cell(M,1);
C = dctmtx(M);
D = C.';

for m=0:M-1
    psim{m+1} = @(x) 0;
    for n=0:M-1
        dnm = D(n+1,m+1);
        psim{m+1} = @(x) psim{m+1}(x) + dnm*fcn_phin(x,n,K,xmin,theta0);
    end
end

%%
% ψmのプロット
figure(iFig)

for m=0:M-1
    subplot(M,1,m+1)
    fplot(@(x) psim{m+1}(x),R)
    axis([R -1 1])
    grid on
end
iFig = iFig + 1;

%% ----------------------------------------------
%%
function y = fcn_phin(x,n,K,x0,theta0)

    y = moddiriclet( ( (x + x0) - (n/K + theta0) )/2 ,K)/(2*K);
   
end

%%
function y = moddiriclet(x,K)
y = 1;
if K > 0
    for k=1:K-1
        y = y + 2*cos(2*pi*k*x);
    end
    y = y + cos(2*pi*K*x);
end
end
