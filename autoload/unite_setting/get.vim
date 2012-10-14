function! unite_setting#get#type_from_name(valname) "{{{
	exe 'return type('.a:valname.')'
endfunction "}}}
function! unite_setting#get#str_data_from_name(valname) "{{{
"function! s:get_str_data_from_name(valname)
	exe 'let rtn = string('.a:valname.')'
	return rtn
endfunction "}}}
function! unite_setting#get#data_from_name(valname) "{{{
	exe 'let tmp = '.a:valname
	return tmp
endfunction "}}}
function! unite_setting#get#data_from_name_def(default, valname) "{{{
	let tmp = unite_setting#get#data_from_name(a:valname)
	if type(a:default) != type(tmp)
		let tmp = a:default
	endif
	return tmp
endfunction "}}}
