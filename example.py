from firedrake import *


mesh = UnitSquareMesh(200, 200)
V = FunctionSpace(mesh, "CG", 2)
u = TrialFunction(V)
v = TestFunction(V)
a = inner(u, v) * dx
L = conj(v) * dx
sol = Function(V)
solve(a == L, sol)
