module main

import chip8
import os
import nsauzede.vsdl2

struct App {
mut:
	cpu      chip8.CPU
	scale    int = 10
	delay u32 = u32(16)
	window   voidptr
	renderer voidptr
	screen   &vsdl2.Surface
	texture  voidptr
	quit     bool
}

fn main() {
	mut arg := ''
	if os.args.len > 1 {
		arg = os.args[1]
	}
	title := 'Chip8-v'
	width := 640
	height := 320
	
	mut app := &App{
		screen: vsdl2.create_rgb_surface(0, width, height, 32, 0x00FF0000, 0x0000FF00,
			0x000000FF, 0xFF000000)
	}
	app.cpu = chip8.CPU{}
	app.cpu.reset()
	if arg != '' {
		app.cpu.load_cart(arg)
	} else {
		exit(0)
	}
	app.quit = false

	C.SDL_Init(C.SDL_INIT_VIDEO | C.SDL_INIT_AUDIO | C.SDL_INIT_JOYSTICK)
	C.atexit(C.SDL_Quit)
	vsdl2.create_window_and_renderer(width, height, 0, &app.window, &app.renderer)
	C.SDL_SetWindowTitle(app.window, title.str)
	app.texture = C.SDL_CreateTexture(app.renderer, C.SDL_PIXELFORMAT_XRGB8888, C.SDL_TEXTUREACCESS_STREAMING,
		width, height)
	
	for !app.quit {
		C.SDL_RenderClear(app.renderer)
		ev := vsdl2.Event{}
		poll_events(ev, mut app)
		loop_cpu(mut app)

		C.SDL_UpdateTexture(app.texture, 0, app.screen.pixels, app.screen.pitch)
		C.SDL_RenderClear(app.renderer)
		C.SDL_RenderCopy(app.renderer, app.texture, 0, 0)
		C.SDL_RenderPresent(app.renderer)
		vsdl2.delay(app.delay)
	}
}

fn loop_cpu(mut app App) {
	if app.cpu.keypad_wait == true {
		app.cpu.wait_for_key()
	} else {
		result := app.cpu.interpret()
		if result == false {
			app.quit = true
		}
	}
	
	if app.cpu.update_screen == true {
		for y in 0 .. 32 {
			for x in 0 .. 64 {
				mut rect := vsdl2.Rect{x * app.scale, y * app.scale, app.scale, app.scale}
				if app.cpu.vram[y][x] == 0 {
					color := vsdl2.Color{byte(0), byte(0), byte(0), byte(255)}
					vsdl2.fill_rect(app.screen, rect, color)
				} else {
					color := vsdl2.Color{byte(255), byte(255), byte(255), byte(255)}
					vsdl2.fill_rect(app.screen, rect, color)
				}
			}
		}
		app.cpu.update_screen = false
	}
}

fn poll_events(ev vsdl2.Event, mut app App) {
	for 0 < vsdl2.poll_event(&ev) {
		match int(unsafe { ev.@type }) {
			C.SDL_QUIT {
				app.quit = true
			}
			C.SDL_KEYDOWN {
				key := unsafe { ev.key.keysym.sym }
				app.key_down(key)
			}
			C.SDL_KEYUP {
				key := unsafe { ev.key.keysym.sym }
				app.key_up(key)
			}
			else {}
		}
	}
}

fn (mut app App) key_down(key int) {
	state := byte(1)
	match key {
		C.SDLK_ESCAPE {
			app.quit = true
		}
		C.SDLK_1 {
			app.cpu.set_key(0x1, state)
		}
		C.SDLK_2 {
			app.cpu.set_key(0x2, state)
		}
		C.SDLK_3 {
			app.cpu.set_key(0x3, state)
		}
		C.SDLK_4 {
			app.cpu.set_key(0xC, state)
		}
		C.SDLK_q {
			app.cpu.set_key(0x4, state)
		}
		C.SDLK_w {
			app.cpu.set_key(0x5, state)
		}
		C.SDLK_e {
			app.cpu.set_key(0x6, state)
		}
		C.SDLK_r {
			app.cpu.set_key(0xD, state)
		}
		C.SDLK_a {
			app.cpu.set_key(0x7, state)
		}
		C.SDLK_s {
			app.cpu.set_key(0x8, state)
		}
		C.SDLK_d {
			app.cpu.set_key(0x9, state)
		}
		C.SDLK_f {
			app.cpu.set_key(0xE, state)
		}
		C.SDLK_z {
			app.cpu.set_key(0xA, state)
		}
		C.SDLK_x {
			app.cpu.set_key(0x0, state)
		}
		C.SDLK_c {
			app.cpu.set_key(0xB, state)
		}
		C.SDLK_v {
			app.cpu.set_key(0xF, state)
		}
		C.SDLK_i {
			if app.delay < 60 {
				app.delay += 1
			}
		}
		C.SDLK_o {
			if app.delay > 1 {
				app.delay -= 1
			}
		}
		else {}
	}
}

fn (mut app App) key_up(key int) {
	state := byte(0)
	match key {
		C.SDLK_1 {
			app.cpu.set_key(0x1, state)
		}
		C.SDLK_2 {
			app.cpu.set_key(0x2, state)
		}
		C.SDLK_3 {
			app.cpu.set_key(0x3, state)
		}
		C.SDLK_4 {
			app.cpu.set_key(0xC, state)
		}
		C.SDLK_q {
			app.cpu.set_key(0x4, state)
		}
		C.SDLK_w {
			app.cpu.set_key(0x5, state)
		}
		C.SDLK_e {
			app.cpu.set_key(0x6, state)
		}
		C.SDLK_r {
			app.cpu.set_key(0xD, state)
		}
		C.SDLK_a {
			app.cpu.set_key(0x7, state)
		}
		C.SDLK_s {
			app.cpu.set_key(0x8, state)
		}
		C.SDLK_d {
			app.cpu.set_key(0x9, state)
		}
		C.SDLK_f {
			app.cpu.set_key(0xE, state)
		}
		C.SDLK_z {
			app.cpu.set_key(0xA, state)
		}
		C.SDLK_x {
			app.cpu.set_key(0x0, state)
		}
		C.SDLK_c {
			app.cpu.set_key(0xB, state)
		}
		C.SDLK_v {
			app.cpu.set_key(0xF, state)
		}
		else {}
	}
}
