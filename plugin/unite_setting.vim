let s:valname_to_source_kind_tabel = {
			\ type(0)              : 'kind_settings_common',
			\ type("")             : 'kind_settings_common',
			\ type(function("tr")) : 'kind_settings_common',
			\ type(0.0)            : 'kind_settings_common',
			\ type([])             : 'kind_settings_list',
			\ type({})             : 'kind_settings_list',
			\ }

"s:source_tmpl "{{{
let s:source_tmpl = {
			\ 'description' : 'show var',
			\ 'syntax'      : 'uniteSource__settings',
			\ 'hooks'       : {},
			\ 'is_quit'     : 0,
			\ }
let s:source_tmpl.hooks.on_syntax = function("unite_setting#sub_setting_syntax")
function! s:source_tmpl.hooks.on_init(args, context) "{{{
	let a:context.source__valname = get(a:args, 0, 'g:')
endfunction "}}}
function! s:source_tmpl.change_candidates(args, context) "{{{

	let new_    = a:context.input
	let valname = a:context.source__valname
	exe 'let type = type('.valname.')'

	if type == type([])
		exe 'let tmps = type('.valname.') ? '.valname.' : []'
		let num_ = len(tmps)
		let valname = valname.'['.num_.']'
	elseif type == type({})
		let valname = valname.'['''.new_.''']'
	endif


	let rtns = []
	if new_ != ''
		let rtns = [{
					\ 'word' : printf("[add]%45s : %s", valname, new_),
					\ 'kind' : 'kind_settings_common',
					\ 'action__valname'   : valname,
					\ 'action__new'   : new_
					\ }]
	endif

	return rtns

endfunction "}}}
"}}}
function! s:get_source_kind(valname) "{{{
	exe 'let tmp = '.a:valname
	return s:valname_to_source_kind_tabel[type(tmp)]
endfunction "}}}
function! s:get_source_word(valname) "{{{
	exe 'let tmp = '.a:valname
	return printf("%-100s : %s", a:valname, string(tmp))
endfunction "}}}
function! s:get_valnames(valname) "{{{
	exe 'let tmp = '.a:valname
	if a:valname == 'g:'
		let valnames = map(keys(tmp),
					\ "'g:'.v:val")
	elseif type([]) == type(tmp)
		let valnames = map(range(len(tmp)),
					\ "a:valname.'['.v:val.']'")
	elseif type({}) == type(tmp)
		let valnames = map(keys(tmp),
					\ "a:valname.'['''.v:val.''']'")
	else
		let valnames = []
	endif

	return valnames
endfunction "}}}
function! s:insert_list(list1, list2, num_) "{{{
	exe 'let tmps = a:list1[0:'.a:num_.'] + a:list2 + a:list1['.(a:num_+1).':]'
	return tmps
endfunction "}}}

" s:kind_settings_common "{{{
let s:kind = { 
			\ 'name'           : 'kind_settings_common',
			\ 'default_action' : 'edit',
			\ 'action_table'   : {},
			\ }
"let s:kind.action_table.edit = { "{{{
let s:kind.action_table.edit = {
			\ 'description'   : 'val setting',
			\ 'is_quit'       : 0,
			\ }
function! s:kind.action_table.edit.func(candidate) 
	let valname   = a:candidate.action__valname

	if !exists(valname)
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
	endif

	call unite#force_redraw()
endfunction
"}}}
"let s:kind.action_table.delete = { "{{{
let s:kind.action_table.delete = {
			\ 'description'   : 'delete',
			\ 'is_quit'       : 0,
			\ }
function! s:kind.action_table.delete.func(candidate) 

	let valname   = a:candidate.action__valname

	exe 'unlet '.valname

	call unite#force_redraw()
endfunction
"}}}
"let s:kind.action_table.preview = { "{{{
let s:kind.action_table.preview = {
			\ 'description'   : 'preview',
			\ 'is_quit'       : 0,
			\ }
function! s:kind.action_table.preview.func(candidate) 
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
"let s:kind.action_table.yank = { "{{{
let s:kind.action_table.yank = {
			\ 'description'   : 'yank',
			\ 'is_quit'       : 0,
			\ 'is_selectable' : 1,
			\ }
function! s:kind.action_table.yank.func(candidates) 
	let @" = ''
	let @* = ''
	for candidate in a:candidates
		let valname   = candidate.action__valname."\n"

		let @" = @" . valname

		if has('clipboard')
			let @* = @* . valname
		endif
	endfor
	echo @"
endfunction
"}}}
"let s:kind.action_table.yank_data = { "{{{
let s:kind.action_table.yank_data = {
			\ 'description'   : 'yank data',
			\ 'is_quit'       : 0,
			\ 'is_selectable' : 1,
			\ }
function! s:kind.action_table.yank_data.func(candidates) 
	let @" = ''
	let @* = ''
	for candidate in a:candidates
		exe 'let data = '.string(a:candidate.action__valname)."\n"

		let @" = @" . data

		if has('clipboard')
			let @* = @* . data
		endif
	endfor
	echo @"
endfunction
"}}}
let s:kind_settings_common = deepcopy(s:kind)
"}}}
"s:kind_settings_list "{{{
let s:kind = { 
			\ 'name'           : 'kind_settings_list',
			\ 'default_action' : 'select',
			\ 'action_table'   : {},
			\ 'parents': ['kind_settings_common'],
			\ }
"let s:kind.action_table.select = { "{{{
let s:kind.action_table.select = {
			\ 'description' : 'select',
			\ 'is_quit'     : 0,
			\ }
function! s:kind.action_table.select.func(candidate)
	let valname = a:candidate.action__valname
	call unite#start_temporary([['settings_var', valname]])
endfunction "}}}
"let s:kind.action_table.select_all = { "{{{
let s:kind.action_table.select_all = {
			\ 'description' : 'select_all',
			\ 'is_quit'     : 0,
			\ }
function! s:kind.action_table.select_all.func(candidate)
	let valname = a:candidate.action__valname
	call unite#start_temporary([['settings_var_all', valname]])
endfunction "}}}
let s:kind_settings_list = deepcopy(s:kind)
"}}}
let s:source_settings_var = deepcopy(s:source_tmpl) "{{{
let s:source_settings_var.name        = 'settings_var'
function! s:source_settings_var.gather_candidates(args, context) "{{{

	let valname = a:context.source__valname

	call unite#print_source_message(valname, self.name)

	let valnames = s:get_valnames(valname)

	return map( copy(valnames), "{
				\ 'word'              : s:get_source_word(v:val),
				\ 'kind'              : s:get_source_kind(v:val),
				\ 'action__valname'   : v:val,
				\ }")

endfunction "}}}
"}}}
let s:source_settings_var_all = deepcopy(s:source_tmpl) "{{{
let s:source_settings_var_all.name        = 'settings_var_all'
function! s:source_settings_var_all.gather_candidates(args, context) "{{{

	let valname = a:context.source__valname

	call unite#print_source_message(valname, self.name)

	let num_     = 0
	let valnames = [valname]

	while num_ < len(valnames)
		let tmps = s:get_valnames(valnames[num_])

		if len(tmps) > 0
			let valnames = s:insert_list(valnames, tmps, num_)
			unlet valnames[num_]
		else
			let num_ = num_ + 1
		endif

	endwhile

	return map(copy(valnames), "{
				\ 'word'              : s:get_source_word(v:val),
				\ 'kind'              : s:get_source_kind(v:val),
				\ 'action__valname'   : v:val,
				\ }")

endfunction "}}}
"}}}

call unite#define_source ( s:source_settings_var      ) | unlet s:source_settings_var
call unite#define_source ( s:source_settings_var_all  ) | unlet s:source_settings_var_all
call unite#define_kind   ( s:kind_settings_common     ) | unlet s:kind_settings_common     
call unite#define_kind   ( s:kind_settings_list       ) | unlet s:kind_settings_list       


