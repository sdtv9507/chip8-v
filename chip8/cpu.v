module chip8
import os

pub const font = [
    0xF0, 0x90, 0x90, 0x90, 0xF0, 0x20, 0x60, 0x20, 0x20, 0x70, 0xF0, 0x10, 0xF0, 0x80, 0xF0, 0xF0,
    0x10, 0xF0, 0x10, 0xF0, 0x90, 0x90, 0xF0, 0x10, 0x10, 0xF0, 0x80, 0xF0, 0x10, 0xF0, 0xF0, 0x80,
    0xF0, 0x90, 0xF0, 0xF0, 0x10, 0x20, 0x40, 0x40, 0xF0, 0x90, 0xF0, 0x90, 0xF0, 0xF0, 0x90, 0xF0,
    0x10, 0xF0, 0xF0, 0x90, 0xF0, 0x90, 0x90, 0xE0, 0x90, 0xE0, 0x90, 0xE0, 0xF0, 0x80, 0x80, 0x80,
    0xF0, 0xE0, 0x90, 0x90, 0x90, 0xE0, 0xF0, 0x80, 0xF0, 0x80, 0xF0, 0xF0, 0x80, 0xF0, 0x80, 0x80,
]

pub struct CPU {
pub mut:
	registers [16]byte
	memory [4096]byte
    address_register u16
    program_counter usize
    delay_timer byte
    sound_timer byte
    keypad [16]byte
    stack [16]usize
    stack_pointer usize
    vram [2048]byte
    update_screen bool
    keypad_wait bool
    keypad_reg usize
}

pub fn (mut cpu CPU) reset() {
    cpu.address_register = u16(0)
    cpu.program_counter = usize(0)
    cpu.delay_timer = 0
    cpu.sound_timer = 0
    cpu.stack_pointer = 0
    cpu.update_screen = false
    cpu.keypad_wait = false
    cpu.keypad_reg = 0
}

pub fn (mut cpu CPU) load_cart(path string) {
    data := os.read_bytes(path) or { panic(err) }
    value := 0
    for i in data {
        cpu.memory[value+0x200] = i
    }
    for i in 0 .. 80 {
        cpu.memory[i] = byte(font[i])
    }
}