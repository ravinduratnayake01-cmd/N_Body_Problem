import numpy as np
import matplotlib.pyplot as plt
import glob
import re
from io import StringIO

# Ignore numbers that are too small
def load_with_nan(fname):
    with open(fname) as f:
        text = f.read()
    text = re.sub(r'\*+', 'nan', text)
    return np.loadtxt(StringIO(text))

files = sorted(glob.glob("snapshot_*.dat"))

N = sum(1 for _ in open(files[0]))

positions = np.zeros((len(files), N, 3))

for t, fname in enumerate(files):
    data = load_with_nan(fname)
    positions[t, :, :] = data[:, :3]

# 2D trajectories
plt.figure(figsize=(8, 6))
for i in range(N):
    plt.plot(positions[:, i, 0], positions[:, i, 1], label=f'Body {i+1}')
plt.xlabel("X")
plt.ylabel("Y")
plt.title("2D Trajectories")
plt.axis('equal')
plt.grid(True)
plt.show()

# 3D trajectories
fig = plt.figure(figsize=(10, 7))
ax = fig.add_subplot(111, projection='3d')
for i in range(N):
    ax.plot(positions[:, i, 0], positions[:, i, 1], positions[:, i, 2], label=f'Body {i+1}')
ax.set_xlabel("X")
ax.set_ylabel("Y")
ax.set_zlabel("Z")
ax.set_title("3D Trajectories")
plt.show()

# Energy
data = load_with_nan('energy.dat')
steps = data[:, 0]
U = data[:, 1]
K = data[:, 2]
E = data[:, 3]

plt.figure(figsize=(10, 6))
plt.plot(steps, U, label='Potential Energy (U)', color='blue')
plt.plot(steps, K, label='Kinetic Energy (K)', color='red')
plt.plot(steps, E, label='Total Energy (E)', color='black')

plt.xlabel('Time Step')
plt.ylabel('Energy')
plt.title('Energy vs Time')
plt.legend()
plt.grid(True)
plt.tight_layout()
plt.show()

# Angular momentum
data = load_with_nan('angular_momentum.dat')
steps_L = data[:, 0]
Lx, Ly, Lz = data[:, 1], data[:, 2], data[:, 3]
L_mag = np.sqrt(Lx**2 + Ly**2 + Lz**2)

plt.plot(steps_L, Lx, label='Lx')
plt.plot(steps_L, Ly, label='Ly')
plt.plot(steps_L, Lz, label='Lz')
plt.xlabel('Time Step')
plt.ylabel('Angular Momentum')
plt.title('Angular momentum components')
plt.legend()
plt.grid(True)

plt.tight_layout()
plt.show()

# Barycenter velocity
data = load_with_nan('barycenter_velocity.dat')
steps_V = data[:, 0]
Vx, Vy, Vz = data[:, 1], data[:, 2], data[:, 3]
V_mag = np.sqrt(Vx**2 + Vy**2 + Vz**2)

plt.plot(steps, V_mag, label='|V_cm|')
plt.xlabel('Time Step')
plt.ylabel('Barycentric Velocity')
plt.title('Barycentric Velocity vs Time')
plt.grid(True)
plt.show()








