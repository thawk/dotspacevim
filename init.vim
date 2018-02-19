" Dark powered mode of SpaceVim, generated by SpaceVim automatically.

" layers {{{
call SpaceVim#layers#load('autocomplete')
call SpaceVim#layers#disable('incsearch')
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
call SpaceVim#layers#load('tags')
call SpaceVim#layers#load('tools#screensaver')

" If there is a particular plugin you don't like, you can define this
" variable to disable them entirely:
let g:spacevim_disabled_plugins=['vim-gutentags']
" }}}

" Native settings {{{
set ignorecase
set smartcase
set wildmode=longest:full,full
set wildmenu
" }}}

" SpaceVim Settings {{{
let g:spacevim_enable_debug = 0
" Enable/Disable key frequency catching of SpaceVim
let g:spacevim_enable_key_frequency = 1
let g:spacevim_default_indent = 4
let g:spacevim_windows_smartclose = ''  " 恢复q的正常用途

"" Wildignore {{{
let g:spacevim_wildignore .= ',.*/'  " 忽略隐藏目录
let g:spacevim_wildignore .= ',bin*/**/gcc-*/'
"" }}}

let g:spacevim_realtime_leader_guide = 1
let g:spacevim_enable_vimfiler_welcome = 1

let g:deoplete#auto_complete_delay = 150
let g:spacevim_enable_tabline_filetype_icon = 1
let g:spacevim_enable_statusline_display_mode = 0
let g:spacevim_enable_os_fileformat_icon = 1
let g:spacevim_buffer_index_type = 1

if has('python3')
    let g:ctrlp_map = ''
    nnoremap <silent> <C-p> :Denite file_rec<CR>
else
    call SpaceVim#custom#SPC('nnoremap', ['f', 'f'], 'UniteWithBufferDir file', 'Find files in the directory of the current buffer', 1)
endif

let g:spacevim_snippet_engine = 'ultisnips'
" }}}

" Plugin settings {{{

"" Projectionist {{{
let g:projectionist_heuristics = {
            \ 'Makefile': {
            \   '*': {'make': 'make'},
            \ },
            \ 'Jamroot|Jamroot.v2': {
            \   '*': {'make': 'b2'},
            \ },
            \ }
"" }}}

"" clang2 {{{
let g:clang2_placeholder_next = ''
let g:clang2_placeholder_prev = ''
"" }}}

"" Neomake {{{
let g:neomake_vim_enabled_makers = []

if executable('vimlint')
    call add(g:neomake_vim_enabled_makers, 'vimlint')
endif
if executable('vint')
    call add(g:neomake_vim_enabled_makers, 'vint')
endif
"" }}}

"" ultisnips {{{
let g:ultisnips_python_quoting_style = "single"
let g:ultisnips_python_triple_quoting_style = "double"
let g:ultisnips_python_style = "google"
"" }}}

"" vim-pydocstring {{{
let g:pydocstring_templates_dir = '~/.SpaceVim.d/templates/pydocstring/google'
"" }}}
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

"" vim-fswitch {{{
call add(g:spacevim_custom_plugins, [ 'derekwyatt/vim-fswitch', {
            \ 'lazy' : 1,
            \ 'on_func' : ['FSwitch'],
            \ 'on_cmd' : ['FSHere','FSRight','FSSplitRight','FSLeft','FSSplitLeft','FSAbove','FSSplitAbove','FSBelow','FSSplitBelow'],
            \ }])

    let g:fsnonewfiles=1
    " 可以用:A在.h/.cpp间切换
    augroup vimrc_fswitch
        autocmd!

        autocmd! BufEnter *.h,*.hpp
                    \  let b:fswitchdst='cpp,c,ipp,cxx'
                    \| let b:fswitchlocs='reg:/include/src/,reg:/include.*/src/,ifrel:|/include/|../src|,reg:!\<include/\w\+/!src/!,reg:!\<include/\(\w\+/\)\{2}!src/!,reg:!\<include/\(\w\+/\)\{3}!src/!,reg:!\<include/\(\w\+/\)\{4}!src/!,reg:!sscc\(/[^/]\+\|\)/.*!libs\1/**!'
        autocmd! BufEnter *.c,*.cpp,cxx,*.ipp
                    \  let b:fswitchdst='h,hpp'
                    \| let b:fswitchlocs='reg:/src/include/,reg:|/src|/include/**|,ifrel:|/src/|../include|,reg:|libs/.*|**|'
        autocmd! BufEnter *.xml
                    \  let b:fswitchdst='rnc'
                    \| let b:fswitchlocs='./'
        autocmd! BufEnter *.rnc
                    \  let b:fswitchdst='xml'
                    \| let b:fswitchlocs='./'

        autocmd! FileType c,cpp,xml,rnc
                    \  command! -buffer A :call FSwitch('%', '')
                    \| call SpaceVim#custom#SPCGroupName(['l', 'j'], '+Jump')
                    \| call SpaceVim#custom#SPC('nnoremap <buffer>', ['l', 'j', 'a'], 'FSHere', 'Switch to the file and load it into the current window', 1)
                    \| call SpaceVim#custom#SPC('nnoremap <buffer>', ['l', 'j', 'A'], 'FSSplitRight', 'Switch to the file and load it into a new window split on the right', 1)
                    \| call SpaceVim#custom#SPC('nnoremap <buffer>', ['l', 'j', 'l'], 'FSRight', 'Switch to the file and load it into the window on the right', 1)
                    \| call SpaceVim#custom#SPC('nnoremap <buffer>', ['l', 'j', 'L'], 'FSSplitRight', 'Switch to the file and load it into a new window split on the right', 1)
                    \| call SpaceVim#custom#SPC('nnoremap <buffer>', ['l', 'j', 'h'], 'FSLeft', 'Switch to the file and load it into the window on the left', 1)
                    \| call SpaceVim#custom#SPC('nnoremap <buffer>', ['l', 'j', 'H'], 'FSSplitLeft', 'Switch to the file and load it into a new window split on the left', 1)
                    \| call SpaceVim#custom#SPC('nnoremap <buffer>', ['l', 'j', 'k'], 'FSAbove', 'Switch to the file and load it into the window above', 1)
                    \| call SpaceVim#custom#SPC('nnoremap <buffer>', ['l', 'j', 'K'], 'FSSplitAbove', 'Switch to the file and load it into a new window split above', 1)
                    \| call SpaceVim#custom#SPC('nnoremap <buffer>', ['l', 'j', 'j'], 'FSBelow', 'Switch to the file and load it into the window below', 1)
                    \| call SpaceVim#custom#SPC('nnoremap <buffer>', ['l', 'j', 'J'], 'FSSplitBelow', 'Switch to the file and load it into a new window split below', 1)
    augroup END
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
"let g:spacevim_windows_leader = 's'

" call SpaceVim#custom#SPCGroupName(['G'], '+TestGroup')
" call SpaceVim#custom#SPC('nore', ['G', 't'], 'echom 1', 'echomessage 1', 1)]])

call SpaceVim#custom#SPC('nnoremap', ['j', 'i'], 'Denite outline unite:outline', 'jump to a definition in buffer', 1)
" }}}

runtime cpp_path_settings.vim

