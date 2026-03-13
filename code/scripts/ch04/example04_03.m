syms t sigma pi_real
assume(pi_real','real')
assume(pi_real','positive')
assume(sigma,'real')
assume(sigma,'positive')
pi_real = sym(pi)

g = 1/(sqrt(2*pi_real)*sigma)*exp(-(1/2)*(t/sigma)^2)

G = fourier(g)

G = subs(G,sigma,2)
fplot(G)
