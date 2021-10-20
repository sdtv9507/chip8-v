# Chip8-V
A chip-8 interpreter made in V language. Can be used as a libretro core or as a standalone app.

## Compiling from source

### Standalone

Install [vsdl2](https://github.com/nsauzede/vsdl2)

To build run:
`v chip8v.v -cc gcc`
After compiling do
`chip8v path/to/my/rom`
If you are on Windows, you may need to do this on MSYS2 shell.

### Libretro Core
`v chip8v_libretro.v -shared -enable-globals -cc gcc`
Copy the core file to Retroarch's core folder
Copy chip8v_libretro.info to Retroarch's info folder