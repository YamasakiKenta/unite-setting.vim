if 0
function! unite_setting#common_out(dict_name) "{{{
""function! s:common_out(dict_name)
	call unite#force_redraw()
endfunction "}}}
endif
function! unite_setting#sub_setting_syntax(args, context) "{{{
	syntax match uniteSource__settings_choose /<.\{-}>/ containedin=uniteSource__settings contained
	syntax match uniteSource__settings_group /".*"/ containedin=uniteSource__settings contained
	highlight default link uniteSource__settings_choose Type 
	highlight default link uniteSource__settings_group Underlined  
endfunction "}}}

