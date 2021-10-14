module main

import gg
import gx
import os

struct App {
mut:
	gg    &gg.Context = 0
	scale int = 5
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
	app.gg.run()
}

fn frame(mut app App) {
	app.gg.begin()
	app.gg.draw_rect(10, 10, app.scale, app.scale, gx.white)
	app.gg.end()
}
