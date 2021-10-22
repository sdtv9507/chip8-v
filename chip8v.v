module main

import chip8
import gg
import gx
import os
import time
import math
import sokol.audio

const (
	m_pi = 3.14159265358979323846
)

struct App {
mut:
	gg    &gg.Context = 0
	scale int = 10
	cpu   chip8.CPU
	phase u32
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
	audio.setup(
		sample_rate: 44100
		num_channels: 1
		stream_userdata_cb: audio_callback
		user_data: app
	)
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
	// Has to be updated every frame
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
	time.sleep(2 * time.millisecond)
	app.gg.end()
}

fn audio_callback(buffer &f32, num_frames int, num_channels int, mut app App) {
	if app.cpu.sound_timer > 0 {
		time := 0.0
		for i := 0; i < 735; i += 1 {
			unsafe {
				mut soundbuffer := buffer
				soundbuffer[i] = 0.5 * math.sinf(2.0 * math.pi * 440.0 * f32(time))
				time += 1.0 / 44100
			}
		}
	} else {
		for i := 0; i < 735; i += 1 {
			unsafe {
				mut soundbuffer := buffer
				soundbuffer[i] = -20
			}
		}
	}
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
			audio.shutdown()
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
