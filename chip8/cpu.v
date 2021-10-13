module chip8
import os
import rand

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

pub fn (cpu CPU) get_instruction() u16 {
    lo := u16(cpu.memory[cpu.program_counter])
    hi := u16(cpu.memory[cpu.program_counter + 1])
    return u16((lo << 8) | hi)
}

pub fn (mut cpu CPU) interpret() {
    if cpu.delay_timer > 0 {
        cpu.delay_timer -= 1
    }
    if cpu.sound_timer > 0 {
        cpu.sound_timer -= 1
    }
    mut skip_instruction := false
    mut jump := false
    instruction := cpu.get_instruction()
    reg_x := usize((instruction & 0x0F00) >> 8)
    reg_y := usize((instruction & 0x00F0) >> 4)
    reg_n := usize(instruction & 0x000F)
    match instruction & 0xF000 {
        0x0000 {
            match instruction & 0x0FFF {
                0x00E0 {
                    for i in 0 .. 2048 {
                        cpu.vram[i] = 0
                    }
                }
                0x00EE {
                    cpu.stack_pointer -= 1
                    cpu.program_counter = usize(cpu.stack[cpu.stack_pointer])
                    jump = true
                }
                else {
                    //Do nothing
                }
            }
        }
        0x1000 {
            cpu.program_counter = (instruction & 0x0FFF)
            jump = true
        }
        0x2000 {
            cpu.stack[cpu.stack_pointer] = cpu.program_counter+2
            cpu.stack_pointer += 1
            cpu.program_counter = usize(instruction & 0x0FFF)
            jump = true
        }
        0x3000 {
            value := byte(instruction & 0x00FF)
            if cpu.registers[reg_x] == value {
                skip_instruction = true
            }
        }
        0x4000 {
            value := byte(instruction & 0x00FF)
            if cpu.registers[reg_x] != value {
                skip_instruction = true
            }
        }
        0x5000 {
            if cpu.registers[reg_x] == cpu.registers[reg_y] {
                skip_instruction = true
            }
        }
        0x6000 {
            value := byte(instruction & 0x00FF)
            cpu.registers[reg_x] = value
        }
        0x7000 {
            value := byte(instruction & 0x00FF)
            cpu.registers[reg_x] = byte(cpu.registers[reg_x] + value)
        }
        0x8000 {
            match reg_n {
                0x0000 {
                    cpu.registers[reg_x] = cpu.registers[reg_y]
                }
                0x0001 {
                    cpu.registers[reg_x] = cpu.registers[reg_x] | cpu.registers[reg_y]
                }
                0x0002 {
                    cpu.registers[reg_x] = cpu.registers[reg_x] & cpu.registers[reg_y]
                }
                0x0003 {
                    cpu.registers[reg_x] = cpu.registers[reg_x] ^ cpu.registers[reg_y]
                }
                0x0004 {
                    result := cpu.registers[reg_x] + cpu.registers[reg_y]
                    if result > 255 {
                        cpu.registers[0xF] = 1
                    }
                    else {
                        cpu.registers[0xF] = 0
                    }
                    cpu.registers[reg_x] = byte(result)
                }
                0x0005 {
                    result := cpu.registers[reg_x] - cpu.registers[reg_y]
                    if cpu.registers[reg_x] > cpu.registers[reg_y] {
                        cpu.registers[0xF] = 1
                    }
                    else {
                        cpu.registers[0xF] = 0
                    }
                    cpu.registers[reg_x] = byte(result)
                }
                0x0006 {
                    cpu.registers[0xF] = cpu.registers[reg_x] & 1
                    cpu.registers[reg_x] = cpu.registers[reg_x] >> 1
                }
                0x0007 {
                    result := cpu.registers[reg_y] - cpu.registers[reg_x]
                    if cpu.registers[reg_y] > cpu.registers[reg_x] {
                        cpu.registers[0xF] = 1
                    }
                    else {
                        cpu.registers[0xF] = 0
                    }
                    cpu.registers[reg_x] = byte(result)
                }
                0x000E {
                    cpu.registers[0xF] = (cpu.registers[reg_x] & 0b10000000) >> 7
                    cpu.registers[reg_x] = cpu.registers[reg_x] << 1
                }
                else {
                    //do nothing
                }
            }
        }
        0x9000 {
            if cpu.registers[reg_x] != cpu.registers[reg_y] {
                skip_instruction = true
            }
        }
        0xA000 {
            cpu.address_register = instruction & 0x0FFF
        }
        0xB000 {
                cpu.program_counter = usize(instruction & 0x0FFF)
                cpu.program_counter = usize(cpu.program_counter + cpu.registers[0])
                jump = true
            }
        0xC000 {
                num := rand.byte()
                cpu.registers[reg_x] = num & byte(instruction & 0x00FF)
            }
        0xD000 {
            mut x := usize(0)
            mut y := usize(0)
            cpu.registers[0xF] = 0
            for i in 0 .. reg_n {
                y = cpu.registers[reg_y] + i
                y %= 32
                data := byte(cpu.memory[cpu.address_register + i])
                for x_pos in 0 .. 8 {
                    x = cpu.registers[reg_x] + x_pos
                    x %= 64
                    color := (data >> (7 - x_pos)) & 1
                    position := x + y * 32
                    if color & cpu.vram[position] == 1 {
                        cpu.registers[0xF] = 1
                    }
                    cpu.vram[position] ^= color
                }
            }
        }
        0xE000 {
            match instruction & 0x00FF {
                0x009E {
                    if cpu.keypad[usize(cpu.registers[reg_x])] == 1 {
                        skip_instruction = true
                    }
                }
                0x00A1 {
                    if cpu.keypad[usize(cpu.registers[reg_x])] == 0 {
                        skip_instruction = true
                    }
                }
                else {
                    //do nothing
                }
            }
        }
        0xF000 {
            match instruction & 0x00FF {
                0x0007 {
                    cpu.registers[reg_x] = cpu.delay_timer
                }
                0x000A {
                    cpu.keypad_wait = true
                    cpu.keypad_reg = usize(reg_x)
                }
                0x0015 {
                    cpu.delay_timer = cpu.registers[reg_x]
                }
                0x0018 {
                    cpu.sound_timer = cpu.registers[reg_x]
                }
                0x001E {
                    cpu.address_register =u16(cpu.address_register + cpu.registers[reg_x])
                }
                0x0029 {
                    cpu.address_register = u16(cpu.registers[reg_x] * 5)
                }
                0x0033 {
                    cpu.memory[usize(cpu.address_register)] = cpu.registers[reg_x] / 100
                    cpu.memory[usize(cpu.address_register + 1)] =
                        (cpu.registers[reg_x] % 100) / 10
                    cpu.memory[usize(cpu.address_register + 2)] = cpu.registers[reg_x] % 10
                }
                0x0055 {
                    for i in 0..reg_x+1 {
                        cpu.memory[usize(cpu.address_register) + i] = cpu.registers[i]
                    }
                }
                0x0065 {
                    for i in 0..reg_x+1 {
                        cpu.registers[i] = cpu.memory[usize(cpu.address_register) + i]
                    }
                }
                else {
                    //do nothing
                }
            }
        }
        else {
            //do nothing
        }
    }
    if skip_instruction == true && jump == false {
        cpu.program_counter += 4
    } else if jump == false {
        cpu.program_counter += 2
    }
    if cpu.program_counter >= 4096 {
    }
}