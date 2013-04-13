let s:save_cpo = &cpo
set cpo&vim

function! unite#kinds#kind_settings_ex_list_select#define()
	return s:kind_settings_ex_list_select
endfunction
let s:kind_settings_ex_list_select = { 
			\ 'name'           : 'settings_ex_list_select',
			\ 'default_action' : 'a_toggles',
			\ 'action_table'   : {},
			\ 'parents': ['kind_settings_ex_common'],
			\ }
let s:kind_settings_ex_list_select.action_table.a_toggles = {
			\ 'is_selectable' : 1,
			\ 'description' : 'İ’è‚ÌØ‘Ö ( •¡”‘I‘ğ‰Â”\ )',
			\ 'is_quit'        : 0,
			\ }
let s:kind_settings_ex_list_select.action_table.a_toggles.func 
			\ = function("unite_setting_ex2#select_list_toggle")

let s:kind_settings_ex_list_select.action_table.a_toggle = {
			\ 'description' : 'İ’è‚ÌØ‘Ö',
			\ 'is_quit'        : 0,
			\ }
let s:kind_settings_ex_list_select.action_table.a_toggle.func 
			\ = function("unite_setting_ex2#select_list_toggle")

let s:kind_settings_ex_list_select.action_table.delete = {
			\ 'is_selectable' : 1,
			\ 'description'   : 'delete',
			\ 'is_quit'        : 0,
			\ }
function! s:kind_settings_ex_list_select.action_table.delete.func(candidates) "{{{

	" ‰Šú‰»
	let valname_ex = a:candidates[0].action__valname_ex
	let kind       = a:candidates[0].action__kind
	let dict_name  = a:candidates[0].action__dict_name
	let nums       = map(copy(a:candidates), 'v:val.action__num')

	" íœ‚·‚é
	call unite_setting_ex2#delete(dict_name, valname_ex, kind, nums)

	call unite_setting_ex2#common_out(dict_name)
endfunction
"}}}

let &cpo = s:save_cpo
unlet s:save_cpo
