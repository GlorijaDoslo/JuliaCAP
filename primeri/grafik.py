from math import log as ln
import numpy as np
import matplotlib.pyplot as plt


# Primer 9
# f = lambda om: abs(1 / (2 - 4*(om**2) + 1j * (4 * om - 2 * (om**3))))

# Primer 10
# f = lambda om: abs(1 / (1 + .5j*om))

# Primer 11
f = lambda om: abs((-1.5j * om) / (1.125 + .75j*om - 1.125 * om**2))


xs = np.linspace(0, 8, 200)
ys = [f(x) for x in xs]

print(xs)
print(ys)

plt.plot(xs, ys)
plt.grid()
plt.show()
