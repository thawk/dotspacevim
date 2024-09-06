" vim: fileencoding=utf-8 foldmethod=marker foldlevel=0:

function! myspacevim#before() abort " {{{
    if filereadable($HOME . "/.myspacevim.local")
        exec "source " . $HOME . "/.myspacevim.local"
    endif

    "if executable('node') && executable('yarn') && ! get(g:, 'spacevim_autocomplete_method', '')
    "    " Use coc.vim only if we have node && yarn installed
    "    let g:spacevim_autocomplete_method = 'coc'
    "endif

    call s:setup_conemu()
    call s:setup_lsp()
    call myspacevim#colorscheme#autoload()

    " Global configurations {{{
    " Add rooter for haskell
    call add(g:spacevim_project_rooter_patterns, 'stack.yaml')
    " Add rooter for Boost.Build
    call add(g:spacevim_project_rooter_patterns, 'Jamroot')
    call add(g:spacevim_project_rooter_patterns, 'Jamroot.v2')
    " }}}

    call s:setup_mapping()
    call s:setup_plugin()
    call s:setup_autocmd()

    if !exists(':Make')
        command! -nargs=* Make :call s:async_make(<q-args>)
    endif
endfunction " }}}

function! myspacevim#after() abort " {{{
    set ignorecase
    set smartcase   " Depending on 'ignorecase', will override 'ignorecase' if the search pattern contains upper case characters
    set wildmode=longest:full,full
    set wildmenu
    " Fix compatibility of CJK long lines.
    set nolinebreak

    set wrap

    call s:setup_plugin_after()

    if filereadable('/usr/share/dict/words')
        if &dictionary == ''
            set dictionary+=/usr/share/dict/words
        endif
    endif

    "    if executable('chez')
    "        call SpaceVim#plugins#runner#reg_runner('scheme', 'chez --script %s')
    "        call SpaceVim#plugins#repl#reg('scheme', ['chez', '--quiet'])
    "    else
    "        call SpaceVim#plugins#runner#reg_runner('scheme', 'scheme --script %s')
    "        call SpaceVim#plugins#repl#reg('scheme', ['scheme', '--quiet'])
    "    endif
endfunction " }}}

function! myspacevim#IncludePathHook(config) " {{{
    if has_key(a:config, 'c_include_path')
        let include = a:config['c_include_path']
        if type(include) == type("")
            let raw_path = has('win32') ? tr(include, '\', '/') : include
            let paths = split(raw_path, ':')
            let root = SpaceVim#plugins#projectmanager#current_root()
            for p in paths
                let &l:path .= ',' . root . p
            endfor
        endif
    endif
endfunction " }}}

function! s:goyo_enter() " {{{
    if executable('tmux')
        silent !tmux set status off
        silent !tmux list-panes -F '\#F' | grep -q Z || tmux resize-pane -Z
    endif
endfunction " }}}

function! s:goyo_leave() " {{{
    if executable('tmux')
        silent !tmux set status on
        silent !tmux list-panes -F '\#F' | grep -q Z && tmux resize-pane -Z
    endif
endfunction " }}}

function! s:setup_lsp() " {{{
    let lsp_servers = {
                \ 'c' : 'clangd',
                \ 'cpp' : 'clangd',
                \ 'css' : 'css-languageserver',
                \ 'dockerfile' : 'docker-langserver',
                \ 'go' : 'gopls',
                \ 'haskell' : {'hie':'hie-wrapper'},
                \ 'html' : 'html-languageserver',
                \ 'javascript' : {'tsserver': 'typescript-language-server'},
                \ 'javascriptreact' : {'tsserver': 'typescript-language-server'},
                \ 'objc' : 'clangd',
                \ 'objcpp' : 'clangd',
                \ 'php' : {'':'php', 'phpactor':'phpactor'},
                \ 'purescript' : 'purescript-language-server',
                \ 'python' : 'pyls',
                \ 'reason' : 'ocaml-language-server',
                \ 'ruby' : 'solargraph',
                \ 'rust' : 'rustup',
                \ 'scala' : 'metals-vim',
                \ 'sh' : {'bashls':'bash-language-server'},
                \ 'typescript' : {'tsserver': 'typescript-language-server'},
                \ 'typescriptreact' : {'tsserver': 'typescript-language-server'},
                \ 'vim' : {'vimls':'vim-language-server'},
                \ 'vue' : 'vls'
                \ }

    let filetypes = []       " for old version
    let enabled_clients = [] " for neovim 0.50 and above
    let executables = {}

    for [lang, lsp] in items(lsp_servers)
        if type(lsp) == v:t_dict
            " lspconfig client name -> executable. empty name means not such lspconfig
            for [c, e] in items(lsp)
                if (has_key(executables, e) && !executables[e])
                    continue
                endif

                if ! executable(e)
                    let executables[e] = 0
                    continue
                endif

                let executables[e] = 1
                call add(filetypes, lang)
                if c != ""
                    call add(enabled_clients, c)
                endif
            endfor
        elseif type(lsp) == v:t_list
            for e in lsp
                if (has_key(executables, e) && !executables[e])
                    continue
                endif

                if ! executable(e)
                    let executables[e] = 0
                    continue
                endif

                let executables[e] = 1

                call add(filetypes, lang)
                call add(enabled_clients, e)
            endfor
        else
            if (has_key(executables, lsp) && !executables[lsp])
                continue
            endif

            if ! executable(lsp)
                let executables[lsp] = 0
                continue
            endif

            let executables[lsp] = 1

            call add(filetypes, lang)
            call add(enabled_clients, lsp)
        endif
    endfor

    let filetypes = uniq(sort(filetypes))
    let enabled_clients = uniq(sort(enabled_clients))

    call SpaceVim#logger#info('enabled lsp langs:   ' . string(filetypes))
    call SpaceVim#logger#info('enabled lsp clients: ' . string(enabled_clients))

    call SpaceVim#layers#lsp#set_variable({
                \ 'filetypes' : filetypes,
                \ 'enabled_clients' : enabled_clients,
                \ })
