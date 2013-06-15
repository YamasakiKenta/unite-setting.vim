let s:save_cpo = &cpo
set cpo&vim

function! unite_setting_2#sub_setting_syntax(args, context) 
	syntax match uniteSource__settings_choose /<.\{-}>/ containedin=uniteSource__settings contained
	syntax match uniteSource__settings_const /[.\{-}]/ containedin=uniteSource__settings contained
	highlight default link uniteSource__settings_choose Type 
	highlight default link uniteSource__settings_const Underlined  
endfunction

function! unite_setting_2#version()
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo

