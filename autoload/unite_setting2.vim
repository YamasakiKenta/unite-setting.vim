let s:save_cpo = &cpo
set cpo&vim

let unite_setting2#valname_to_source_kind_tabel = {
			\ type(0)              : 'kind_settings_common',
			\ type("")             : 'kind_settings_common',
			\ type(function("tr")) : 'kind_settings_common',
			\ type(0.0)            : 'kind_settings_common',
			\ type([])             : 'kind_settings_list',
			\ type({})             : 'kind_settings_list',
			\ }

"unite_setting2#source_tmpl "{{{
let unite_setting2#source_tmpl = {
			\ 'description' : 'show var',
			\ 'syntax'      : 'uniteSource__settings',
			\ 'hooks'       : {},
			\ 'is_quit'     : 0,
			\ }
let unite_setting2#source_tmpl.hooks.on_syntax = function("unite_setting#sub_setting_syntax")
function! unite_setting2#source_tmpl.hooks.on_init(args, context) "{{{
	let a:context.source__valname = get(a:args, 0, 'g:')
endfunction "}}}
function! unite_setting2#source_tmpl.change_candidates(args, context) "{{{

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
function! unite_setting2#get_source_kind(valname) "{{{
	exe 'let Tmp = '.a:valname
	return unite_setting2#valname_to_source_kind_tabel[type(Tmp)]
endfunction "}}}
function! unite_setting2#get_source_word(valname) "{{{
	exe 'let Tmp = '.a:valname
	return printf("%-100s : %s", a:valname, string(Tmp))
endfunction "}}}
function! unite_setting2#get_valnames(valname) "{{{
	exe 'let Tmp = '.a:valname
	if a:valname == 'g:'
		let valnames = map(keys(Tmp),
					\ "'g:'.v:val")
	elseif type([]) == type(Tmp)
		let valnames = map(range(len(Tmp)),
					\ "a:valname.'['.v:val.']'")
	elseif type({}) == type(Tmp)
		let valnames = map(keys(Tmp),
					\ "a:valname.'['''.v:val.''']'")
	else
		let valnames = []
	endif

	return valnames
endfunction "}}}
function! unite_setting2#insert_list(list1, list2, num_) "{{{
	exe 'let tmps = a:list1[0:'.a:num_.'] + a:list2 + a:list1['.(a:num_+1).':]'
	return tmps
endfunction "}}}


"
" unite_setting2#kind_settings_common "{{{
let unite_setting2#kind = { 
			\ 'name'           : 'kind_settings_common',
			\ 'default_action' : 'edit',
			\ 'action_table'   : {},
			\ }
"let unite_setting2#kind.action_table.edit = { "{{{
let unite_setting2#kind.action_table.edit = {
			\ 'description'   : 'val setting',
			\ 'is_quit'       : 0,
			\ }
function! unite_setting2#kind.action_table.edit.func(candidate) 
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
"let unite_setting2#kind.action_table.delete = { "{{{
let unite_setting2#kind.action_table.delete = {
			\ 'description'   : 'delete',
			\ 'is_quit'       : 0,
			\ }
function! unite_setting2#kind.action_table.delete.func(candidate) 

	let valname   = a:candidate.action__valname

	exe 'unlet '.valname

	call unite#force_redraw()
endfunction
"}}}
"let unite_setting2#kind.action_table.preview = { "{{{
let unite_setting2#kind.action_table.preview = {
			\ 'description'   : 'preview',
			\ 'is_quit'       : 0,
			\ }
function! unite_setting2#kind.action_table.preview.func(candidate) 
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
"let unite_setting2#kind.action_table.yank = { "{{{
let unite_setting2#kind.action_table.yank = {
			\ 'description'   : 'yank',
			\ 'is_quit'       : 0,
			\ 'is_selectable' : 1,
			\ }
function! unite_setting2#kind.action_table.yank.func(candidates) 
	let @" = ''
	for candidate in a:candidates
		exe 'let valname = "let ".candidate.action__valname." = ".string('.candidate.action__valname.')."\n"'
		let @" = @" . valname
	endfor
	echo @"
	let @* = @"
endfunction
"}}}
"let unite_setting2#kind.action_table.delete = { "{{{
let unite_setting2#kind.action_table.delete = {
			\ 'description'   : 'yank data',
			\ 'is_quit'       : 0,
			\ 'is_selectable' : 1,
			\ }
function! unite_setting2#kind.action_table.delete.func(candidates) 
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
let unite_setting2#kind_settings_common = deepcopy(unite_setting2#kind)
"}}}
"unite_setting2#kind_settings_list "{{{
let unite_setting2#kind = { 
			\ 'name'           : 'kind_settings_list',
			\ 'default_action' : 'select',
			\ 'action_table'   : {},
			\ 'parents': ['kind_settings_common'],
			\ }
"let unite_setting2#kind.action_table.select = { "{{{
let unite_setting2#kind.action_table.select = {
			\ 'description' : 'select',
			\ 'is_quit'     : 0,
			\ }
function! unite_setting2#kind.action_table.select.func(candidate)
	let valname = a:candidate.action__valname
	call unite#start_temporary([['settings_var', valname]])
endfunction "}}}
"let unite_setting2#kind.action_table.select_all = { "{{{
let unite_setting2#kind.action_table.select_all = {
			\ 'description' : 'select_all',
			\ 'is_quit'     : 0,
			\ }
function! unite_setting2#kind.action_table.select_all.func(candidate)
	let valname = a:candidate.action__valname
	call unite#start_temporary([['settings_var_all', valname]])
endfunction "}}}
let unite_setting2#kind_settings_list = deepcopy(unite_setting2#kind)
"}}}
let unite_setting2#source_settings_var = deepcopy(unite_setting2#source_tmpl) "{{{
let unite_setting2#source_settings_var.name        = 'settings_var'
function! unite_setting2#source_settings_var.gather_candidates(args, context) "{{{

	let valname = a:context.source__valname

	call unite#print_source_message(valname, self.name)

	let valnames = unite_setting2#get_valnames(valname)

	return map( copy(valnames), "{
				\ 'word'              : unite_setting2#get_source_word(v:val),
				\ 'kind'              : unite_setting2#get_source_kind(v:val),
				\ 'action__valname'   : v:val,
				\ }")

endfunction "}}}
"}}}
let unite_setting2#source_settings_var_all = deepcopy(unite_setting2#source_tmpl) "{{{
let unite_setting2#source_settings_var_all.name        = 'settings_var_all'
function! unite_setting2#source_settings_var_all.gather_candidates(args, context) "{{{

	let valname = a:context.source__valname

	call unite#print_source_message(valname, self.name)

	let num_     = 0
	let valnames = [valname]

	while num_ < len(valnames)
		let tmps = unite_setting2#get_valnames(valnames[num_])

		if len(tmps) > 0
			let valnames = unite_setting2#insert_list(valnames, tmps, num_)
			unlet valnames[num_]
		else
			let num_ = num_ + 1
		endif

	endwhile

	return map(copy(valnames), "{
				\ 'word'              : unite_setting2#get_source_word(v:val),
				\ 'kind'              : unite_setting2#get_source_kind(v:val),
				\ 'action__valname'   : v:val,
				\ }")

endfunction "}}}
"}}}

call unite#define_source ( unite_setting2#source_settings_var      ) | unlet unite_setting2#source_settings_var
call unite#define_source ( unite_setting2#source_settings_var_all  ) | unlet unite_setting2#source_settings_var_all
call unite#define_kind   ( unite_setting2#kind_settings_common     ) | unlet unite_setting2#kind_settings_common     
call unite#define_kind   ( unite_setting2#kind_settings_list       ) | unlet unite_setting2#kind_settings_list       



let &cpo = s:save_cpo
unlet s:save_cpo

