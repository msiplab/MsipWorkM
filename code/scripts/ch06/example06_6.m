close all
iFig = 1;
%% 
M = 4;
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
psim = cell(M,1);
C = dctmtx(M);

for m=0:M-1
    psim{m+1} = @(x) 0;
    for n=0:M-1
        cmn = C(m+1,n+1);
        psim{m+1} = @(x) psim{m+1}(x) + cmn*phi0(x,n);
    end
end

%%
figure(iFig)

for m=0:M-1
    subplot(M,1,m+1)
    fplot(@(x) psim{m+1}(x),R)
    axis([R -1 1])
    grid on
end
iFig = iFig + 1;

%%
figure(iFig)
% Chebyshev nodes
chebyshev_nodes = cos((2*(0:M-1)'+1)*pi/(2*M));

for m=0:M-1
    subplot(M,1,m+1)
    f = @(x) chb(-2*x +1,m);
    fplot(f,R)
    hold on
    plot((chebyshev_nodes+1)/2, f((chebyshev_nodes+1)/2), 'r.')
    axis([R -1 1])
    grid on
    hold off
end
iFig = iFig + 1;

%%
function y = chb(x,n)
    if n==0 
        alpha = 1/sqrt(pi);
    else
        alpha = sqrt(2/pi);
    end
    y = alpha*cos(n*acos(x));
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
