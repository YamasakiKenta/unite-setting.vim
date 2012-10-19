function! unite_setting#sub_setting_syntax(args, context) "{{{
	syntax match uniteSource__settings_choose /<.\{-}>/ containedin=uniteSource__settings contained
	syntax match uniteSource__settings_group /".*"/ containedin=uniteSource__settings contained
	highlight default link uniteSource__settings_choose Type 
	highlight default link uniteSource__settings_group Underlined  
endfunction "}}}

