let s:save_cpo = &cpo
set cpo&vim

let s:V      = vital#of('unite-setting.vim')
let s:Sjis   = s:V.import('Mind.Sjis')
let s:Common = s:V.import('Mind.Common')

function! unite_setting#util#save(...)
	return call(s:Common.save, a:000)
endfunction
function! unite_setting#util#printf(...)
	return call(s:Sjis.printf, a:000)
endfunction
function! unite_setting#util#load(...)
	return call(s:Common.load, a:000)
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo