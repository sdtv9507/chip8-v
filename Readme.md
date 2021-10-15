# Chip8-V
A chip-8 interpreter made in V language. Can be used as a libretro core or as a standalone app.
Doesn't have audio yet.

## Compiling from source

### Standalone
*Requieres OpenGL 3.3
```sh
v chip8v.v
```
After compiling do
```sh
chip8v path/to/my/rom
```

### Libretro Core
```sh
v chip8v_libretro.v -shared -enable-globals -cc tccbin
```
Copy the core file to Retroarch's core folder
Copy chip8v_libretro.info to Retroarch's info folder