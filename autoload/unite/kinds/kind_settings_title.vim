let s:save_cpo = &cpo
set cpo&vim
setl enc=utf8

function! unite#kinds#kind_settings_title#define()
	return s:kind
endfunction


" p4_settings.vim で使用する
let s:kind = { 
			\ 'name'           : 'k_title',
			\ 'default_action' : 'a_null',
			\ 'action_table'   : {},
			\ 'is_quit'        : 0,
			\ }

let s:kind.action_table.a_null = {
			\ 'description' : 'none',
			\ 'is_quit' : 0,
			\ }
function! s:kind.action_table.a_null.func(candidate) "{{{
endfunction "}}}

let &cpo = s:save_cpo
unlet s:save_cpo

