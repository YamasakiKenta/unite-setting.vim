let s:unite_kind = {
			\ 'bool'     : 'settings_ex_bool',
			\ 'var'      : 'settings_ex_var',
			\ 'list'     : 'settings_ex_list',
			\ 'select'   : 'settings_ex_select',
			\ }

function! Sub_set_settings_ex_select_list_toggle(candidates) "{{{

	let candidates = type(a:candidates) == type([]) ? a:candidates : [a:candidates]

	let dict_name = candidates[0].action__dict_name
	let valname   = candidates[0].action__valname
	let kind      = candidates[0].action__kind
	"let only_     = candidates[0].action__only

	let tmps = s:get_orig(dict_name, valname, kind)

	let val = 0
	for candidate in candidates
		let val += candidate.action__bitnum
	endfor

	" 新規追加の場合
	if candidates[0].action__new != ''
		call insert(tmps, candidates[0].action__new, 1)
		let val = val * 2 + 1
	else
		call unite#force_quit_session()
	endif

	let tmps[0] = val
	call s:set(dict_name, valname, kind, tmps)

	call s:common_out(dict_name)
	return 
endfunction "}}}

function! s:save(dict_name) "{{{
	exe 'let tmp_d = '.a:dict_name
	let file_ = tmp_d.__file
	call writefile([string(tmp_d)], expand("file_"))
endfunction "}}}
function! s:delete(dict_name, valname, kind, nums) "{{{

	" 並び替え
	let nums = copy(a:nums)
	call sort(nums, 's:sort_lager')

	" 番号の取得
	let datas = s:get_orig(a:dict_name, a:valname, a:kind)

	" 選択番号の取得
	let bits = [0]
	call extend(bits, s:get_bits(a:dict_name, a:valname, a:kind))

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
	call s:set(a:dict_name, a:valname, a:kind, datas)

endfunction "}}}

function! s:common_out(dict_name) "{{{
	call s:save(a:dict_name)
	call unite#force_redraw()
endfunction "}}}

function! s:get_bits(dict_name, valname, kind) "{{{

	let tmp_d   = s:get_orig(a:dict_name, a:valname, a:kind)
	let tmp_num = tmp_d[0]
	let bits    = []
	let num     = 1

	for i in range(len(tmp_d[1:]))
		call add(bits, tmp_num % 2 > 0 ? num : 0 )
		let tmp_num = tmp_num / 2
		let num = num * 2
	endfor

	return bits
endfunction "}}}
function! s:get_kind(dict_name, valname, kind) "{{{
	if exists(a:dict_name.'[a:valname][a:kind]')
		return a:kind
	endif
	return '__common'
endfunction "}}}
function! s:get_num_from_bits(bits) "{{{
	let sum  = 0
	let num_ = 1
	for i_ in range(len(a:bits))
		if a:bits[i_] > 0
			let sum += num_
		endif
		let num_ = num_ * 2
	endfor
	let sum = sum / 2

	return sum
endfunction "}}}
function! s:get_orig(dict_name, valname, kind) "{{{
	exe 'let tmp_d = '.a:dict_name
	let kind = s:get_kind(a:dict_name, a:valname, a:kind)
	return tmp_d[a:valname][kind]
endfunction "}}}
function! s:get_source_kind(dict_name, valname, kind) "{{{
	exe 'let tmp_d = '.a:dict_name
	let type = tmp_d[a:valname].__type
	if exists('s:unite_kind[type]')
		return s:unite_kind[type]
	endif
	return ""
endfunction "}}}
function! s:get_source_word(dict_name, valname, kind) "{{{
	exe 'let tmp_d = '.a:dict_name
	let type = tmp_d[a:valname].__type

	let rtn = '----'
	if type == 'bool'
		let rtn = s:get_source_word_from_bool(a:dict_name, a:valname, a:kind)
	elseif type == 'list' || type == 'select'
		let rtn = s:get_source_word_from_strs(a:dict_name, a:valname, a:kind)
	elseif type == 'var'
		let rtn = s:get_source_word_from_val(a:dict_name, a:valname, a:kind)
	else
		let rtn = '"'.a:valname.'"'
	endif

	return rtn
