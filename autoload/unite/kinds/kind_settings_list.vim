let s:save_cpo = &cpo
set cpo&vim
function! unite#kinds#kind_settings_list#define()
	return s:kind_settings_list
endfunction

let s:kind_settings_list = { 
			\ 'name'           : 'kind_settings_list',
			\ 'default_action' : 'select',
			\ 'action_table'   : {},
			\ 'parents': ['kind_settings_common'],
			\ }
let s:kind_settings_list.action_table.select = {
			\ 'description' : 'select',
			\ 'is_quit'     : 0,
			\ }
function! s:kind_settings_list.action_table.select.func(candidate) "{{{
	let valname = a:candidate.action__valname
	call unite#start_temporary([['settings', valname]])
endfunction
"}}}
let s:kind_settings_list.action_table.select_all = {
			\ 'description' : 'select_all',
			\ 'is_quit'     : 0,
			\ }
function! s:kind_settings_list.action_table.select_all.func(candidate) "{{{
	let valname = a:candidate.action__valname
	call unite#start_temporary([['settings_all', valname]])
endfunction
"}}}

let &cpo = s:save_cpo
unlet s:save_cpo
