import os
import sys

path_poly_dir = sys.argv[1]

for poly_name in os.listdir(path_poly_dir):
    print("checking", poly_name)
    fat_size, f_vector = map(sage_eval, poly_name.split("_"))
    with open(os.path.join(path_poly_dir, poly_name)) as f:
        vertices = sage_eval(f.read())
    P = Polyhedron(vertices)
    assert f_vector == tuple(P.f_vector())
    size = f_vector[1] + f_vector[4] - 10
    y_size = f_vector[2] + f_vector[3] - 20 - 2*size
    assert (size, y_size) == fat_size
