syms t Delta
assume(Delta,'real')
assume(Delta,'positive')

g = sinc(t/Delta)

G = fourier(g)

G = subs(G,Delta,2)
fplot(G)
