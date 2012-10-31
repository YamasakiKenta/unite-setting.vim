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
		" BIT ���L���Ȃ烊�X�g�ɒǉ�����
		if bit % 2 
			let nums += [val]
		endif

		" Bit ���X�g�̍X�V
		let bit = bit / 2

		" ���X�g�ʒu�̍X�V
		let val += 1
	endwhile

	return nums

endfunction "}}}


