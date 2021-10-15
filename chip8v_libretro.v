module emulator

import libretrov as l
import chip8

#include <stdio.h>
#include <string.h>
#include <stdlib.h>

const (
	width  = 64
	height = 32
	pixels = 2048
)

struct LibretroCore {
mut:
	framebuffer    [2048]byte
	log_cb         l.Retro_log_printf_t
	environ_cb     l.Retro_environment_t
	video_cb       l.Retro_video_refresh_t
	input_poll_cb  l.Retro_input_poll_t
	input_state_cb l.Retro_input_state_t
	audio_cb       l.Retro_audio_sample_t
	audio_batch_cb l.Retro_audio_sample_batch_t
	cpu            chip8.CPU
}

__global (
	core LibretroCore
)

[export: 'retro_api_version']
pub fn retro_api_version() u32 {
	return l.retro_api_version
}

[export: 'retro_cheat_reset']
pub fn retro_cheat_reset() {}

[export: 'retro_cheat_set']
pub fn retro_cheat_set(index u32, enable bool, core &char) {}

[export: 'retro_load_game']
pub fn retro_load_game(info &C.retro_game_info) bool {
	core.cpu.reset()
	core.cpu.load_cart(string(info.path))
	return true
}

[export: 'retro_load_game_special']
pub fn retro_load_game_special(game_type u32, info &C.retro_game_info, num_info usize) bool {
	return false
}

[export: 'retro_get_region']
pub fn retro_get_region() u32 {
	return u32(l.retro_region_pal)
}

[export: 'retro_get_memory_data']
pub fn retro_get_memory_data(id u32) voidptr {
	return C.NULL
}

[export: 'retro_get_memory_size']
pub fn retro_get_memory_size(id u32) usize {
	return usize(0)
}

[export: 'retro_set_controller_port_device']
pub fn retro_set_controller_port_device(port u32, device u32) {}

[export: 'retro_init']
pub fn retro_init() {
	level := 4

	// the performance level is guide to frontend to give an idea of how intensive this core is to run
	core.environ_cb(u32(l.retro_environment_set_performance_level), &level)
}

[export: 'retro_serialize_size']
pub fn retro_serialize_size() usize {
	return usize(0)
}

[export: 'retro_serialize']
pub fn retro_serialize(mut data voidptr, size usize) bool {
	return false
}

[export: 'retro_unserialize']
pub fn retro_unserialize(data voidptr, size usize) bool {
	return false
}

[export: 'retro_get_system_info']
pub fn retro_get_system_info(mut info C.retro_system_info) {
	info.library_name = 'chip8-v'.str
	info.library_version = '0.1.0'.str
	info.need_fullpath = true
	info.valid_extensions = 'ch8|c8'.str
}

[export: 'retro_get_system_av_info']
pub fn retro_get_system_av_info(mut info C.retro_system_av_info) {
	pixel_format := l.Retro_pixel_format.retro_pixel_format_xrgb8888
	unsafe { C.memset(info, 0, sizeof(info)) }
	info.timing.fps = 60.0
	info.timing.sample_rate = 44100
	info.geometry.base_width = emulator.width
	info.geometry.base_height = emulator.height
	info.geometry.max_width = emulator.width
	info.geometry.max_height = emulator.height
	info.geometry.aspect_ratio = emulator.width / emulator.height
	core.environ_cb(u32(l.retro_environment_set_pixel_format), &pixel_format)
}

[export: 'retro_set_environment']
pub fn retro_set_environment(cb l.Retro_environment_t) {
	core.environ_cb = cb
	no_rom := false
	cb(u32(l.retro_environment_set_support_no_game), &no_rom)
}

[export: 'retro_unload_game']
pub fn retro_unload_game() {
}

[export: 'retro_deinit']
pub fn retro_deinit() {
}

[export: 'retro_set_video_refresh']
pub fn retro_set_video_refresh(cb l.Retro_video_refresh_t) {
	core.video_cb = cb
}

[export: 'retro_run']
pub fn retro_run() {
	core.cpu.interpret()
	//if core.cpu.update_screen == true {
		for y in 0 .. 32 {
			for x in 0 .. 64 {
			if core.cpu.vram[y][x] == 0 {
				core.framebuffer[x + y * 64] = 0x00
			} else {
				core.framebuffer[x + y * 64] = 0xFF
			}
			}
		}
		core.cpu.update_screen = false
	//}
	core.video_cb(voidptr(&core.framebuffer), emulator.width, emulator.height, emulator.width << 2)
}

[export: 'retro_reset']
pub fn retro_reset() {
}

[export: 'retro_set_audio_sample_batch']
pub fn retro_set_audio_sample_batch(cb l.Retro_audio_sample_batch_t) {}

[export: 'retro_set_audio_sample']
pub fn retro_set_audio_sample(cb l.Retro_audio_sample_t) {
	core.audio_cb = cb
}

[export: 'retro_set_input_poll']
pub fn retro_set_input_poll(cb l.Retro_input_poll_t) {
	core.input_poll_cb = cb
}

[export: 'retro_set_input_state']
pub fn retro_set_input_state(cb l.Retro_input_state_t) {
	core.input_state_cb = cb
}