endfunction "}}}
function! s:get_source_word_from_bool(dict_name, valname, kind) "{{{
	let str =  unite_setting_ex#get(a:dict_name, a:valname, a:kind) ? 
				\ '<TRUE>  FALSE ' :
				\ ' TRUE  <FALSE>'
	return s:get_source_word_sub( a:dict_name, a:valname, a:kind, str)
endfunction "}}}
function! s:get_source_word_from_strs(dict_name, valname, kind) "{{{

	let datas  = s:get_orig(a:dict_name, a:valname, a:kind)
	let select = datas[0]

	"全選択
	if select < 0
		let items  = datas[1:]
		let strs   = map(copy(items), "'<'.v:val.'>'")
	else
		let strs  = s:get_strs_on_off(a:dict_name, a:valname, a:kind)
	endif
	return s:get_source_word_sub( a:dict_name, a:valname, a:kind, join(strs))
endfunction "}}}
function! s:get_source_word_from_val(dict_name, valname, kind) "{{{
	let data = unite_setting_ex#get(a:dict_name, a:valname, a:kind)
	return s:get_source_word_sub( a:dict_name, a:valname, a:kind, string(data))
endfunction "}}}
function! s:get_source_word_sub(dict_name, valname, kind, str) "{{{
	exe 'let tmp_d = '.a:dict_name
	return printf(' %-100s %50s - %s', 
				\ tmp_d[a:valname].__description,
				\ s:get_source_word_sub_type(a:dict_name, a:valname, a:kind),
				\ a:str,
				\ )
endfunction "}}}
function! s:get_source_word_sub_type(dict_name, valname, kind) "{{{
	let kind = s:get_kind( a:dict_name, a:valname, a:kind) 

	if exists(a:valname)
		let star = '_'
	elseif kind=='__common'
		let star = '*'
	else
		let star = ' '
	endif

	return star.''.a:valname.''.star
endfunction "}}}
function! s:get_strs_on_off(dict_name, valname, kind) "{{{

	let items  = s:get_orig(a:dict_name, a:valname, a:kind)[1:]
	let flgs   = s:get_bits(a:dict_name, a:valname, a:kind)
	let tmps_d = map(range(len(items)), "{
				\ 'flg'      : flgs[v:val],
				\ 'item_on'  : '<'.items[v:val].'>',
				\ 'item_off' : ' '.items[v:val].' ',
				\ }")
	let strs = map(copy(tmps_d), "v:val.flg ? v:val.item_on : v:val.item_off")

	return strs
endfunction "}}}
function! s:get_type(dict_name, valname, kind) "{{{
	exe 'let tmp_d = '.a:dict_name
	return get( tmp_d[a:valname],'__type','title')
endfunction "}}}

function! s:set(dict_name, valname, kind, val) "{{{

	exe 'let '.a:dict_name.'["'.a:valname.'"]["'.a:kind.'"]'.' = a:val'

	if exists(a:valname)
		let tmp = unite_setting_ex#get(a:dict_name, a:valname, a:kind)
		exe 'let '.a:valname.' = tmp'
	endif

endfunction "}}}
function! s:set_next(dict_name, valname, kind) "{{{
	exe 'let tmp_d = '.a:dict_name
	let type = tmp_d[a:valname].__type

	if type == 'bool'
		let val = !unite_setting_ex#get(a:dict_name, a:valname, a:kind)
	else
		let val = s:get_orig(a:dict_name, a:valname, a:kind)
		let tmp_int   = val[0]

		" 修正できる範囲か確認する
		let max   = s:get_num_from_bits(range(len(val)-1))
		let val[0]   = val[0] > max ? 1 : val[0] * 2
	endif

	call s:set(a:dict_name, a:valname, a:kind, val )
endfunction "}}}

