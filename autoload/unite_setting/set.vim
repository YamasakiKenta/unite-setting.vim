function! unite_setting#set#name_from_data(valname, val) "{{{
"function! s:set_name_from_data(valname, val)
	exe 'let '.a:valname.' = a:val'
endfunction "}}}
function! unite_setting#set#name_from_str(valname, str) "{{{
"function! s:set_name_from_data(valname, val)
	exe 'let '.a:valname.' = '.a:str
endfunction "}}}
