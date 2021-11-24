#Copyright 2021 Google LLC
#
#Licensed under the Apache License, Version 2.0 (the "License");
#you may not use this file except in compliance with the License.
#You may obtain a copy of the License at
#
#    https://www.apache.org/licenses/LICENSE-2.0
#
#Unless required by applicable law or agreed to in writing, software
#distributed under the License is distributed on an "AS IS" BASIS,
#WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#See the License for the specific language governing permissions and
#limitations under the License.

# TODO: comment and clean-up code
import sys
import os

target_size = ZZ(int(sys.argv[1]))
target_y = ZZ(int(sys.argv[2]))
num_rounds = 200000
solved_dir = './small_fat_4_polys'
max_size_interested = 22
def random_poly(n, d=4,  num_bound = 100000, den_bound = 1):
    return Polyhedron([QQ.random_element(num_bound, den_bound) for i in range(d)] for j in range(n))
def get_intersection(f1_a=14, f1_b=20, num_bound=2):
    'quick adhoc way to get a fairly fat polytope, which is not to simple and not to simplicial'
    P1 = random_poly(f1_a, num_bound = num_bound)
    P2 = random_poly(f1_b, num_bound = num_bound).polar()
    return P2.dilation(9).intersection(P1.dilation(1))
def delta(f_vector, target_size, target_y):
    fm1, f0, f1, f2, f3, f4 = vector(f_vector)
    size = (f0 + f3) - 10
    return  12*(size - target_size)^2 + (f1 + f2 - 20 -  2*size - (target_y))^2
def check_if_better(Q, best_delta, solved_cases_with_f):
    if not Q.is_compact() or Q.dimension()!=4:
        return None, best_delta
    fvec = Q.f_vector()
    new_delta = delta(fvec, target_size, target_y)

    if best_delta is None or new_delta < best_delta:
        hyperplane_removed = True
        new_under_sun = True
        best_delta = new_delta
        fv = fvec
        fm1, f0, f1, f2, f3, f4 = vector(fv)
        size = f0 + f3 - 10
        new_pair = (size, f1 + f2 - 20 - 2*size)
        if (new_pair, tuple(Q.f_vector())) not in solved_cases_with_f and new_pair[0] <= max_size_interested:
            with open(os.path.join(solved_dir, f'{new_pair}_{Q.f_vector()}'), 'w') as f:
                f.write(str(Q.vertices_list()) + '\n')
            print('newsol', new_pair, fv, best_delta)

        return Q, new_delta
    return 'P', best_delta

best_delta = None
counter = 0
pair = (target_size, target_y)
print(f'optimizing for {pair}')

solved_cases = {sage_eval(sol.split('_')[0])  for sol in os.listdir(solved_dir)}
solved_cases_with_f = {tuple(sage_eval(val) for val in sol.split('_')) for sol in os.listdir(solved_dir)}
while(best_delta!=0 and counter < num_rounds):
    if counter%50 == 0:
        solved_cases = {sage_eval(sol.split('_')[0])  for sol in os.listdir(solved_dir)}
        solved_cases_with_f = {tuple(sage_eval(val) for val in sol.split('_')) for sol in os.listdir(solved_dir)}
    if pair in solved_cases or best_delta==0:
        print("case solved")
        break
    counter += 1
    lap = 0
    new_under_sun = True
    P = get_intersection(17, 27, 200)
    best_delta = None
    while(new_under_sun and best_delta!=0):
        new_under_sun = False
        #print(f'{lap = }')
        lap +=1
        #print('remove hyperplanes')
        hyperplane_removed = True
        while(hyperplane_removed):
            hyperplane_removed = False
            inequalities = list(range(len(P.inequalities_list())))
            shuffle(inequalities)
            for hk in inequalities:
                Q = Polyhedron(ieqs = [ine for k, ine in enumerate(P.inequalities_list()) if k!= hk])
                new_P, best_delta = check_if_better(Q, best_delta, solved_cases_with_f)
                if new_P is None or best_delta == 0:
                    break
                if new_P != 'P':
                    P = new_P
                    new_under_sun = True
                    hyperplane_removed = True
        hyperplane_removed = True
        while(hyperplane_removed and best_delta!=0):
            hyperplane_removed = False
            vertices = list(range(len(P.vertices_list())))
            shuffle(vertices)
            for hk in vertices:
                Q = Polyhedron([ine for k, ine in enumerate(P.vertices_list()) if k!= hk])
                new_P, best_delta = check_if_better(Q, best_delta, solved_cases_with_f)
                if new_P is None or best_delta == 0:
                    break
                if new_P != 'P':
                    P = new_P
                    hyperplane_removed = True
                    new_under_sun = True




