"call unite_setting_ex#load('g:unite_test_data' , '~/test_setting.vim')

let g:unite_test_data = {}
call unite_setting_ex#add('g:unite_test_data'  , 'bool'                , '' , 'bool'    , 0)
call unite_setting_ex#add('g:unite_test_data'  , 'list'                , '' , 'list'    , [[1], 'aaa', 'bbb'])
call unite_setting_ex#add('g:unite_test_data'  , 'list_ex'             , '' , 'list_ex' , [[1], 'aaa', 'bbb'])
call unite_setting_ex#add('g:unite_test_data'  , 'select'              , '' , 'select'  , [[1], 'aaa', 'bbb'])
call unite_setting_ex#add('g:unite_test_data'  , 'var'                 , '' , 'var'     , 0)
let g:unite_test_data.__file = expand('~/test_setting.vim')

nnoremap ;ii<CR> :<C-u>call unite#start([['settings_ex', 'g:unite_test_data']])<CR>
