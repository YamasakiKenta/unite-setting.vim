let s:save_cpo = &cpo
set cpo&vim
setl enc=utf8

function! unite#kinds#kind_settings_ex_common#define()
	return s:kind_settings_ex_common
endfunction
let s:kind_settings_ex_common = { 
			\ 'name'           : 'kind_settings_ex_common',
			\ 'default_action' : 'a_toggle',
			\ 'action_table'   : {},
			\ 'parents': ['kind_settings_common'],
			\ }
let s:kind_settings_ex_common.action_table.set_select = {
			\ 'is_selectable' : 1,
			\ 'description'   : '',
			\ 'is_quit'       : 0,
			\ }
function! s:kind_settings_ex_common.action_table.set_select.func(candidates) "{{{
	for candidate in a:candidates
		let dict_name  = candidate.action__dict_name
		let valname_ex = candidate.action__valname_ex
		let kind       = candidate.action__kind

		call unite_setting_ex2#cnv_list_ex_select(dict_name, valname_ex, kind, 'select')


	endfor

	call unite_setting_ex2#common_out(dict_name)
endfunction 
"}}}
let s:kind_settings_ex_common.action_table.set_list_ex = {
			\ 'is_selectable' : 1,
			\ 'description'   : '',
			\ 'is_quit'       : 0,
			\ }
function! s:kind_settings_ex_common.action_table.set_list_ex.func(candidates) "{{{
	for candidate in a:candidates
		let dict_name  = candidate.action__dict_name
		let valname_ex = candidate.action__valname_ex
		let kind       = candidate.action__kind

		call unite_setting_ex2#cnv_list_ex_select(dict_name, valname_ex, kind, 'list_ex')

	endfor

	call unite_setting_ex2#common_out(dict_name)
endfunction 
"}}}
let s:kind_settings_ex_common.action_table.set_bool = {
			\ 'is_selectable' : 1,
			\ 'description'   : '',
			\ 'is_quit'       : 0,
			\ }
function! s:kind_settings_ex_common.action_table.set_bool.func(candidates) "{{{
	for candidate in a:candidates
		let dict_name  = candidate.action__dict_name
		let valname_ex = candidate.action__valname_ex
		let kind       = candidate.action__kind

		call unite_setting_ex2#set_type(dict_name, valname_ex, kind, 'bool')
	endfor

	call unite_setting_ex2#common_out(dict_name)
endfunction 
"}}}
let s:kind_settings_ex_common.action_table.set_var = {
			\ 'is_selectable' : 1,
			\ 'description'   : '',
			\ 'is_quit'       : 0,
			\ }
function! s:kind_settings_ex_common.action_table.set_var.func(candidates) "{{{
	for candidate in a:candidates
		let dict_name  = candidate.action__dict_name
		let valname_ex = candidate.action__valname_ex
		let kind       = candidate.action__kind

		call unite_setting_ex2#set_type(dict_name, valname_ex, kind, 'var')
	endfor

	call unite_setting_ex2#common_out(dict_name)
endfunction 
"}}}
let s:kind_settings_ex_common.action_table.set_list = {
			\ 'is_selectable' : 1,
			\ 'description'   : '',
			\ 'is_quit'       : 0,
			\ }
function! s:kind_settings_ex_common.action_table.set_list.func(candidates) "{{{
	for candidate in a:candidates
		let dict_name  = candidate.action__dict_name
		let valname_ex = candidate.action__valname_ex
		let kind       = candidate.action__kind

		call unite_setting_ex2#set_type(dict_name, valname_ex, kind, 'list')
	endfor

	call unite_setting_ex2#common_out(dict_name)
endfunction 
"}}}
let s:kind_settings_ex_common.action_table.yank = {
			\ 'description'   : 'yank',
			\ 'is_quit'       : 0,
			\ 'is_selectable' : 1,
			\ }
function! s:kind_settings_ex_common.action_table.yank.func(candidates) "{{{
	let @" = ''
	for candidate in a:candidates
		let dict_name  = candidate.action__dict_name
		let valname_ex = candidate.action__valname_ex
		let kind       = candidate.action__kind

		let data = 'let '.valname_ex.' = '.string(unite_setting_ex#get( dict_name, valname_ex, kind))."\n"
		let @" = @" . data

	endfor
	let @* = @"
	echo @"
endfunction
"}}}

let &cpo = s:save_cpo
unlet s:save_cpo