" s:kind_settings_ex_bool "{{{
let s:kind = { 
			\ 'name'           : 'settings_ex_bool',
			\ 'default_action' : 'a_toggle',
			\ 'action_table'   : {},
			\ }
let s:kind.action_table.a_toggle = {
			\ 'is_selectable' : 1,
			\ 'description'   : '設定の切替',
			\ 'is_quit'       : 0,
			\ }
function! s:kind.action_table.a_toggle.func(candidates) "{{{
	for candidate in a:candidates
		let dict_name = candidate.action__dict_name
		let valname   = candidate.action__valname
		let kind      = candidate.action__kind
		call s:set_next(dict_name, valname, kind)
	endfor
	call s:common_out(dict_name)
endfunction "}}}
let s:kind_settings_ex_bool = deepcopy(s:kind)
"}}}
" s:kind_settings_ex_var  "{{{
let s:kind = { 
			\ 'name'           : 'settings_ex_var',
			\ 'default_action' : 'edit',
			\ 'action_table'   : {},
			\ }
let s:kind.action_table.edit = {
			\ 'description' : '設定編集',
			\ 'is_quit'     : 0,
			\ }"
function! s:kind.action_table.edit.func(candidate) "{{{
	let dict_name = a:candidate.action__dict_name
	let valname   = a:candidate.action__valname
	let kind      = a:candidate.action__kind
	let tmp       = input("",string(s:get_orig(dict_name, valname, kind)))

	if tmp != ""
		exe 'let val = '.tmp
		call s:set(dict_name, valname, kind, val)
	endif

	call s:common_out(dict_name)
endfunction "}}}
let s:kind_settings_ex_var = deepcopy(s:kind)
"}}}
"s:kind_settings_ex_select "{{{
let s:kind = { 
			\ 'name'           : 'settings_ex_select',
			\ 'default_action' : 'a_toggle',
			\ 'action_table'   : {},
			\ 'parents': ['settings_common'],
			\ }
let s:kind.action_table.a_toggle = {
			\ 'description' : '選択',
			\ 'is_quit'     : 0,
			\ }
function! s:kind.action_table.a_toggle.func(candidate) "{{{
	let dict_name = a:candidate.action__dict_name
	let valname   = a:candidate.action__valname
	let kind      = a:candidate.action__kind

	call s:set_next(dict_name, valname, kind)
	call s:common_out(dict_name)
endfunction "}}}
let s:kind.action_table.edit = {
			\ 'description' : 'edit',
			\ 'is_quit'     : 0,
			\ }
function! s:kind.action_table.edit.func(candidate) "{{{
	let tmp_d = {
				\ 'dict_name' : a:candidate.action__dict_name,
				\ 'valname'   : a:candidate.action__valname,
				\ 'kind'      : a:candidate.action__kind,
				\ 'only_'     : 1,
				\ }
	call unite#start_temporary([['settings_ex_list_select', tmp_d]], {'default_action' : 'a_toggle'})
endfunction "}}}
let s:kind_settings_ex_select = deepcopy(s:kind)
"}}}
" s:kind_settings_ex_list "{{{
let s:kind = { 
			\ 'name'           : 'settings_ex_list',
			\ 'default_action' : 'a_toggle',
			\ 'action_table'   : {},
			\ 'parents': ['settings_common'],
			\ }
" action
let s:kind.action_table.a_toggle = {
			\ 'description' : '選択',
			\ 'is_quit'     : 0,
			\ }
function! s:kind.action_table.a_toggle.func(candidate) "{{{
	let tmp_d = {
				\ 'dict_name' : a:candidate.action__dict_name,
				\ 'valname'   : a:candidate.action__valname,
				\ 'kind'      : a:candidate.action__kind,
				\ 'only_'     : 0,
				\ }
	call unite#start_temporary([['settings_ex_list_select', tmp_d]])
endfunction "}}}
let s:kind.action_table.edit = {
			\ 'description' : '設定編集',
			\ 'is_quit'     : 0,
			\ }"
function! s:kind.action_table.edit.func(candidate) "{{{
	let dict_name = a:candidate.action__dict_name
	let valname   = a:candidate.action__valname
	let kind      = a:candidate.action__kind
	let tmp       = input("",string(s:get_orig(dict_name, valname, kind)))

	if tmp != ""
		exe 'let val = '.tmp
		call s:set(dict_name, valname, kind, val)
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
			\ 'parents': [],
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
	let valname   = a:candidates[0].action__valname
	let kind      = a:candidates[0].action__kind
	let dict_name = a:candidates[0].action__dict_name
	let nums      = map(copy(a:candidates), 'v:val.action__num')

	" 削除する
	call s:delete(dict_name, valname, kind, nums)

	call s:common_out(dict_name)
endfunction "}}}
let s:kind_settings_ex_list_select = deepcopy(s:kind)
"}}}
"
"s:source_settings_ex "{{{
let s:source = {
			\ 'name'        : 'settings_ex',
			\ 'description' : '',
			\ 'syntax'      : 'uniteSource__settings',
			\ 'hooks'       : {},
			\ 'is_quit'     : 0,
			\ }
let s:source.hooks.on_syntax = function("unite_setting#sub_setting_syntax")
function! s:source.hooks.on_init(args, context) "{{{
	if len(a:args) > 0
		let a:context.source__dict_name = a:args[0]
	else
		let a:context.source__dict_name = 'g:unite_pf_data'
	endif
endfunction "}}}
function! s:source.gather_candidates(args, context) "{{{
	" 設定する項目
	let dict_name = a:context.source__dict_name
	exe 'let tmp_d = '.dict_name

	call unite#print_source_message(dict_name, 'settings_ex')

	let orders  = tmp_d.__order
	let kind    = '__common'

	" 辞書名と、取得関数が必要になる

	return map( copy(orders), "{
				\ 'word'              : s:get_source_word(dict_name, v:val, kind),
				\ 'kind'              : s:get_source_kind(dict_name, v:val, kind),
				\ 'action__kind'      : kind,
				\ 'action__valname'   : v:val,
				\ 'action__dict_name' : dict_name,
				\ }")

endfunction "}}}
let s:source_settings_ex = deepcopy(s:source)
"}}}
"s:source_settings_ex_list_select"{{{
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
		let a:context.source__valname   = a:args[0].valname
		let a:context.source__kind      = a:args[0].kind
		let a:context.source__only      = a:args[0].only_
	endif
endfunction "}}}
function! s:source.gather_candidates(args, context) "{{{

	" 設定する項目
	if len(a:args) > 0
		let dict_name = a:args[0].dict_name
		let valname   = a:args[0].valname
		let kind      = a:args[0].kind
	endif

	" 引数を取得する
	let words = s:get_orig(dict_name, valname, kind)[1:]

	let val  = 0
	let num_ = 0

	let strs  = s:get_strs_on_off(dict_name, valname, kind)
	call insert(strs, ' NULL ')

	let rtns = []
	for word in strs 
		let rtns += [{
					\ 'word'              : word,
					\ 'kind'              : 'settings_ex_list_select',
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
					\ 'kind' : 'settings_ex_list_select',
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
let s:source_settings_ex_list_select = deepcopy(s:source)
"}}}

call unite#define_kind   ( s:kind_settings_ex_select        )  | unlet s:kind_settings_ex_select
call unite#define_kind   ( s:kind_settings_ex_bool          )  | unlet s:kind_settings_ex_bool
call unite#define_kind   ( s:kind_settings_ex_var           )  | unlet s:kind_settings_ex_var 
call unite#define_kind   ( s:kind_settings_ex_list          )  | unlet s:kind_settings_ex_list
call unite#define_kind   ( s:kind_settings_ex_list_select   )  | unlet s:kind_settings_ex_list_select
call unite#define_source ( s:source_settings_ex             )  | unlet s:source_settings_ex
call unite#define_source ( s:source_settings_ex_list_select )  | unlet s:source_settings_ex_list_select


