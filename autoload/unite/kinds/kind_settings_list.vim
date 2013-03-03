let s:save_cpo = &cpo
set cpo&vim

let unite_setting2#kind = { 
			\ 'name'           : 'kind_settings_list',
			\ 'default_action' : 'select',
			\ 'action_table'   : {},
			\ 'parents': ['kind_settings_common'],
			\ }
let unite_setting2#kind.action_table.select = {
			\ 'description' : 'select',
			\ 'is_quit'     : 0,
			\ }
function! unite_setting2#kind.action_table.select.func(candidate) "{{{
	let valname = a:candidate.action__valname
	call unite#start_temporary([['settings_var', valname]])
endfunction "}}}
let unite_setting2#kind.action_table.select_all = {
			\ 'description' : 'select_all',
			\ 'is_quit'     : 0,
			\ }
function! unite_setting2#kind.action_table.select_all.func(candidate) "{{{
	let valname = a:candidate.action__valname
	call unite#start_temporary([['settings_var_all', valname]])
endfunction "}}}

let &cpo = s:save_cpo
unlet s:save_cpo
