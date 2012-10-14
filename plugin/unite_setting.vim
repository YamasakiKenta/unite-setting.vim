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
function! s:kind.action_table.edit.func(candidate) "{{{
	let valname   = a:candidate.action__valname

	let val = unite_setting#get#data_from_name(valname)
	let val = input(valname.' : ', val)

	call unite_setting#set#name_from_data(valname, val)

	call unite#force_redraw()
endfunction "}}}
"}}}
"let s:kind.action_table.delete = { "{{{
let s:kind.action_table.delete = {
			\ 'description'   : 'delete',
			\ 'is_quit'       : 0,
			\ }
function! s:kind.action_table.delete.func(candidate) "{{{
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

	call s:common_out(dict_name)
endfunction "}}}
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
			\ 'default_action' : 'a_toggles',
			\ 'action_table'   : {},
			\ 'parents': ['settings_common'],
			\ }
let s:kind.action_table.a_toggles = {
			\ 'description' : 'select',
			\ 'is_quit'     : 0,
			\ }
function! s:kind.action_table.a_toggles.func(candidate) "{{{
	let tmp_d = {
				\ 'dict_name' : a:candidate.action__dict_name,
				\ 'valname'   : a:candidate.action__valname,
				\ 'kind'      : a:candidate.action__kind,
				\ 'only_'     : 0,
				\ }
	call unite#start_temporary([['settings_select', tmp_d]])
endfunction "}}}
let s:kind_settings_list = deepcopy(s:kind)
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
	" ê›íËÇ∑ÇÈçÄñ⁄
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
			\ 'description' : 'ï°êîëIë',
			\ 'syntax'      : 'uniteSource__settings',
			\ 'hooks'       : {},
			\ }
let s:source.hooks.on_syntax = function('Sub_setting_syntax')
function! s:source.hooks.on_init(args, context) "{{{
	if len(a:args) > 0
		let a:context.source__dict_name = a:args[0].dict_name
		let a:context.source__valname   = a:args[0].valname
		let a:context.source__kind      = a:args[0].kind
		let a:context.source__only      = a:args[0].only_
	endif
endfunction "}}}
function! s:source.gather_candidates(args, context) "{{{

	" ê›íËÇ∑ÇÈçÄñ⁄
	if len(a:args) > 0
		let dict_name = a:args[0].dict_name
		let valname   = a:args[0].valname
		let kind      = a:args[0].kind
	endif

	" à¯êîÇéÊìæÇ∑ÇÈ
	let words = s:get_orig(dict_name, valname, kind)[1:]

	let val  = 0
	let num_ = 0

	let strs  = s:get_strs_on_off(dict_name, valname, kind)
	call insert(strs, ' NULL ')

	let rtns = []
	for word in strs 
		let rtns += [{
					\ 'word'              : word,
					\ 'kind'              : 'settings_select',
					\ 'action__dict_name' : a:context.source__dict_name,
					\ 'action__valname'   : a:context.source__valname,
					\ 'action__kind'      : a:context.source__kind,
					\ 'action__only'      : a:context.source__only,
					\ 'action__bitnum'    : val,
					\ 'action__num'       : num_,
					\ 'action__new'       : '',
					\ }]
		let val = val ? val * 2 : 1
		let num_ += 1
	endfor	

	return rtns

endfunction "}}}
function! s:source.change_candidates(args, context) "{{{

	let new = a:context.input
	let dict_name   = a:context.source__dict_name
	let valname     = a:context.source__valname
	let kind        = a:context.source__kind

	let rtns = []
	if new != ''
		let rtns = [{
					\ 'word' : '[add] '.new,
					\ 'kind' : 'settings_select',
					\ 'action__new'       : new,
					\ 'action__dict_name' : a:context.source__dict_name,
					\ 'action__valname'   : a:context.source__valname,
					\ 'action__kind'      : a:context.source__kind,
					\ 'action__only'      : a:context.source__only,
					\ 'action__bitnum'    : 0,
					\ 'action__num'       : 0,
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

let g:test_num = 0
let g:test_list = []
let g:test_dict = {}
