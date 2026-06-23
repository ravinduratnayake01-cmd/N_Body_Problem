# N_Body_Problem
N-Body Gravitational Simulator

# N-Body Gravitational Simulator

Main.f95          
module1.f95       # Modules: gravity, virial, and N-body leapfrog integrator
Makefile          
2DTrajectories.py # Python visualization script


## Running

```
./nbody.exe
```

Prompt to enter the number of bodies N:
```
Ex:
Input Number of Bodies/Objects (N):
10
```


## Output Files

- positions.dat — Initial positions of all bodies
- snapshot_XXXX.dat — Space snapshot at step XXXX
- energy.dat 
- angular_momentum.dat 
- barycenter_velocity.dat 


## Visualization

After a simulation run, generate all plots with:

```
python3 2DTrajectories.py
```