endfunction " }}}

function! s:setup_conemu() " {{{
    if &term=='win32' && !empty($ConEmuANSI)
        " echom "Running in conemu"
        " Should ``chcp 65001`` in console
        set termencoding=utf8
        set term=xterm
        set t_Co=256
        let &t_AB="\e[48;5;%dm"
        let &t_AF="\e[38;5;%dm"
        let g:spacevim_enable_guicolors=0
        let g:spacevim_colorscheme_default = "gruvbox"
    endif
endfunction
" }}}

function! s:setup_mapping() " {{{
    nnoremap zJ zjzx
    nnoremap zK zkzx

    " use '%/' in cmdline to get current file path.  e.g. :e %/
    cmap %/ <C-R>=escape(expand("%:p:h")."/", ' \')<CR>

    "" vim-mark <Leader>m {{{
    let g:_spacevim_mappings.m = {'name' : '+vim-mark'}
    call SpaceVim#mapping#def('nmap <silent>', '<Leader>mm', '<Plug>MarkSet', 'Mark current word', 'MarkSet')
    call SpaceVim#mapping#def('xmap <silent>', '<Leader>mm', '<Plug>MarkSet', 'Mark selected word', 'MarkSet')
    call SpaceVim#mapping#def('nmap <silent>', '<Leader>mr', '<Plug>MarkRegex', 'Mark using regex', 'MarkRegex')
    call SpaceVim#mapping#def('xmap <silent>', '<Leader>mr', '<Plug>MarkRegex', 'Mark selection as regex','MarkRegex')
    call SpaceVim#mapping#def('nmap <silent>', '<Leader>mc', '<Plug>MarkClear', 'Clear current mark','MarkClear')
    call SpaceVim#mapping#def('nmap <silent>', '<Leader>mM', '<Plug>MarkToggle', 'Toggle marks', 'MarkToggle')
    call SpaceVim#mapping#def('nmap <silent>', '<Leader>mC', '<Plug>MarkConfirmAllClear', 'Clear ALL marks','MarkAllClear')

    " nmap <silent><unique> <Leader>mn <Plug>MarkSearchCurrentNext
    " nmap <silent><unique> <Leader>mp <Plug>MarkSearchCurrentPrev
    " nmap <silent><unique> <Leader>mN <Plug>MarkSearchAnyNext
    " nmap <silent><unique> <Leader>mP <Plug>MarkSearchAnyPrev
    " nmap <silent><unique> <Plug>IgnoreMarkSearchNext <Plug>MarkSearchNext
    " nmap <silent><unique> <Plug>IgnoreMarkSearchPrev <Plug>MarkSearchPrev

    " highlight MarkWord1 ctermbg=DarkCyan    ctermfg=Black guibg=#8CCBEA guifg=Black |
    " highlight MarkWord2 ctermbg=DarkMagenta ctermfg=Black guibg=#FF7272 guifg=Black |
    " highlight MarkWord3 ctermbg=DarkYellow  ctermfg=Black guibg=#FFDB72 guifg=Black |
    " highlight MarkWord4 ctermbg=DarkGreen   ctermfg=Black guibg=#FFB3FF guifg=Black |
    " highlight MarkWord5 ctermbg=DarkRed     ctermfg=Black guibg=#9999FF guifg=Black |
    " highlight MarkWord6 ctermbg=DarkBlue    ctermfg=Black guibg=#A4E57E guifg=Black
    "" }}}
endfunction
" }}}

function! s:setup_plugin() " {{{
    "" xml syntax {{{
    let g:xml_syntax_folding = 1
    augroup myspacevim_xml
        autocmd! BufNewFile,BufEnter *.xml
                    \  setlocal foldmethod=syntax
    augroup END
    "" }}}

    "" dein.vim {{{
    " Do a shallow clone
    let g:dein#types#git#clone_depth = 1
    "" }}}

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

    "" incsearch {{{
    let g:incsearch#auto_nohlsearch = 0
    "" }}}

    "" ultisnips {{{
    let g:UltiSnipsNoPythonWarning = 1
    let g:ultisnips_python_quoting_style = "single"
    let g:ultisnips_python_triple_quoting_style = "double"
    let g:ultisnips_python_style = "google"
    "" }}}

    "" vim-pydocstring {{{
    let g:pydocstring_templates_dir = '~/.SpaceVim.d/templates/pydocstring/google'
    "" }}}

    "" Tagbar {{{
    let g:tagbar_autofocus = 1
    "" }}}

    "" Startify {{{
    let g:startify_custom_header = ['   Welcome to SpaceVim!']
    "" }}}

    "" Unite {{{
    if exists('*unite#custom#source')
        call unite#custom#source(
                    \ 'file_rec,file_rec/async,grep',
                    \ 'ignore_pattern',
                    \ join([
                    \ '\%(^\|/\)\.$',
                    \ '\~$',
                    \ '\.\%(o\|a\|exe\|dll\|bak\|DS_Store\|zwc\|pyc\|sw[po]\|class\|gcno\|gcda\|gcov\)$',
                    \ '\%(^\|/\)gcc-[0-9]\+\%(\.[0-9]\+\)*/',
                    \ '\%(^\|/\)doc/html/',
                    \ '\%(^\|/\)stage/',
                    \ '\%(^\|/\)boost\%(\|_\w\+\)/',
                    \ '\%(^\|/\)\%(\.hg\|\.git\|\.bzr\|\.svn\|tags\%(-.*\)\?\)\%($\|/\)',
                    \ ], '\|'))
    endif
    "" }}}

    "" vim-asciidoc-folding {{{
    let g:asciidoc_fold_style = 'nested'
    let g:asciidoc_fold_override_foldtext = 1
    "" }}}

    "" vim-markdown {{{
    "let g:markdown_default_mappings = 1
    let g:vim_markdown_auto_insert_bullets = 0
    "let g:markdown_hi_error = 1
    "" }}}

    "" vim-markdown-folding {{{
    let g:markdown_fold_style = 'nested'
    let g:markdown_fold_override_foldtext = 1
    "" }}}

    "" vim-markdown-toc {{{
    let g:vmt_auto_update_on_save = 0
    let g:vmt_dont_insert_fence = 0
    let g:vmt_cycle_list_item_markers = 1
    "" }}}

    "" vim-bracketed-paste {{{
    let g:bracketed_paste_tmux_wrap = 0
    "" }}}

    "" CodeReviewer.vim {{{
    call SpaceVim#mapping#def('nmap <silent>', '<Leader>i', '<Plug>AddComment', 'Insert code review comment', 'AddComment')

    if $USER != ""
        let g:CodeReviewer_reviewer = $USER
    elseif $USERNAME != ""
        let g:CodeReviewer_reviewer = $USERNAME
    else
        let g:CodeReviewer_reviewer = "Unknown"
    endif

    let g:CodeReviewer_reviewFile="review.rev"
    "" }}}

    "" NERD_commenter.vim {{{
    if SpaceVim#layers#isLoaded('lang#c')
        call SpaceVim#custom#SPC('nmap', ['c', 'c'], '<Plug>NERDCommenterToggle', 'comment or uncomment lines(aligned)', 0)
    endif
    "" }}}

    "" coc.nvim {{{
    if exists('*coc#config')
        call coc#config('coc.preferences', {
                    \ "autoTrigger": "always",
                    \ "maxCompleteItemCount": 10,
                    \ "codeLens.enable": 1,
                    \ "diagnostic.virtualText": 1,
                    \})

        let s:coc_extensions = [
                    \ 'coc-dictionary',
                    \ 'coc-json',
                    \ 'coc-ultisnips',
                    \ 'coc-tag',
                    \]

        for extension in s:coc_extensions
            call coc#add_extension(extension)
        endfor
    endif
    "" }}}

    "" colorizer {{{
    let g:colorizer_maxlines = 1000     " Disable plugin on large file
    "" }}}

    "" indentLine {{{
    let g:indentLine_setColors = 0
    let g:indentLine_fileTypeExclude = get(g:, 'indentLine_fileTypeExclude', [])
    call add(g:indentLine_fileTypeExclude, 'sml')
    "" }}}
