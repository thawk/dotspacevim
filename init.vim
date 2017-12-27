" Dark powered mode of SpaceVim, generated by SpaceVim automatically.

" layers {{{
call SpaceVim#layers#load('incsearch')
call SpaceVim#layers#load('lang#c')
" call SpaceVim#layers#load('lang#elixir')
call SpaceVim#layers#load('lang#go')
" call SpaceVim#layers#load('lang#haskell')
call SpaceVim#layers#load('lang#java')
call SpaceVim#layers#load('lang#javascript')
call SpaceVim#layers#load('lang#lua')
" call SpaceVim#layers#load('lang#perl')
" call SpaceVim#layers#load('lang#php')
call SpaceVim#layers#load('lang#python')
" call SpaceVim#layers#load('lang#rust')
" call SpaceVim#layers#load('lang#swig')
call SpaceVim#layers#load('lang#tmux')
call SpaceVim#layers#load('lang#vim')
call SpaceVim#layers#load('lang#xml')
call SpaceVim#layers#load('shell')
call SpaceVim#layers#load('tools#screensaver')

" If there is a particular plugin you don't like, you can define this
" variable to disable them entirely:
let g:spacevim_disabled_plugins=[]
" }}}

" Settings {{{
let g:spacevim_enable_debug = 1
" Enable/Disable key frequency catching of SpaceVim
let g:spacevim_enable_key_frequency = 1

let g:spacevim_realtime_leader_guide = 1
let g:spacevim_enable_vimfiler_welcome = 1

let g:deoplete#auto_complete_delay = 150
let g:spacevim_enable_tabline_filetype_icon = 1
let g:spacevim_enable_statusline_display_mode = 0
let g:spacevim_enable_os_fileformat_icon = 1
let g:spacevim_buffer_index_type = 1
let g:neomake_vim_enabled_makers = []

if executable('vimlint')
    call add(g:neomake_vim_enabled_makers, 'vimlint')
endif
if executable('vint')
    call add(g:neomake_vim_enabled_makers, 'vint')
endif
if has('python3')
    let g:ctrlp_map = ''
    nnoremap <silent> <C-p> :Denite file_rec<CR>
endif
let g:clang2_placeholder_next = ''
let g:clang2_placeholder_prev = ''
" }}}

" Additional plugins {{{
let g:spacevim_custom_plugins = []

"" vim-tmux-navigator {{{
call add(g:spacevim_custom_plugins,
      \ [ 'christoomey/vim-tmux-navigator', {
      \     'lazy' : 1,
      \     'on_cmd' : ['TmuxNavigateLeft', 'TmuxNavigateDown', 'TmuxNavigateUp', 'TmuxNavigateRight', 'TmuxNavigatePrevious'],
      \   },
      \ ])

" 不希望map <C-\>，因此自行map
let g:tmux_navigator_no_mappings = 1

nnoremap <silent> <c-h> :TmuxNavigateLeft<CR>
nnoremap <silent> <c-j> :TmuxNavigateDown<CR>
nnoremap <silent> <c-k> :TmuxNavigateUp<CR>
nnoremap <silent> <c-l> :TmuxNavigateRight<CR>
"" }}}

"" vim-asciidoc-folding {{{
call add(g:spacevim_custom_plugins,
      \ [ 'thawk/vim-asciidoc-folding', {
      \     'lazy' : 1,
      \     'on_ft' : 'asciidoc',
      \   },
      \ ])
let g:asciidoc_fold_style = 'nested'
let g:asciidoc_fold_override_foldtext = 1
"" }}}

"" vim-bracketed-paste {{{
call add(g:spacevim_custom_plugins, [ 'ConradIrwin/vim-bracketed-paste' ])
let g:bracketed_paste_tmux_wrap = 0
"" }}}

" }}}

" Colorscheme && Fonts {{{
let g:spacevim_colorscheme = 'NeoSolarized'
let g:spacevim_colorscheme_bg = 'dark'
"let g:spacevim_enable_guicolors = 0

" set the guifont
"let g:spacevim_guifont = 'DejaVu\ Sans\ Mono\ for\ Powerline\ 12'
if WINDOWS()
  " use fontlink to map fonts into Consolas, so just use Consolas is OK
    let g:spacevim_guifont = 'Consolas:h13:cANSI:qDRAFT'
endif
" }}}

" Key mappings {{{
" Set unite work flow shortcut leader [Unite], default is `f`
let g:spacevim_unite_leader = '\f'
let g:spacevim_denite_leader = '\F'

" call SpaceVim#custom#SPCGroupName(['G'], '+TestGroup')
" call SpaceVim#custom#SPC('nore', ['G', 't'], 'echom 1', 'echomessage 1', 1)]])

call SpaceVim#custom#SPC('nnoremap', ['j', 'i'], 'Denite outline unite:outline', 'jump to a definition in buffer', 1)
" }}}
