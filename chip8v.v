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
	cpu chip8.CPU
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
		user_data: app
	)
	app.cpu = chip8.CPU{}
	app.cpu.reset()
	if arg != "" {
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
	//if app.cpu.update_screen == true {
		mut x := 0
		mut y := 0
		for i in 0 .. 2048 {
			x = i % 64
			y = i / 32
			if app.cpu.vram[i] == 0 {
				app.gg.draw_rect(x * app.scale, y * app.scale, app.scale, app.scale, gx.black)
			} else {
				app.gg.draw_rect(x * app.scale, y * app.scale, app.scale, app.scale, gx.white)
			}
		}
		app.cpu.update_screen = false
	//}
	time.sleep(16 * time.millisecond)
	app.gg.end()
}
