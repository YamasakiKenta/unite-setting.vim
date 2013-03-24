let s:save_cpo = &cpo
set cpo&vim
setl enc=utf8

function! unite#kinds#kind_settings_ex_bool#define()
	return [
				\ s:kind_settings_ex_bool,
				\ ]
endfunction

let s:kind_settings_ex_bool = { 
			\ 'name'           : 'kind_settings_ex_bool',
			\ 'default_action' : 'a_toggle',
			\ 'action_table'   : {},
			\ 'parents': ['kind_settings_ex_common'],
			\ }
let s:kind_settings_ex_bool.action_table.a_toggle = {
			\ 'is_selectable' : 1,
			\ 'description'   : '設定の切替',
			\ 'is_quit'       : 0,
			\ }
function! s:kind_settings_ex_bool.action_table.a_toggle.func(candidates) "{{{
	for candidate in a:candidates
		let dict_name  = candidate.action__dict_name
		let valname_ex = candidate.action__valname_ex
		let kind       = candidate.action__kind
		call unite_setting_ex2#set_next(dict_name, valname_ex, kind)
	endfor
	call unite_setting_ex2#common_out(dict_name)
endfunction 
"}}}

let &cpo = s:save_cpo
unlet s:save_cpo
