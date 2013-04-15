let s:save_cpo = &cpo
set cpo&vim

function! unite#kinds#kind_settings_ex_select#define()
	return s:kind_settings_ex_select
endfunction
let s:kind_settings_ex_select = { 
			\ 'name'           : 'kind_settings_ex_select',
			\ 'default_action' : 'a_toggle',
			\ 'action_table'   : {},
			\ 'parents': ['kind_settings_ex_common', 'kind_settings_common'],
			\ }
let s:kind_settings_ex_select.action_table.a_toggle = {
			\ 'description' : '‘I‘ð',
			\ 'is_quit'     : 0,
			\ }
function! s:kind_settings_ex_select.action_table.a_toggle.func(candidate) "{{{
	let dict_name  = a:candidate.action__dict_name
	let valname_ex = a:candidate.action__valname_ex
	let kind       = a:candidate.action__kind

	call unite_setting_ex2#set_next(dict_name, valname_ex, kind)
	call unite_setting_ex2#common_out(dict_name)
endfunction
"}}}
let s:kind_settings_ex_select.action_table.edit = {
			\ 'description' : 'edit',
			\ 'is_quit'     : 0,
			\ }
function! s:kind_settings_ex_select.action_table.edit.func(candidate) "{{{
	let tmp_d = {
				\ 'dict_name'    : a:candidate.action__dict_name,
				\ 'valname_ex'   : a:candidate.action__valname_ex,
				\ 'kind'         : a:candidate.action__kind,
				\ 'only_'        : 1,
				\ 'const_'       :
				\ unite_setting_ex2#get_const_flg(
				\ a:candidate.action__dict_name,
				\ a:candidate.action__valname_ex, 
				\ a:candidate.action__kind
				\ ),
				\ }

	call unite#start_temporary([['settings_ex_list_select', tmp_d]], {'default_action' : 'a_toggle'})
endfunction
"}}}

let &cpo = s:save_cpo
unlet s:save_cpo
