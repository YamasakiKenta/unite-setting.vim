let s:save_cpo = &cpo
set cpo&vim

function! s:next_items(num, items) "{{{
	" ********************************************************************************
	" @par           {items} �̔z�񐔂𒴂��Ȃ��悤�� {num} �����Z����
	" @param[in]     num   = 0
	" @param[in]     items = [1, 2, 3]
	" @return        num   = 1
	" ********************************************************************************
	let num_ = a:num + 1
	let num_ = num_ < len(a:items) ? num_ : 0
	return num_
endfunction
" }}}

function! unite_setting#kind#set_next(dict_name, valname_ex, kind) "{{{
	let type = unite_setting_ex2#var(a:dict_name)[a:valname_ex].__type

	if type == 'bool'
		let val = unite_setting#data#get(a:dict_name, a:valname_ex) ? 0 : 1
	elseif type == 'select'
		let val = unite_setting_ex2#get_orig(a:dict_name, a:valname_ex, a:kind)
		let val.num = s:next_items(val.num, val.items)
	elseif type == 'list_ex'
		let val = unite_setting_ex2#get_orig(a:dict_name, a:valname_ex, a:kind)
		call map(val.nums, 's:next_items(v:val, val.items)')
	else
		echo 'non supoert....'
		call input("")
	endif

	call unite_setting#kind#set(a:dict_name, a:valname_ex, a:kind, val )
endfunction
"}}}
function! unite_setting#kind#set(dict_name, valname_ex, kind, val) "{{{

	if exists(a:dict_name.'["'.a:valname_ex.'"]["'.a:kind.'"]')
		let valname = a:dict_name.'["'.a:valname_ex.'"]["'.a:kind.'"]'
	else
		let valname = a:valname_ex
	endif

	exe 'let '.valname.' = a:val'

	if a:valname_ex =~ '^g:'
		let tmp = unite_setting#data#get(a:dict_name, a:valname_ex)
		exe 'let '.a:valname_ex.' = tmp'
	endif

endfunction
"}}}

if exists('s:save_cpo')
	let &cpo = s:save_cpo
	unlet s:save_cpo
else
	set cpo&
endif