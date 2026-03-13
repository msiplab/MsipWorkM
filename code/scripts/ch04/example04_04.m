syms q Delta
assume(Delta,'real')
assume(Delta,'positive')

h = sinc(q/Delta)/Delta

H = fourier(h)

H = subs(G,Delta,2)
fplot(G)
