function! unite_setting#sub_setting_syntax(args, context) "{{{
	syntax match uniteSource__settings_choose /<.\{-}>/ containedin=uniteSource__settings contained
	syntax match uniteSource__settings_group /".*"/ containedin=uniteSource__settings contained
	highlight default link uniteSource__settings_choose Type 
	highlight default link uniteSource__settings_group Underlined  
endfunction "}}}
function! unite_setting#get_nums_form_bit(bit) "{{{

	let nums = []
	let bit  = a:bit
	let val  = 0

	while bit > 0 
		" BIT が有効ならリストに追加する
		if bit % 2 
			let nums += [val]
		endif

		" Bit リストの更新
		let bit = bit / 2

		" リスト位置の更新
		let val += 1
	endwhile

	return nums

endfunction "}}}


