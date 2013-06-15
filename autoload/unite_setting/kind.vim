let s:save_cpo = &cpo
set cpo&vim

function! s:next_items(num, items) "{{{
	" ********************************************************************************
	" @par           {items} ‚Ì”z—ñ”‚ğ’´‚¦‚È‚¢‚æ‚¤‚É {num} ‚ğ‰ÁZ‚·‚é
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
	exe 'let tmp_d = '.a:dict_name
	let type = unite_setting_ex2#get_type(a:dict_name, a:valname_ex, a:kind)

	if type == 'bool'
		let val = unite_setting_ex_3#get(a:dict_name, a:valname_ex) ? 0 : 1
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

	call unite_setting_ex2#set(a:dict_name, a:valname_ex, a:kind, val )
endfunction
"}}}

if exists('s:save_cpo')
	let &cpo = s:save_cpo
	unlet s:save_cpo
else
	set cpo&
endif
