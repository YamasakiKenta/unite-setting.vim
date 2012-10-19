function! unite_setting#get#data_from_name_def(default, valname) "{{{
	let tmp = unite_setting#get#data_from_name(a:valname)
	if type(a:default) != type(tmp)
		unlet tmp
		let tmp = a:default
	endif
	return tmp
endfunction "}}}
