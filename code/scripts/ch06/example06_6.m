close all
iFig = 1;
%% 
% パラメータ設定

K = 4;
M = 2*K;
Delta = 2/M;
R = [-1 1];

close all
iFig = 1;

%%
% チェビシェフ節点
chebyshev_nodes = cos( ((0:M-1)'+1/2)*pi /M);
qk = chebyshev_nodes;

%%
% チェビシェフ多項式とチェビシェフ節点
figure(iFig)

for m=0:M-1
    subplot(M,1,m+1)
    taum = @(q) fcn_cheb(q,m);
    fplot(taum,R)
    hold on
    %plot(qk, taum(qk))
    for k=1:M
        line([qk(k) qk(k)], [-1 1], 'Color', 'r', 'LineStyle', '--');    
    end
    axis([R -1 1])
    grid on
    hold off
end
iFig = iFig + 1;

%%
% 補間関数 φ の設定とプロット
%phi = @(x) fcn_phin(x,0,K,0,0); %.* fcn_chi(x,R);
phi = @(x) fcn_cubic(x*K); %.* fcn_chi(x,R);
%phi = @(x) max(1-abs(K*x),0);

figure(iFig)
fplot(@(x) phi(x),2*R)
grid on

iFig = iFig + 1;

%% TODO
% 行列 H の設定
xmin = -1;
theta0 = 1/(2*K);

pm = -1 + ( 1 + 2*(0:M-1))/M;
qn = cos(((0:M-1)+1/2)*pi/M);

H = zeros(M);

%%{
for n=0:M-1
    for m=0:M-1
        qn(n+1)-pm(m+1)
        H(n+1,m+1) = phi(qn(n+1)-pm(m+1));
    end
end
%%}

H
rank(H)

%%
%{
% φn の構成
phin = cell(M,1);
for n=0:M-1
    %phin{n+1} = @(x) fcn_phin(x,n,K,xmin,theta0);
    phin{n+1} = @(x) fcn_chi(x,Delta*R-1+1/M+n*Delta);
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
D = H\C.';

for m=0:M-1
    psim{m+1} = @(x) 0;
    for n=0:M-1
        dnm = D(n+1,m+1);
        %psim{m+1} = @(x) psim{m+1}(x) + dnm*fcn_phin(x,n,K,xmin,theta0);
        psim{m+1} = @(x) psim{m+1}(x) + dnm*phin{n+1}(x);
    end
    psim{m+1} = @(x) psim{m+1}(x);
end

%% TODO
% ψmのプロット
figure(iFig)

for m=0:M-1
    subplot(M,1,m+1)
    fplot(@(x) psim{m+1}(x),R)
    %axis([R -1 1])
    grid on
end
iFig = iFig + 1;
%}
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

%%
function y = fcn_cheb(x,n)
    if n==0 
        alpha = 1/sqrt(pi);
    else
        alpha = sqrt(2/pi);
    end
    y = alpha*cos(n*acos(x));
end

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

%%
function y = fcn_cubic(x)
a = -1/2;
absx = abs(x);
if 1 < absx && absx <=2
    y = a*absx.^3 - 5*a*absx.^2 + 8*a*absx - 4 * a;
elseif absx <= 1
    y = (a+2)*absx.^3 - (a+3)*absx.^2 + 1;
else
    y = 0;
end

end