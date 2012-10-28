call unite_setting_ex#load('g:unite_setting_default_data', expand('~/unite_setting_data_def.vim'))

let s:unite_kind = {
			\ 'bool'     : 'kind_settings_ex_bool',
			\ 'list'     : 'kind_settings_ex_var_list',
			\ 'list_ex'  : 'kind_settings_ex_list',
			\ 'select'   : 'kind_settings_ex_select',
			\ 'var'      : 'kind_settings_ex_var',
			\ }

function! Sub_set_settings_ex_select_list_toggle(candidates) "{{{

	let candidates = type(a:candidates) == type([]) ? a:candidates : [a:candidates]

	let dict_name = candidates[0].action__dict_name
	let valname_ex   = candidates[0].action__valname_ex
	let kind      = candidates[0].action__kind

	let tmps = s:get_orig(dict_name, valname_ex, kind)

	let nums = []
	for candidate in candidates
		if ( candidate.action__num > 0 )
			call add(nums, candidate.action__num)
		endif
	endfor

	" 新規追加の場合
	if candidates[0].action__new != ''
		call insert(tmps, candidates[0].action__new, 1)
		call map(nums, "v:val+1")
	else
		call unite#force_quit_session()
	endif

	let tmps[0] = nums
	call s:set(dict_name, valname_ex, kind, tmps)

	call s:common_out(dict_name)
	return 
endfunction "}}}

function! s:save(dict_name) "{{{
	exe 'let tmp_d = '.a:dict_name

	let tmps  = split(string(tmp_d), '},\zs')
	let tmps  = map(tmps, "'\\'.v:val")

	call insert(tmps, 'let g:tmp_unite_setting = ')

	call writefile(tmps ,expand(tmp_d.__file))
endfunction "}}}
function! s:delete(dict_name, valname_ex, kind, nums) "{{{


	" 並び替え
	let nums = copy(a:nums)
	call sort(nums, 's:sort_lager')

	" 番号の取得
	let datas = s:get_orig(a:dict_name, a:valname_ex, a:kind)

	" 選択番号の取得
	let bits = [0]
	call extend(bits, s:get_bits(a:dict_name, a:valname_ex, a:kind))

	" 削除 ( 大きい数字から削除 ) 
	for num_ in a:nums
		" 番号の更新
		if exists('datas[num_]')
			unlet datas[num_]
		endif
		if exists('bits[num_]')
			unlet bits[num_]
		endif
	endfor

	" 選択番号の設定
	let datas[0] = s:get_num_from_bits(bits)

	" 設定
	call s:set(a:dict_name, a:valname_ex, a:kind, datas)

