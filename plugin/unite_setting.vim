let s:valname_to_source_kind_tabel = {
			\ type(0)              : 'settings_common',
			\ type("")             : 'settings_common',
			\ type(function("tr")) : 'settings_common',
			\ type(0.0)            : 'settings_common',
			\ type([])             : 'settings_list',
			\ type({})             : 'settings_list',
			\ }

function! s:get_source_word(valname) "{{{
	exe 'let tmp = '.a:valname
	return printf("%-50s : %s", a:valname, string(tmp))
endfunction "}}}
function! s:get_source_kind(valname) "{{{
	exe 'let tmp_ = '.a:valname
	return s:valname_to_source_kind_tabel[type(tmp)]
endfunction "}}}

"s:source_settings_var "{{{
let s:source = {
			\ 'name'        : 'settings_var',
			\ 'description' : 'show var',
			\ 'syntax'      : 'uniteSource__settings',
			\ 'hooks'       : {},
			\ 'is_quit'     : 0,
			\ }
let s:source.hooks.on_syntax = function("unite_setting#sub_setting_syntax")
function! s:source.hooks.on_init(args, context) "{{{
	let a:context.source__valname = get(a:args, 0, 'g:')
endfunction "}}}
function! s:source.gather_candidates(args, context) "{{{

	let valname = a:context.source__valname

	call unite#print_source_message(valname, 'settings_var')

	exe 'let tmp = '.valname

	if type([]) == type(tmp)
		let vars = map(range(len(tmp)),
					\ "valname.'['.v:val.']'")
	elseif type({}) == type(tmp)
		let vars = map(keys(tmp),
					\ "valname.'['''.v:val.''']'")
	endif

	return map( copy(vars), "{
				\ 'word'              : s:get_source_word(v:val),
				\ 'kind'              : s:get_source_kind(v:val),
				\ 'action__valname'   : v:val,
				\ }")

endfunction "}}}
function! s:source.change_candidates(args, context) "{{{

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
					\ 'kind' : 'settings_common',
					\ 'action__valname'   : valname,
					\ }]
	endif

	return rtns

endfunction "}}}
let s:source_settings_var = deepcopy(s:source)
"}}}

" s:kind_settings_common "{{{
let s:kind = { 
			\ 'name'           : 'settings_common',
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
let s:kind_settings_common = deepcopy(s:kind)
"}}}
"s:kind_settings_list "{{{
let s:kind = { 
			\ 'name'           : 'settings_list',
			\ 'default_action' : 'select',
			\ 'action_table'   : {},
			\ 'parents': ['settings_common'],
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
let s:kind_settings_list = deepcopy(s:kind)
"}}}

call unite#define_source ( s:source_settings_var      ) | unlet s:source_settings_var
call unite#define_kind   ( s:kind_settings_common     ) | unlet s:kind_settings_common     
call unite#define_kind   ( s:kind_settings_list       ) | unlet s:kind_settings_list       

let g:test_list = [{'a':123, 'b':456, 'd':[1,2,3,{'eee':4}]}, 'bbb', 'ccc']