endfunction
" }}}

function! s:setup_autocmd() " {{{
    augroup myspacevim_jam
        autocmd!
        autocmd! FileType jam
                    \  nnoremap <buffer> [SPC]lb :make<CR>
                    \| nnoremap <buffer> [SPC]lt :make unittest<CR>
    augroup END

    augroup myspacevim_cpp
        autocmd!
        autocmd! FileType c,cpp
                    \  setlocal foldmethod=syntax
                    \| setlocal foldlevel=99
    augroup END

    augroup myspacevim_asciidoc
        autocmd!
        autocmd! FileType asciidoc
                    \  :set foldlevel=0
    augroup END

    augroup myspacevim_markdown
        autocmd!
        autocmd! FileType markdown
                    \  :set foldlevel=1 shiftwidth=2
                    \| :command! -buffer -range=% ReBullet silent! %s/^\(  \(    \)*\)\* /\1- / <bar> silent! %s/^\(\(    \)*\)\- /\1* /
    augroup END

    augroup myspacevim_scss
        autocmd!
        autocmd! FileType scss
                    \  :set shiftwidth=2
    augroup END

    augroup myspacevim_haskell
        autocmd!
        autocmd! FileType haskell
                    \  :set shiftwidth=2 expandtab
    augroup END

    " surround
    augroup myspacevim_surround_markdown
        autocmd!
        autocmd! FileType markdown :let b:surround_96 = "``\r``"
    augroup END

    " Goyo, Distraction-free writing in Vim
    augroup myspacevim_goyo
        autocmd!
        autocmd! User GoyoEnter nested call <SID>goyo_enter()
        autocmd! User GoyoLeave nested call <SID>goyo_leave()
    augroup END

    augroup myspacevim_yaml
        autocmd!
        autocmd! BufNewFile,BufEnter *.ksy
                    \ :setlocal filetype=yaml
        autocmd! FileType yaml :setlocal shiftwidth=2 expandtab
    augroup END

    augroup myspacevim_private
        autocmd!
        autocmd! BufNewFile,BufEnter */private/*
                    \ :setlocal noswapfile noundofile nobackup writebackup backupdir=.
    augroup END
endfunction
" }}}

function! s:setup_plugin_after() " {{{
    if exists('*editorconfig#AddNewHook')
        call editorconfig#AddNewHook(function('myspacevim#IncludePathHook'))
    endif

    "" unite {{{
    if exists('*unite#filters#matcher_default#use')
        call unite#filters#matcher_default#use(['matcher_context'])
    endif

    if exists('*unite#custom#profile')
        call unite#custom#profile('default', 'context', {
                    \   'direction': 'botright',
                    \ })
    endif
    ""}}}

    "" denite {{{
    if exists('*denite#custom#source')
        call denite#custom#source('_', 'matchers', ['matcher/regexp'])
        call denite#custom#source('_', 'sorters', ['sorter/sublime'])
    endif

    if exists('*denite#custom#option')
        call denite#custom#option('default', {
                    \ 'direction' : 'botright',
                    \ })
    endif
    ""}}}

    "" deoplete.vim {{{
    if exists('*deoplete#custom#option')
        call deoplete#custom#option("auto_complete_delay", 150)
    endif
    "" }}}

    "" vim-markdown {{{
    if SpaceVim#layers#isLoaded("lang#latex")
        augroup myspacevim_mkdtex
            autocmd!
            autocmd! FileType markdown
                        \  syntax include @tex syntax/tex.vim
                        \| syntax region mkdMath start="\\\@<!\$" end="\$" skip="\\\$" contains=@tex keepend
                        \| syntax region mkdMath start="\\\@<!\$\$" end="\$\$" skip="\\\$" contains=@tex keepend
                        \| echomsg "tex syntax loaded"
        augroup END
    endif
    "" }}}

    "" vim-startify {{{
    if exists('g:startify_skiplist')
        call add(g:startify_skiplist, '/private/')
    endif
    "" }}}

    "" vim-fswitch {{{
    " 可以用:A在.h/.cpp间切换

    for l:lang in ['c', 'cpp', 'xml', 'rnc', 'haskell']
        call SpaceVim#custom#LangSPCGroupName(l:lang, ['j'], '+Jump/Switch')
        call SpaceVim#custom#LangSPC(l:lang, 'nmap', ['j', 'a'], 'FSHere', 'switch and load it into current window', 1)
        call SpaceVim#custom#LangSPC(l:lang, 'nmap', ['j', 'A'], 'FSSplitRight', 'switch and load it into a new window split on the right', 1)
        call SpaceVim#custom#LangSPC(l:lang, 'nmap', ['j', 'l'], 'FSRight', 'switch and load it into the window on the right', 1)
        call SpaceVim#custom#LangSPC(l:lang, 'nmap', ['j', 'L'], 'FSSplitRight', 'switch and load it into a new window split on the right', 1)
        call SpaceVim#custom#LangSPC(l:lang, 'nmap', ['j', 'h'], 'FSLeft', 'switch and load it into the window on the left', 1)
        call SpaceVim#custom#LangSPC(l:lang, 'nmap', ['j', 'H'], 'FSSplitLeft', 'switch and load it into a new window split on the left', 1)
        call SpaceVim#custom#LangSPC(l:lang, 'nmap', ['j', 'k'], 'FSAbove', 'switch and load it into the window above', 1)
        call SpaceVim#custom#LangSPC(l:lang, 'nmap', ['j', 'K'], 'FSSplitAbove', 'switch and load it into a new window split above', 1)
        call SpaceVim#custom#LangSPC(l:lang, 'nmap', ['j', 'j'], 'FSBelow', 'switch and load it into the window above', 1)
        call SpaceVim#custom#LangSPC(l:lang, 'nmap', ['j', 'J'], 'FSSplitBelow', 'switch and load it into a new window split above', 1)
    endfor

    augroup myspacevim_fswitch
        autocmd!

        " reg:的匹配部分使用的是:p:h的结果，是没有最后/的目录
        autocmd! BufNewFile,BufEnter *.h,*.hpp
                    \  let b:fswitchdst='cpp,c,ipp,cxx'
                    \| let b:fswitchlocs=
                    \      'reg:!/include\>!/src!,' .
                    \      'reg:!/include/.*!/src!,' .
                    \      'ifrel:!/include\>!../src!,' .
                    \      'reg:!/include/\w\+\>!/src!,' .
                    \      'reg:!/include\(/\w\+\)\{2}\>!/src!,' .
                    \      'reg:!/include\(/\w\+\)\{3}\>!/src!,' .
                    \      'reg:!/include\(/\w\+\)\{4}\>!/src!,' .
                    \      'reg:!/include/.*!/src/**!,' .
                    \      'reg:!^\(.*/\|\)sscc\(/[^/]\+\|\)!\1libs\2/src/**!' .
                    \      'reg:!/impl_include\>!/src/impl!,' .
                    \      'reg:!/impl_include/.*!/src/impl!,' .
                    \      'ifrel:!/impl_include\>!../src/impl!,' .
                    \      'reg:!/impl_include/\w\+\>!/src/impl!,' .
                    \      'reg:!/impl_include\(/\w\+\)\{2}\>!/src/impl!,' .
                    \      'reg:!/impl_include\(/\w\+\)\{3}\>!/src/impl!,' .
                    \      'reg:!/impl_include\(/\w\+\)\{4}\>!/src/impl!,' .
                    \      'reg:!/impl_include/.*!/src/impl/**!,'
                    \| let b:fsnonewfiles="on"
        autocmd! BufNewFile,BufEnter *.c,*.cpp,cxx,*.ipp
                    \  let b:fswitchdst='h,hpp'
                    \| let b:fswitchlocs=
                    \      'reg:!/src\>!/include!,' .
                    \      'reg:!/src\(/.*\|\)$!/include/**!,' .
                    \      'ifrel:!/src\>!../include/!,' .
                    \      'reg:!/libs/.*!/**!' .
                    \      'reg:!/src/impl\>!/impl_include!,' .
                    \      'reg:!/src/impl\(/.*\|\)$!/impl_include/**!,' .
                    \      'ifrel:!/src/impl\>!../impl_include/!,'
                    \| let b:fsnonewfiles="on"

        autocmd! BufNewFile,BufEnter *.xml
                    \  let b:fswitchdst='rnc'
                    \| let b:fswitchlocs='./'
        autocmd! BufNewFile,BufEnter *.rnc
                    \  let b:fswitchdst='xml'
                    \| let b:fswitchlocs='./'

        autocmd! BufNewFile,BufEnter */src/*.hs
                    \  let b:fswitchdst='hs'
                    \| let b:fswitchlocs='reg:!/src/!/test/!'
                    \| let b:fswitchfnames='/$/Spec/'
        autocmd! BufNewFile,BufEnter */test/*Spec.hs
                    \  let b:fswitchdst='hs'
                    \| let b:fswitchlocs='reg:!/test/!/src/!'
                    \| let b:fswitchfnames='/Spec$//'

        autocmd! FileType c,cpp,xml,rnc,haskell
        command! -buffer A :call FSwitch('%', '')
    augroup END
    "" }}}

    "" Neomake {{{
    let g:neomake_open_list = 0     " 0: don't auto open

    if ! exists('g:neomake_vim_enabled_makers')
        let g:neomake_vim_enabled_makers = []
    endif
    if executable('vimlint')
        call add(g:neomake_vim_enabled_makers, 'vimlint')
    endif
    if executable('vint')
        call add(g:neomake_vim_enabled_makers, 'vint')
    endif

    " 优先使用clang-tidy
    if executable('clang-tidy')
        let g:neomake_c_enabled_makers = 'clangtidy'
        let g:neomake_cpp_enabled_makers = 'clangtidy'
    endif

    let g:neomake_markdown_markdownlint_errorformat =
                \ '%f:%l:%c %m,' .
                \ '%f: %l: %c: %m,' .
                \ '%f:%l %m,' .
                \ '%f: %l: %m'
    "" }}}

    "" Telescope {{{
    if SpaceVim#layers#isLoaded("telescope")
        call SpaceVim#mapping#def('nmap <silent>', '<Leader>fs', ':<C-U>Telescope lsp_dynamic_workspace_symbols<CR>', 'Telescope dynamic symbols', 'Find symbols')

        for l:lang in ['c', 'cpp']
            if SpaceVim#layers#isLoaded('lang#c')
                call SpaceVim#mapping#gd#add(l:lang, function('s:gotodef'))
                call SpaceVim#custom#LangSPC(l:lang, 'nmap', ['x'], ':Telescope lsp_references', 'show-reference', 1)
                call SpaceVim#custom#LangSPC(l:lang, 'nmap', ['i'], ':Telescope lsp_implementations', 'implementation', 1)
            endif
        endfor
    endif
    "" }}}

    "" build/test mapping for c and cpp {{{
    if SpaceVim#layers#isLoaded('lang#c')
        for l:lang in ['c', 'cpp', 'bbv2']
            call SpaceVim#custom#LangSPC(l:lang, 'nmap', ['b'], 'make', 'build project', 1)
            call SpaceVim#custom#LangSPC(l:lang, 'nmap', ['B'], 'Make', 'async build project', 1)
            call SpaceVim#custom#LangSPC(l:lang, 'nmap', ['t'], 'make unittest', 'run unittest', 1)
            call SpaceVim#custom#LangSPC(l:lang, 'nmap', ['T'], 'Make unittest', 'async run unittest', 1)
        endfor
    endif
    "" }}}

endfunction
" }}}

function! s:gotodef() abort
    if SpaceVim#layers#isLoaded("telescope")
        exec 'Telescope lsp_definitions'
    endif
endfunction

function! s:build_make(program, args) abort " {{{
    if a:program =~# '\$\*'
        return substitute(a:program, '\$\*', a:args, 'g')
    elseif empty(a:args)
        return a:program
    else
        return a:program . ' ' . a:args
    endif
endfunction
" }}}

function! s:async_make(args) " {{{
    let cmd1 = s:build_make(&makeprg, a:args)
    let cmd2 = join(map(split(cmd1, '\ze[<%# "'']'), 'expand(v:val)'), '')
    call SpaceVim#plugins#runner#open(cmd2)
endfunction
" }}}

" command SyntaxId {{{
function! s:syntax_id()
    let s = []
    for id in synstack(line("."), col("."))
        call add(s, synIDattr(id, "name"))
    endfor
    echo join(s, ' -> ')
endfunction

command! SyntaxId call s:syntax_id()
" }}}