endfunction "}}}
function! s:get_source_valname(dict_name, valname_ex, kind) "{{{
	if exists(a:valname_ex)
		let valname = a:valname_ex
	else
		let valname = a:dict_name.'['''.a:valname_ex.''']['''.a:kind.''']'
	endif
	return valname
endfunction "}}}

function! s:common_out(dict_name) "{{{
	call unite#force_redraw()
endfunction "}}}

function! s:get_bits(dict_name, valname_ex, kind) "{{{

	let tmp_d = s:get_orig(a:dict_name, a:valname_ex, a:kind)
	let bits  = map(range(len(tmp_d)), "0")

	" ★　バグ対応
	if 0 && type(tmp_d[0]) != type([])
		let tmp_d[0] = [1]
	endif

	for num_ in tmp_d[0]
		let num_ = num_ < len(tmp_d) ? num_ : 1
		let bits[num_] = num_
	endfor


	return bits
endfunction "}}}
function! s:get_kind(dict_name, valname_ex, kind) "{{{
	if exists(a:dict_name.'[a:valname_ex][a:kind]')
		return a:kind
	endif
	return '__common'
endfunction "}}}
function! s:get_num_from_bits(bits) "{{{
	let nums  = []
	for i_ in range(len(a:bits))
		if a:bits[i_] > 0
			call add(nums, i_)
		endif
	endfor

	return nums
endfunction "}}}
function! s:get_orig(dict_name, valname_ex, kind) "{{{
	exe 'let tmp_d = '.a:dict_name
	let kind = s:get_kind(a:dict_name, a:valname_ex, a:kind)
	return tmp_d[a:valname_ex][kind]
endfunction "}}}
function! s:get_source_kind(dict_name, valname_ex, kind) "{{{
	exe 'let tmp_d = '.a:dict_name
	let type = s:get_type(a:dict_name, a:valname_ex, a:kind)
	if exists('s:unite_kind[type]')
		let kind = s:unite_kind[type]
	else
		let kind = 'title'
	endif
	return kind
endfunction "}}}
function! s:get_source_word(dict_name, valname_ex, kind) "{{{
	exe 'let tmp_d = '.a:dict_name
	let type = s:get_type(a:dict_name, a:valname_ex, a:kind)

	if type == 'bool'
		let rtn = s:get_source_word_from_bool(a:dict_name, a:valname_ex, a:kind)
	elseif type == 'list_ex' || type == 'select' 
		let rtn = s:get_source_word_from_strs(a:dict_name, a:valname_ex, a:kind)
	elseif type == 'var'|| type == 'list'
		let rtn = s:get_source_word_from_val(a:dict_name, a:valname_ex, a:kind)
	else
		" ★ タイトルをわける
		let rtn = '"'.a:valname_ex.'"'
	endif

	return rtn
endfunction "}}}
function! s:get_source_word_from_bool(dict_name, valname_ex, kind) "{{{
	let str =  unite_setting_ex#get(a:dict_name, a:valname_ex, a:kind) ? 
				\ '<TRUE>  FALSE ' :
				\ ' TRUE  <FALSE>'
	return s:get_source_word_sub( a:dict_name, a:valname_ex, a:kind, str)
endfunction "}}}
function! s:get_source_word_from_strs(dict_name, valname_ex, kind) "{{{

	let strs  = s:get_strs_on_off(a:dict_name, a:valname_ex, a:kind)

	return s:get_source_word_sub( a:dict_name, a:valname_ex, a:kind, join(strs))
endfunction "}}}
function! s:get_source_word_from_val(dict_name, valname_ex, kind) "{{{
	let data = unite_setting_ex#get(a:dict_name, a:valname_ex, a:kind)
	return s:get_source_word_sub( a:dict_name, a:valname_ex, a:kind, string(data))
endfunction "}}}
function! s:get_source_word_sub(dict_name, valname_ex, kind, str) "{{{
	exe 'let tmp_d = '.a:dict_name
	let description = ''
	if exists('tmp_d[a:valname_ex].__description')
		let description = tmp_d[a:valname_ex].__description
	endif

	return printf(' %-100s %50s - %s', 
				\ description,
				\ s:get_source_word_sub_type(a:dict_name, a:valname_ex, a:kind),
				\ a:str,
				\ )
endfunction "}}}
function! s:get_source_word_sub_type(dict_name, valname_ex, kind) "{{{
	let kind = s:get_kind( a:dict_name, a:valname_ex, a:kind) 

	if exists(a:valname_ex)
		let star = '_'
	elseif kind=='__common'
		let star = '*'
	else
		let star = ' '
	endif

	return star.''.a:valname_ex.''.star
endfunction "}}}
function! s:get_strs_on_off(dict_name, valname_ex, kind) "{{{

	let datas = copy(s:get_orig(a:dict_name, a:valname_ex, a:kind))
	let flgs  = datas[0]

	" ★　バグ対応
	if type(flgs) != type([])
		unlet flgs
		let flgs = [1]
	endif

	" ★　バグ対応
	if type(datas) != type([])
		echo 'error - '.a:valname_ex.' - '.a:kind
		unlet datas
		let datas = []
	endif

	let strs = [0] + map(copy(datas[1:]), "' '.v:val.' '")
	
	for num_ in flgs
		let strs[num_] = '<'.datas[num_].'>'
	endfor

	unlet strs[0]

	return strs
endfunction "}}}
function! s:get_type(dict_name, valname_ex, kind) "{{{
	
	if  exists(a:dict_name.'[a:valname_ex].__type')
		exe 'let type_ = '.a:dict_name.'[a:valname_ex].__type'
	else
		exe 'let tmp = '.a:valname_ex
		let type_ = type(tmp)
		if type([]) == type_ || type({}) == type_
			let type_ = 'list'
		elseif type(0) == type_ && ( tmp == 0 || tmp == 1 ) 
			let type_ = 'bool'
		endif
	endif

	retu type_
endfunction "}}}
function! s:set_type(dict_name, valname_ex, kind, type) "{{{
		exe 'let tmp_d = '.a:dict_name

		let tmp_d[a:valname_ex].__type = a:type

		exe 'let '.a:dict_name.' = tmp_d'
endfunction "}}}

function! s:set(dict_name, valname_ex, kind, val) "{{{

	exe 'let '.a:dict_name.'["'.a:valname_ex.'"]["'.a:kind.'"]'.' = a:val'

	if exists(a:valname_ex) || a:valname_ex =~ '^g:'
		let tmp = unite_setting_ex#get(a:dict_name, a:valname_ex, a:kind)
		exe 'let '.a:valname_ex.' = tmp'
	endif

endfunction "}}}
function! s:set_next(dict_name, valname_ex, kind) "{{{
	exe 'let tmp_d = '.a:dict_name
	let type = s:get_type(a:dict_name, a:valname_ex, a:kind)

	if type == 'bool'
		let val = unite_setting_ex#get(a:dict_name, a:valname_ex, a:kind) ? 0 : 1
	else
		let val = s:get_orig(a:dict_name, a:valname_ex, a:kind)

		let num_ = val[0][0]
		let num_ = num_ + 1
		let num_ = num_ < len(val) ? num_ : 1

		let val[0][0] = num_

	endif

	call s:set(a:dict_name, a:valname_ex, a:kind, val )
endfunction "}}}

" s:kind_settings_ex_common "{{{
let s:kind = { 
			\ 'name'           : 'kind_settings_ex_common',
			\ 'default_action' : 'a_toggle',
			\ 'action_table'   : {},
			\ 'parents': ['kind_settings_common'],
			\ }
"let s:kind.action_table.set_select = {"{{{
let s:kind.action_table.set_select = {
			\ 'is_selectable' : 1,
			\ 'description'   : '',
			\ 'is_quit'       : 0,
			\ }
function! s:kind.action_table.set_select.func(candidates) "{{{
	for candidate in a:candidates
		let dict_name  = candidate.action__dict_name
		let valname_ex = candidate.action__valname_ex
		let kind       = candidate.action__kind

		call s:set_type(dict_name, valname_ex, kind, 'select')
	endfor

	call s:common_out(dict_name)
endfunction "}}}
"}}}
"let s:kind.action_table.set_list_ex = {"{{{
let s:kind.action_table.set_list_ex = {
			\ 'is_selectable' : 1,
			\ 'description'   : '',
			\ 'is_quit'       : 0,
			\ }
function! s:kind.action_table.set_list_ex.func(candidates) "{{{
	for candidate in a:candidates
		let dict_name  = candidate.action__dict_name
		let valname_ex = candidate.action__valname_ex
		let kind       = candidate.action__kind

		call s:set_type(dict_name, valname_ex, kind, 'list_ex')
	endfor

	call s:common_out(dict_name)
endfunction "}}}
"}}}
"let s:kind.action_table.set_bool = {"{{{
let s:kind.action_table.set_bool = {
			\ 'is_selectable' : 1,
			\ 'description'   : '',
			\ 'is_quit'       : 0,
			\ }
function! s:kind.action_table.set_bool.func(candidates) "{{{
	for candidate in a:candidates
		let dict_name  = candidate.action__dict_name
		let valname_ex = candidate.action__valname_ex
		let kind       = candidate.action__kind

		call s:set_type(dict_name, valname_ex, kind, 'bool')
	endfor

	call s:common_out(dict_name)
endfunction "}}}
"}}}
"let s:kind.action_table.set_var = {"{{{
let s:kind.action_table.set_var = {
			\ 'is_selectable' : 1,
			\ 'description'   : '',
			\ 'is_quit'       : 0,
			\ }
function! s:kind.action_table.set_var.func(candidates) "{{{
	for candidate in a:candidates
		let dict_name  = candidate.action__dict_name
		let valname_ex = candidate.action__valname_ex
		let kind       = candidate.action__kind

		call s:set_type(dict_name, valname_ex, kind, 'var')
	endfor

	call s:common_out(dict_name)
endfunction "}}}
"}}}
"let s:kind.action_table.set_list = {"{{{
let s:kind.action_table.set_list = {
			\ 'is_selectable' : 1,
			\ 'description'   : '',
			\ 'is_quit'       : 0,
			\ }
function! s:kind.action_table.set_list.func(candidates) "{{{
	for candidate in a:candidates
		let dict_name  = candidate.action__dict_name
		let valname_ex = candidate.action__valname_ex
		let kind       = candidate.action__kind

		call s:set_type(dict_name, valname_ex, kind, 'list')
	endfor

	call s:common_out(dict_name)
endfunction "}}}
"}}}
let s:kind_settings_ex_common = deepcopy(s:kind)
"}}}

" s:kind_settings_ex_bool "{{{
let s:kind = { 
			\ 'name'           : 'kind_settings_ex_bool',
			\ 'default_action' : 'a_toggle',
			\ 'action_table'   : {},
			\ 'parents': ['kind_settings_ex_common'],
			\ }
let s:kind.action_table.a_toggle = {
			\ 'is_selectable' : 1,
			\ 'description'   : '設定の切替',
			\ 'is_quit'       : 0,
			\ }
function! s:kind.action_table.a_toggle.func(candidates) "{{{
	for candidate in a:candidates
		let dict_name  = candidate.action__dict_name
		let valname_ex = candidate.action__valname_ex
		let kind       = candidate.action__kind
		call s:set_next(dict_name, valname_ex, kind)
	endfor
	call s:common_out(dict_name)
endfunction "}}}
let s:kind_settings_ex_bool = deepcopy(s:kind)
"}}}
" s:kind_settings_ex_var  "{{{
let s:kind = { 
			\ 'name'           : 'kind_settings_ex_var',
			\ 'default_action' : 'edit',
			\ 'action_table'   : {},
			\ 'parents': ['kind_settings_ex_common'],
			\ }
let s:kind.action_table.edit = {
			\ 'description' : '設定編集',
			\ 'is_quit'     : 0,
			\ }"
function! s:kind.action_table.edit.func(candidate) "{{{
	let dict_name  = a:candidate.action__dict_name
	let valname_ex = a:candidate.action__valname_ex
	let kind       = a:candidate.action__kind
	let tmp        = input("",string(s:get_orig(dict_name, valname_ex, kind)))

	if tmp != ""
		exe 'let val = '.tmp
		call s:set(dict_name, valname_ex, kind, val)
	endif

	call s:common_out(dict_name)
endfunction "}}}
let s:kind_settings_ex_var = deepcopy(s:kind)
"}}}
" s:kind_settings_ex_var_list  "{{{
let s:kind = { 
			\ 'name'           : 'kind_settings_ex_var_list',
			\ 'default_action' : 'select',
			\ 'action_table'   : {},
			\ 'parents': ['kind_settings_ex_common'],
			\ }
let s:kind.action_table.select = {
			\ 'description' : '設定編集',
			\ 'is_quit'     : 0,
			\ }"
function! s:kind.action_table.select.func(candidate) "{{{
	let valname   = a:candidate.action__valname
	call unite#start_temporary([['settings_var', valname]])
endfunction "}}}
let s:kind_settings_ex_var_list = deepcopy(s:kind)
"}}}
"s:kind_settings_ex_select "{{{
let s:kind = { 
			\ 'name'           : 'kind_settings_ex_select',
			\ 'default_action' : 'a_toggle',
			\ 'action_table'   : {},
			\ 'parents': ['kind_settings_ex_common', 'kind_settings_common'],
			\ }
let s:kind.action_table.a_toggle = {
			\ 'description' : '選択',
			\ 'is_quit'     : 0,
			\ }
function! s:kind.action_table.a_toggle.func(candidate) "{{{
	let dict_name  = a:candidate.action__dict_name
	let valname_ex = a:candidate.action__valname_ex
	let kind       = a:candidate.action__kind

	call s:set_next(dict_name, valname_ex, kind)
	call s:common_out(dict_name)
endfunction "}}}
let s:kind.action_table.edit = {
			\ 'description' : 'edit',
			\ 'is_quit'     : 0,
			\ }
function! s:kind.action_table.edit.func(candidate) "{{{
	let tmp_d = {
				\ 'dict_name' : a:candidate.action__dict_name,
				\ 'valname_ex'   : a:candidate.action__valname_ex,
				\ 'kind'      : a:candidate.action__kind,
				\ 'only_'     : 1,
				\ }
	call unite#start_temporary([['settings_ex_list_select', tmp_d]], {'default_action' : 'a_toggle'})
endfunction "}}}
let s:kind_settings_ex_select = deepcopy(s:kind)
"}}}
" s:kind_settings_ex_list "{{{
let s:kind = { 
			\ 'name'           : 'kind_settings_ex_list',
			\ 'default_action' : 'a_toggle',
			\ 'action_table'   : {},
			\ 'parents': ['kind_settings_ex_common', 'kind_settings_common'],
			\ }
" action
let s:kind.action_table.a_toggle = {
			\ 'description' : '選択',
			\ 'is_quit'     : 0,
			\ }
function! s:kind.action_table.a_toggle.func(candidate) "{{{
	let tmp_d = {
				\ 'dict_name' : a:candidate.action__dict_name,
				\ 'valname_ex'   : a:candidate.action__valname_ex,
				\ 'kind'      : a:candidate.action__kind,
				\ }
	call unite#start_temporary([['settings_ex_list_select', tmp_d]])
endfunction "}}}
let s:kind.action_table.edit = {
			\ 'description' : '設定編集',
			\ 'is_quit'     : 0,
			\ }"
function! s:kind.action_table.edit.func(candidate) "{{{
	let dict_name = a:candidate.action__dict_name
	let valname_ex   = a:candidate.action__valname_ex
	let kind      = a:candidate.action__kind
	let tmp       = input("",string(s:get_orig(dict_name, valname_ex, kind)))

	if tmp != ""
		exe 'let val = '.tmp
		call s:set(dict_name, valname_ex, kind, val)
	endif

	call s:common_out(dict_name)
endfunction "}}}
let s:kind_settings_ex_list = deepcopy(s:kind)
"}}}
" s:kind_settings_ex_list_select "{{{
let s:kind = { 
			\ 'name'           : 'settings_ex_list_select',
			\ 'default_action' : 'a_toggles',
			\ 'action_table'   : {},
			\ 'parents': ['kind_settings_ex_common'],
			\ }
let s:kind.action_table.a_toggles = {
			\ 'is_selectable' : 1,
			\ 'description' : '設定の切替 ( 複数選択可能 )',
			\ 'is_quit'        : 0,
			\ }
let s:kind.action_table.a_toggles.func = function("Sub_set_settings_ex_select_list_toggle")
let s:kind.action_table.a_toggle = {
			\ 'description' : '設定の切替',
			\ 'is_quit'        : 0,
			\ }
let s:kind.action_table.a_toggle.func = function("Sub_set_settings_ex_select_list_toggle")
let s:kind.action_table.delete = {
			\ 'is_selectable' : 1,
			\ 'description'   : 'delete',
			\ 'is_quit'        : 0,
			\ }
function! s:kind.action_table.delete.func(candidates) "{{{

	" 初期化
	let valname_ex   = a:candidates[0].action__valname_ex
	let kind      = a:candidates[0].action__kind
	let dict_name = a:candidates[0].action__dict_name
	let nums      = map(copy(a:candidates), 'v:val.action__num')

	" 削除する
	call s:delete(dict_name, valname_ex, kind, nums)

	call s:common_out(dict_name)
endfunction "}}}
let s:kind_settings_ex_list_select = deepcopy(s:kind)
"}}}
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
"
"source - s:settings_ex "{{{
let s:source = {
			\ 'name'        : 'settings_ex',
			\ 'description' : '',
			\ 'syntax'      : 'uniteSource__settings',
			\ 'hooks'       : {},
			\ 'is_quit'     : 0,
			\ }
let s:source.hooks.on_syntax = function("unite_setting#sub_setting_syntax")
function! s:source.hooks.on_init(args, context) "{{{
	let a:context.source__dict_name = get(a:args, 0, 'g:')
endfunction "}}}
function! s:source.hooks.on_close(args, context) "{{{
	let dict_name = a:context.source__dict_name 
	call s:save(dict_name)
endfunction "}}}
function! s:source.gather_candidates(args, context) "{{{
	" 設定する項目
	let dict_name = a:context.source__dict_name
	exe 'let tmp_d = '.dict_name

	call unite#print_source_message(dict_name, self.name)

	" ★ データに登録がない場合は、どうしよう
	if exists('tmp_d.__order')
		let orders  = tmp_d.__order
	else
		let orders = s:get_valnames(dict_name)
		let dict_name = 'g:unite_setting_default_data'
	endif

	let kind    = '__common'

	" 辞書名と、取得関数が必要になる

	return map( copy(orders), "{
				\ 'word'               : s:get_source_word(dict_name, v:val, kind),
				\ 'kind'               : s:get_source_kind(dict_name, v:val, kind),
				\ 'action__kind'       : kind,
				\ 'action__valname'    : s:get_source_valname(dict_name, v:val, kind),
				\ 'action__valname_ex' : v:val,
				\ 'action__dict_name'  : dict_name,
				\ }")

endfunction "}}}
let s:settings_ex = deepcopy(s:source)
"}}}
"source - s:settings_ex_list_select"{{{
let s:source = {
			\ 'name'        : 'settings_ex_list_select',
			\ 'description' : '複数選択',
			\ 'syntax'      : 'uniteSource__settings',
			\ 'hooks'       : {},
			\ }
let s:source.hooks.on_syntax = function('unite_setting#sub_setting_syntax')
function! s:source.hooks.on_init(args, context) "{{{
	if len(a:args) > 0
		let a:context.source__dict_name = a:args[0].dict_name
		let a:context.source__valname_ex   = a:args[0].valname_ex
		let a:context.source__kind      = a:args[0].kind
		let a:context.source__only      = get(a:args[0], 'only_', 0)
	endif
endfunction "}}}
function! s:source.gather_candidates(args, context) "{{{

	let dict_name = a:context.source__dict_name 
	let valname_ex   = a:context.source__valname_ex   
	let kind      = a:context.source__kind      
	let only_     = a:context.source__only      

	" 引数を取得する
	let words = s:get_orig(dict_name, valname_ex, kind)[1:]

	let strs  = s:get_strs_on_off(dict_name, valname_ex, kind)

	if only_
		let num_ = 1
	else
		let num_ = 0
		call insert(strs, ' NULL ')
	endif

	let rtns = []
	for word in strs 
		let rtns += [{
					\ 'word'              : num_.' - '.word,
					\ 'kind'              : 'settings_ex_list_select',
					\ 'action__dict_name' : a:context.source__dict_name,
					\ 'action__valname_ex'   : a:context.source__valname_ex,
					\ 'action__kind'      : a:context.source__kind,
					\ 'action__num'       : num_,
					\ 'action__new'       : '',
					\ }]
		let num_ += 1
	endfor	

	return rtns

endfunction "}}}
function! s:source.change_candidates(args, context) "{{{

	let new_ = a:context.input
	let dict_name   = a:context.source__dict_name
	let valname_ex     = a:context.source__valname_ex
	let kind        = a:context.source__kind

	let rtns = []
	if new_ != ''
		let rtns = [{
					\ 'word' : '[add] '.new_,
					\ 'kind' : 'settings_ex_list_select',
					\ 'action__new'       : new_,
					\ 'action__dict_name' : a:context.source__dict_name,
					\ 'action__valname_ex'   : a:context.source__valname_ex,
					\ 'action__kind'      : a:context.source__kind,
					\ 'action__num'       : 1,
					\ }]
	endif

	return rtns

endfunction "}}}
let s:settings_ex_list_select = deepcopy(s:source)
"}}}

call unite#define_kind   ( s:kind_settings_ex_bool          )  | unlet s:kind_settings_ex_bool
call unite#define_kind   ( s:kind_settings_ex_common        )  | unlet s:kind_settings_ex_common
call unite#define_kind   ( s:kind_settings_ex_list          )  | unlet s:kind_settings_ex_list
call unite#define_kind   ( s:kind_settings_ex_list_select   )  | unlet s:kind_settings_ex_list_select
call unite#define_kind   ( s:kind_settings_ex_select        )  | unlet s:kind_settings_ex_select
call unite#define_kind   ( s:kind_settings_ex_var           )  | unlet s:kind_settings_ex_var 
call unite#define_kind   ( s:kind_settings_ex_var_list      )  | unlet s:kind_settings_ex_var_list
call unite#define_source ( s:settings_ex                    )  | unlet s:settings_ex
call unite#define_source ( s:settings_ex_list_select        )  | unlet s:settings_ex_list_select

nnoremap ;tt<CR> :Unite settings_ex<CR>
