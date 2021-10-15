module main

import chip8
import gg
import gx
import os
import time

struct App {
mut:
	gg    &gg.Context = 0
	scale int = 10
	cpu   chip8.CPU
}

fn main() {
	mut arg := ''
	if os.args.len > 1 {
		arg = os.args[1]
	}
	mut app := &App{}
	app.gg = gg.new_context(
		width: 640
		height: 320
		create_window: true
		window_title: 'Chip-8'
		frame_fn: frame
		event_fn: on_event
		user_data: app
	)
	app.cpu = chip8.CPU{}
	app.cpu.reset()
	if arg != '' {
		app.cpu.load_cart(arg)
	} else {
		exit(0)
	}
	app.gg.run()
}

fn frame(mut app App) {
	app.gg.begin()
	if app.cpu.keypad_wait == true {
		app.cpu.wait_for_key()
	} else {
		result := app.cpu.interpret()
		if result == false {
			exit(0)
		}
	}
	//Has to be updated every frame
	// if app.cpu.update_screen == true {
	for y in 0 .. 32 {
		for x in 0 .. 64 {
			if app.cpu.vram[y][x] == 0 {
				app.gg.draw_rect(x * app.scale, y * app.scale, app.scale, app.scale, gx.black)
			} else {
				app.gg.draw_rect(x * app.scale, y * app.scale, app.scale, app.scale, gx.white)
			}
		}
	}
	app.cpu.update_screen = false
	//}
	time.sleep(16 * time.millisecond)
	app.gg.end()
}

fn on_event(e &gg.Event, mut app App) {
	if e.typ == .key_down {
		app.key_down(e.key_code)
	} else if e.typ == .key_up {
		app.key_up(e.key_code)
	}
}

fn (mut app App) key_down(key gg.KeyCode) {
	state := byte(1)
	match key {
		.escape {
			exit(0)
		}
		._1 {
			app.cpu.set_key(0x1, state)
		}
		._2 {
			app.cpu.set_key(0x2, state)
		}
		._3 {
			app.cpu.set_key(0x3, state)
		}
		._4 {
			app.cpu.set_key(0xC, state)
		}
		.q {
			app.cpu.set_key(0x4, state)
		}
		.w {
			app.cpu.set_key(0x5, state)
		}
		.e {
			app.cpu.set_key(0x6, state)
		}
		.r {
			app.cpu.set_key(0xD, state)
		}
		.a {
			app.cpu.set_key(0x7, state)
		}
		.s {
			app.cpu.set_key(0x8, state)
		}
		.d {
			app.cpu.set_key(0x9, state)
		}
		.f {
			app.cpu.set_key(0xE, state)
		}
		.z {
			app.cpu.set_key(0xA, state)
		}
		.x {
			app.cpu.set_key(0x0, state)
		}
		.c {
			app.cpu.set_key(0xB, state)
		}
		.v {
			app.cpu.set_key(0xF, state)
		}
		else {}
	}
}

fn (mut app App) key_up(key gg.KeyCode) {
	state := byte(0)
	match key {
		._1 {
			app.cpu.set_key(0x1, state)
		}
		._2 {
			app.cpu.set_key(0x2, state)
		}
		._3 {
			app.cpu.set_key(0x3, state)
		}
		._4 {
			app.cpu.set_key(0xC, state)
		}
		.q {
			app.cpu.set_key(0x4, state)
		}
		.w {
			app.cpu.set_key(0x5, state)
		}
		.e {
			app.cpu.set_key(0x6, state)
		}
		.r {
			app.cpu.set_key(0xD, state)
		}
		.a {
			app.cpu.set_key(0x7, state)
		}
		.s {
			app.cpu.set_key(0x8, state)
		}
		.d {
			app.cpu.set_key(0x9, state)
		}
		.f {
			app.cpu.set_key(0xE, state)
		}
		.z {
			app.cpu.set_key(0xA, state)
		}
		.x {
			app.cpu.set_key(0x0, state)
		}
		.c {
			app.cpu.set_key(0xB, state)
		}
		.v {
			app.cpu.set_key(0xF, state)
		}
		else {}
	}
}
