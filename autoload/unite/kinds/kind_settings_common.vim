let s:save_cpo = &cpo
set cpo&vim

function! unite#kinds#kind_settings_common#define()
	return s:kind_settings_common
endfunction

let s:kind_settings_common = { 
			\ 'name'           : 'kind_settings_common',
			\ 'default_action' : 'edit',
			\ 'action_table'   : {},
			\ }
let s:kind_settings_common.action_table.edit = {
			\ 'description'   : 'val setting',
			\ 'is_quit'       : 0,
			\ }
function! s:kind_settings_common.action_table.edit.func(candidate)  "{{{
	let valname    = a:candidate.action__valname
	let const_flg  = get(a:candidate, 'action__const_flg', 0)

	if const_flg == 1
		call unite#print_message("con't edit")
		return
	endif

	" íËã`Ç≥ÇÍÇƒÇ¢Ç»Ç¢èÍçáÇÕÅAí«â¡Ç∑ÇÈ
	if !exists(valname)

		call unite#print_message("not define!")
		
		let tmp_str = matchstr(valname, '.*\ze[.\{-}\]$')
		exe 'let type_ = type('.tmp_str.')'

		" Åö èâä˙ì¸óÕÇÃïœçX
		if type_ == type([])
			exe 'call add('.tmp_str.', 0)'
		elseif type_ == type({})
			exe 'let '.valname.' = 0'
		endif
	endif

	exe 'let str = string('.valname.')'
	let str = input(valname.' : ', str)

	if str !=# ""
		exe 'let '.valname.' = '.str

		" ex ÇÃê›íË
		let valname_ex = get(a:candidate, 'action__valname_ex', 0)
		if exists(valname_ex)
			exe 'let '.valname_ex.' = '.str
		endif
	endif

	call unite#force_redraw()
endfunction
"}}}
let s:kind_settings_common.action_table.edit_key = {
			\ 'description'   : 'key setting',
			\ 'is_quit'       : 0,
			\ }
function! s:kind_settings_common.action_table.edit_key.func(candidate)  "{{{
	let valname   = a:candidate.action__valname
	let const_flg = get(a:candidate, 'action__const_flg', 0)

	if const_flg == 1
		call unite#print_message("con't edit")
		return
	endif

	let dict_name = matchstr(valname, '.*\ze[.\{-}\]$')
	let key       = matchstr(valname, '.*[\zs.\{-}\ze\]$')

	exe 'let type_ = type('.dict_name.')'

	if type_ != type({})
		call unite#print_message("not dict")
		return
	endif

	echo dict_name
	let str = input(key.' : ', key)

	if str !=# "" && str !=# key
		let  cmd = 'let   '.dict_name.'['.str.'] = '.valname
		echo cmd
		exe  cmd

		let  cmd = 'unlet '.valname
		echo cmd
		exe  cmd
	endif

	call unite#force_redraw()
endfunction
"}}}
let s:kind_settings_common.action_table.delete = {
			\ 'description'   : 'delete ( kind_settings_common.vim ) ',
			\ 'is_quit'       : 0,
			\ }
function! s:kind_settings_common.action_table.delete.func(candidate)  "{{{

	let valname   = a:candidate.action__valname

	exe 'unlet '.valname

	call unite#force_redraw()
endfunction
"}}}
let s:kind_settings_common.action_table.preview = {
			\ 'description'   : 'preview',
			\ 'is_quit'       : 0,
			\ }
function! s:kind_settings_common.action_table.preview.func(candidate)  "{{{
	try
		let valname   = a:candidate.action__valname
		exe 'help '.valname
		wincmd p
	catch
		call unite#clear_message()
		call unite#print_message('can not find "'.valname.'" help.')
	endtry
endfunction
"}}}
let s:kind_settings_common.action_table.yank = {
			\ 'description'   : 'yank',
			\ 'is_quit'       : 0,
			\ 'is_selectable' : 1,
			\ }
function! s:kind_settings_common.action_table.yank.func(candidates)  "{{{
	let @" = ''
	for candidate in a:candidates
		exe 'let valname = "let ".candidate.action__valname." = ".string('.candidate.action__valname.')."\n"'
		let @" = @" . valname
	endfor
	echo @"
	let @* = @"
endfunction
"}}}
let s:kind_settings_common.action_table.yank_data = {
			\ 'description'   : 'yank data',
			\ 'is_quit'       : 0,
			\ 'is_selectable' : 1,
			\ }
function! s:kind_settings_common.action_table.yank_data.func(candidates)  "{{{
	let @" = ''
	let @* = ''
	for candidate in a:candidates
		exe "let data = 'let ".candidate.action__valname." = '.string(".candidate.action__valname.").'\n'"
		let @" = @" . data
	endfor
	echo @"
	let @* = @"
endfunction
"}}}

call unite#define_kind( s:kind_settings_common )

let &cpo = s:save_cpo
unlet s:save_cpo
