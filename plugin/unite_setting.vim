let s:valname_to_source_kind_tabel = {
			\ type(0)              : 'settings_val',
			\ type("")             : 'settings_val',
			\ type(function("tr")) : 'settings_val',
			\ type([])             : 'settings_list',
			\ type({})             : 'settings_dict',
			\ type(0.0)            : 'settings_val',
			\ }
" source 
function! s:get_source_word(valname) "{{{
	let val_str = unite_setting#get#str_data_from_name(a:valname)
	return printf("%50s : %s", a:valname, val_str)
endfunction "}}}
function! s:get_source_kind(valname) "{{{
	let type = unite_setting#get#type_from_name(a:valname)
	return s:valname_to_source_kind_tabel[type]
endfunction "}}}

" s:kind_settings_common "{{{
let s:kind = { 
			\ 'name'           : 'settings_common',
			\ 'default_action' : '',
			\ 'action_table'   : {},
			\ }
"let s:kind.action_table.edit = { "{{{
let s:kind.action_table.edit = {
			\ 'description'   : 'val setting',
			\ 'is_quit'       : 0,
			\ }
function! s:kind.action_table.edit.func(candidate) 
	let valname   = a:candidate.action__valname

	let str = string(unite_setting#get#data_from_name(valname))
	let str = input(valname.' : ', str)

	call unite_setting#set#name_from_str(valname, str)

	call unite#force_redraw()
endfunction
"}}}
"let s:kind.action_table.delete = { "{{{
let s:kind.action_table.delete = {
			\ 'description'   : 'delete',
			\ 'is_quit'       : 0,
			\ }
function! s:kind.action_table.delete.func(candidate) 
	let candidate = a:candidate

	let dict_name = candidate.action__dict_name
	let valname   = candidate.action__valname
	let kind      = candidate.action__kind

	let tmp_d = s:get_data_from_name({}, dict_name)

	unlet tmp_d[valname]
	let orders = s:get_order(dict_name)
	for num_ in range(len(orders)-1, 0, -1)
		let order = orders[num_]
		if order  =~ valname
			unlet orders[num_]
		endif
	endfor

	call s:set_data_from_name(dict_name, tmp_d)

	call unite#force_redraw()
endfunction
"}}}
let s:kind_settings_common = deepcopy(s:kind)
"}}}
" s:kind_settings_val "{{{
let s:kind = { 
			\ 'name'           : 'settings_val',
			\ 'default_action' : 'edit',
			\ 'action_table'   : {},
			\ 'parents': ['settings_common'],
			\ }
let s:kind_settings_val = deepcopy(s:kind)
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
	let tmp_d = {
				\ 'valname'   : a:candidate.action__valname,
				\ }
	call unite#start_temporary([['settings_select', tmp_d]])
endfunction "}}}
let s:kind_settings_list = deepcopy(s:kind)
"}}}
"s:kind_settings_dict "{{{
let s:kind = { 
			\ 'name'           : 'settings_dict',
			\ 'default_action' : 'edit',
			\ 'action_table'   : {},
			\ 'parents': ['settings_common'],
			\ }
"let s:kind.action_table.a_toggles = { "{{{
let s:kind.action_table.a_toggles = {
			\ 'description' : 'select',
			\ 'is_quit'     : 0,
			\ }
function! s:kind.action_table.a_toggles.func(candidate) 
	let tmp_d = {
				\ 'valname'   : a:candidate.action__valname,
				\ }
	call unite#start_temporary([['settings_select', tmp_d]])
endfunction "}}}
let s:kind_settings_dict = deepcopy(s:kind)
"}}}
" s:kind_settings_select "{{{
let s:kind = { 
			\ 'name'           : 'settings_select',
			\ 'default_action' : 'rename',
			\ 'action_table'   : {},
			\ }
"let s:kind.action_table.rename = "{{{
let s:kind.action_table.rename = {
			\ 'description' : '',
			\ 'is_quit'     : 0,
			\ }
function! s:kind.action_table.rename.func(candidates) 
	let valname = a:candidates.action__valname
	let listnum = a:candidates.action__listnum
	let new     = a:candidates.action__new
	let lists   = unite_setting#get#data_from_name_def([], valname)

	let tmp_str = valname.'['.listnum.'] : '

	if listnum < len(lists)
		let val = input(tmp_str, string(lists[listnum]))
		let lists[listnum] = unite_setting#get#data_from_name(val) 
	else
		call add(lists, new)
	endif

	call unite_setting#set#name_from_data(valname, lists)

	call unite#force_redraw()
endfunction "}}}
"let s:kind.action_table.delete = "{{{
let s:kind.action_table.delete = {
			\ 'is_selectable' : 1,
			\ 'description'   : 'delete',
			\ 'is_quit'        : 0,
			\ }
function! s:kind.action_table.delete.func(candidates) 
	" íœ‚·‚é
	call s:delete(dict_name, valname, kind, nums)

	call unite#force_redraw()
endfunction "}}}
let s:kind_settings_select = deepcopy(s:kind)
"}}}

"s:source_settings "{{{
let s:source = {
			\ 'name'        : 'settings_var',
			\ 'description' : 'show var',
			\ 'syntax'      : 'uniteSource__settings',
			\ 'hooks'       : {},
			\ 'is_quit'     : 0,
			\ }
let s:source.hooks.on_syntax = function("unite_setting#sub_setting_syntax")
function! s:source.gather_candidates(args, context) "{{{
	" Ý’è‚·‚é€–Ú
	let vars = keys(g:)
	call sort(vars)

	cal map(vars, "'g:'.v:val")

	return map( copy(vars), "{
				\ 'word'              : s:get_source_word(v:val),
				\ 'kind'              : s:get_source_kind(v:val),
				\ 'action__valname'   : v:val,
				\ }")

endfunction "}}}
let s:source_settings = deepcopy(s:source)
"}}}
"s:source_settings_select "{{{
let s:source = {
			\ 'name'        : 'settings_select',
			\ 'description' : '•¡”‘I‘ð',
			\ 'syntax'      : 'uniteSource__settings',
			\ 'hooks'       : {},
			\ }
let s:source.hooks.on_syntax = function('Sub_setting_syntax')
function! s:source.hooks.on_init(args, context) "{{{
	let a:context.source__valname = ''
	if len(a:args) > 0
		let a:context.source__valname = a:args[0].valname
	endif
endfunction "}}}
function! s:source.gather_candidates(args, context) "{{{

	let valname = a:context.source__valname
	let num_ = 0
	let rtns = []
	for data in unite_setting#get#data_from_name_def([], valname)
		call add(rtns ,{
					\ 'word'              : num_.' - '.data,
					\ 'kind'              : 'settings_select',
					\ 'action__valname'   : valname,
					\ 'action__new'       : '',
					\ 'action__listnum'   : num_,
					\ })
		let num_ = num_ + 1
	endfor

	return rtns

endfunction "}}}
function! s:source.change_candidates(args, context) "{{{

	let new = a:context.input
	let valname     = a:context.source__valname
	let num_ = len(unite_setting#get#data_from_name_def([], valname))

	let rtns = []
	if new != ''
		let rtns = [{
					\ 'word' : num_.' - [add] '.new,
					\ 'kind' : 'settings_select',
					\ 'action__new'       : new,
					\ 'action__valname'   : a:context.source__valname,
					\ 'action__listnum'   : num_,
					\ }]
	endif

	return rtns

endfunction "}}}
let s:source_settings_select = deepcopy(s:source)
"}}}

call unite#define_source ( s:source_settings          ) | unlet s:source_settings
call unite#define_kind   ( s:kind_settings_val        ) | unlet s:kind_settings_val
call unite#define_source ( s:source_settings_select   ) | unlet s:source_settings_select
call unite#define_kind   ( s:kind_settings_common     ) | unlet s:kind_settings_common     
call unite#define_kind   ( s:kind_settings_list       ) | unlet s:kind_settings_list       
call unite#define_kind   ( s:kind_settings_dict       ) | unlet s:kind_settings_dict
call unite#define_kind   ( s:kind_settings_select     ) | unlet s:kind_settings_select      

let g:test_num = 0
let g:test_list = []
let g:test_dict = {}
