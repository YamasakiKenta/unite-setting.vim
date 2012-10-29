nnoremap ;uu<CR> :<C-u>call unite#start([['settings_ex', 'g:unite_data']])<CR>

let file_ = expand('~/unite_setting.vim')
"if filereadable(file_) 
if 0
	call unite_setting_ex#load('g:unite_data', file_)
else
	call unite_setting_ex#add('g:unite_data', 'g:unite_update_time',
				\ 'Update time interval of candidates for each input of narrowing text.  In Msec.',
				\ 'select', [1, 500, 750, 1000])

	call unite_setting_ex#add('g:unite_data', 'g:unite_enable_start_insert',
				\ 'If this variable is 1, unite buffer will be in Insert Mode',
				\ 'bool', 0)

	call unite_setting_ex#add('g:unite_data' , 'g:unite_enable_split_vertically'               , '' , 'bool' , get(g: , 'unite_enable_split_vertically'               , 0) )
	call unite_setting_ex#add('g:unite_data' , 'g:unite_enable_use_short_source_names'         , '' , 'bool' , get(g: , 'unite_enable_use_short_source_names'         , 0) )
	call unite_setting_ex#add('g:unite_data' , 'g:unite_kind_openable_cd_command'              , '' , 'bool' , get(g: , 'unite_kind_openable_cd_command'              , 0) )
	call unite_setting_ex#add('g:unite_data' , 'g:unite_kind_openable_lcd_command'             , '' , 'bool' , get(g: , 'unite_kind_openable_lcd_command'             , 0) )
	call unite_setting_ex#add('g:unite_data' , 'g:unite_kind_openable_persist_open_blink_time' , '' , 'bool' , get(g: , 'unite_kind_openable_persist_open_blink_time' , 0) )
	call unite_setting_ex#add('g:unite_data' , 'g:unite_source_history_yank_enable'            , '' , 'bool' , get(g: , 'unite_source_history_yank_enable'            , 0) )
	call unite_setting_ex#add('g:unite_data' , 'g:unite_source_line_enable_highlight'          , '' , 'bool' , get(g: , 'unite_source_line_enable_highlight'          , 0) )
	call unite_setting_ex#add('g:unite_data' , 'g:unite_abbr_highlight'                        , '' , 'var'  , get(g: , 'unite_abbr_highlight'                        , 0) )
	call unite_setting_ex#add('g:unite_data' , 'g:unite_cursor_line_highlight'                 , '' , 'var'  , get(g: , 'unite_cursor_line_highlight'                 , 0) )
	call unite_setting_ex#add('g:unite_data' , 'g:unite_data_directory'                        , '' , 'var'  , get(g: , 'unite_data_directory'                        , 0) )
	call unite_setting_ex#add('g:unite_data' , 'g:unite_kind_jump_list_after_jump_scroll'      , '' , 'var'  , get(g: , 'unite_kind_jump_list_after_jump_scroll'      , 0) )
	call unite_setting_ex#add('g:unite_data' , 'g:unite_no_default_keymappings'                , '' , 'var'  , get(g: , 'unite_no_default_keymappings'                , 0) )
	call unite_setting_ex#add('g:unite_data' , 'g:unite_quick_match_table'                     , '' , 'var'  , get(g: , 'unite_quick_match_table'                     , 0) )
	call unite_setting_ex#add('g:unite_data' , 'g:unite_source_alias_aliases'                  , '' , 'var'  , get(g: , 'unite_source_alias_aliases'                  , 0) )
	call unite_setting_ex#add('g:unite_data' , 'g:unite_source_bookmark_directory'             , '' , 'var'  , get(g: , 'unite_source_bookmark_directory'             , 0) )
	call unite_setting_ex#add('g:unite_data' , 'g:unite_source_directory_mru_directory'        , '' , 'var'  , get(g: , 'unite_source_directory_mru_directory'        , 0) )
	call unite_setting_ex#add('g:unite_data' , 'g:unite_source_directory_mru_filename_format'  , '' , 'var'  , get(g: , 'unite_source_directory_mru_filename_format'  , 0) )
	call unite_setting_ex#add('g:unite_data' , 'g:unite_source_directory_mru_ignore_pattern'   , '' , 'var'  , get(g: , 'unite_source_directory_mru_ignore_pattern'   , 0) )
	call unite_setting_ex#add('g:unite_data' , 'g:unite_source_directory_mru_limit'            , '' , 'var'  , get(g: , 'unite_source_directory_mru_limit'            , 0) )
	call unite_setting_ex#add('g:unite_data' , 'g:unite_source_directory_mru_time_format'      , '' , 'var'  , get(g: , 'unite_source_directory_mru_time_format'      , 0) )
	call unite_setting_ex#add('g:unite_data' , 'g:unite_source_file_ignore_pattern'            , '' , 'var'  , get(g: , 'unite_source_file_ignore_pattern'            , 0) )
	call unite_setting_ex#add('g:unite_data' , 'g:unite_source_file_mru_file'                  , '' , 'var'  , get(g: , 'unite_source_file_mru_file'                  , 0) )
	call unite_setting_ex#add('g:unite_data' , 'g:unite_source_file_mru_filename_format'       , '' , 'var'  , get(g: , 'unite_source_file_mru_filename_format'       , 0) )
	call unite_setting_ex#add('g:unite_data' , 'g:unite_source_file_mru_ignore_pattern'        , '' , 'var'  , get(g: , 'unite_source_file_mru_ignore_pattern'        , 0) )
	call unite_setting_ex#add('g:unite_data' , 'g:unite_source_file_mru_limit'                 , '' , 'var'  , get(g: , 'unite_source_file_mru_limit'                 , 0) )
	call unite_setting_ex#add('g:unite_data' , 'g:unite_source_file_mru_time_format'           , '' , 'var'  , get(g: , 'unite_source_file_mru_time_format'           , 0) )
	call unite_setting_ex#add('g:unite_data' , 'g:unite_source_file_rec_ignore_pattern'        , '' , 'var'  , get(g: , 'unite_source_file_rec_ignore_pattern'        , 0) )
	call unite_setting_ex#add('g:unite_data' , 'g:unite_source_file_rec_min_cache_files'       , '' , 'var'  , get(g: , 'unite_source_file_rec_min_cache_files'       , 0) )
	call unite_setting_ex#add('g:unite_data' , 'g:unite_source_find_command'                   , '' , 'var'  , get(g: , 'unite_source_find_command'                   , 0) )
	call unite_setting_ex#add('g:unite_data' , 'g:unite_source_find_ignore_pattern'            , '' , 'var'  , get(g: , 'unite_source_find_ignore_pattern'            , 0) )
	call unite_setting_ex#add('g:unite_data' , 'g:unite_source_find_max_candidates'            , '' , 'var'  , get(g: , 'unite_source_find_max_candidates'            , 0) )
	call unite_setting_ex#add('g:unite_data' , 'g:unite_source_grep_command'                   , '' , 'var'  , get(g: , 'unite_source_grep_command'                   , 0) )
	call unite_setting_ex#add('g:unite_data' , 'g:unite_source_grep_default_opts'              , '' , 'var'  , get(g: , 'unite_source_grep_default_opts'              , 0) )
	call unite_setting_ex#add('g:unite_data' , 'g:unite_source_grep_ignore_pattern'            , '' , 'var'  , get(g: , 'unite_source_grep_ignore_pattern'            , 0) )
	call unite_setting_ex#add('g:unite_data' , 'g:unite_source_grep_max_candidates'            , '' , 'var'  , get(g: , 'unite_source_grep_max_candidates'            , 0) )
	call unite_setting_ex#add('g:unite_data' , 'g:unite_source_grep_recursive_opt'             , '' , 'var'  , get(g: , 'unite_source_grep_recursive_opt'             , 0) )
	call unite_setting_ex#add('g:unite_data' , 'g:unite_source_grep_search_word_highlight'     , '' , 'var'  , get(g: , 'unite_source_grep_search_word_highlight'     , 0) )
	call unite_setting_ex#add('g:unite_data' , 'g:unite_source_history_yank_file'              , '' , 'var'  , get(g: , 'unite_source_history_yank_file'              , 0) )
	call unite_setting_ex#add('g:unite_data' , 'g:unite_source_history_yank_limit'             , '' , 'var'  , get(g: , 'unite_source_history_yank_limit'             , 0) )
	call unite_setting_ex#add('g:unite_data' , 'g:unite_source_line_search_word_highlight'     , '' , 'var'  , get(g: , 'unite_source_line_search_word_highlight'     , 0) )
	call unite_setting_ex#add('g:unite_data' , 'g:unite_source_menu_menus'                     , '' , 'var'  , get(g: , 'unite_source_menu_menus'                     , 0) )
	call unite_setting_ex#add('g:unite_data' , 'g:unite_source_vimgrep_ignore_pattern'         , '' , 'var'  , get(g: , 'unite_source_vimgrep_ignore_pattern'         , 0) )
	call unite_setting_ex#add('g:unite_data' , 'g:unite_source_vimgrep_search_word_highlight'  , '' , 'var'  , get(g: , 'unite_source_vimgrep_search_word_highlight'  , 0) )
	call unite_setting_ex#add('g:unite_data' , 'g:unite_split_rule'                            , '' , 'var'  , get(g: , 'unite_split_rule'                            , 0) )
	call unite_setting_ex#add('g:unite_data' , 'g:unite_winheight'                             , '' , 'var'  , get(g: , 'unite_winheight'                             , 0) )
	call unite_setting_ex#add('g:unite_data' , 'g:unite_winwidth'                              , '' , 'var'  , get(g: , 'unite_winwidth'                              , 0) )
endif


