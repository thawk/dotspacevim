function! myspacevim#before() abort
    " Plugin settings {{{

    "" deoplete.vim {{{
    let g:deoplete#auto_complete_delay = 150
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

    "" vim-bracketed-paste {{{
    let g:bracketed_paste_tmux_wrap = 0
    "" }}}

    "" vim-fswitch {{{
    let g:fsnonewfiles=1
    " 可以用:A在.h/.cpp间切换
    augroup myspacevim_fswitch
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
                    \| nnoremap <buffer> [SPC]lja :FSHere
                    \| nnoremap <buffer> [SPC]ljA :FSSplitRight
                    \| nnoremap <buffer> [SPC]ljl :FSRight
                    \| nnoremap <buffer> [SPC]ljL :FSSplitRight
                    \| nnoremap <buffer> [SPC]ljh :FSLeft
                    \| nnoremap <buffer> [SPC]ljH :FSSplitLeft
                    \| nnoremap <buffer> [SPC]ljk :FSAbove
                    \| nnoremap <buffer> [SPC]ljK :FSSplitAbove
                    \| nnoremap <buffer> [SPC]ljj :FSBelow
                    \| nnoremap <buffer> [SPC]ljJ :FSSplitBelow
    augroup END
    "" }}}

    "" CodeReviewer.vim {{{
    call SpaceVim#custom#SPC('nmap', ['i', 'c'], '<Plug>AddComment', 'Insert code review comment', 0)

    if $USER != ""
        let g:CodeReviewer_reviewer = $USER
    elseif $USERNAME != ""
        let g:CodeReviewer_reviewer = $USERNAME
    else
        let g:CodeReviewer_reviewer = "Unknown"
    endif

    let g:CodeReviewer_reviewFile="review.rev"
    "" }}}

    " }}}

    augroup myspacevim_jam
        autocmd!
        autocmd! BufEnter Jamroot,Jamfile,Jamroot.v2,Jamfile.v2,*.jam :set filetype=jam
        autocmd! BufEnter Jamroot,Jamfile,Jamroot.v2,Jamfile.v2 :setlocal makeprg=b2
    augroup END
endfunction

function! myspacevim#after() abort
    set ignorecase
    set smartcase
    set wildmode=longest:full,full
    set wildmenu

    call editorconfig#AddNewHook(function('myspacevim#IncludePathHook'))
endfunction

function! myspacevim#IncludePathHook(config)
    if has_key(a:config, 'c_include_path')
        let p = a:config['c_include_path']
        if type(p) == type("")
            let raw_path = has('win32') ? tr(p, '\', '/') : p
            let paths = split(escape(p, ' '), '[;:]\([\/]\)\@!')
            let &l:path .= ',' . join(paths, ',')
        endif
    endif
endfunction
