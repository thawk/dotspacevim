"=============================================================================
" lilypond.vim --- lilypond layer for SpaceVim
" Copyright (c) 2019 thawk
" Author: thawk
" URL: https://spacevim.org
" License: GPLv3
"=============================================================================
function! SpaceVim#layers#lang#lilypond#plugins() abort
  let plugins = []
  " call add(plugins, ['gisraptor/vim-lilypond-integrator', {'merged' : 0}])
  call add(plugins, ['wchargin/vim-lilypond', {'merged' : 0}])
  return plugins
endfunction

function! SpaceVim#layers#lang#lilypond#config() abort
  augroup spacevim_lang_lilypond
    autocmd FileType lilypond 
                \ compiler lilypond |
                \ setlocal errorformat+=%DChanging\ working\ directory\ to:\ `%f'
                \          errorformat+=%XConverting\ to
  augroup END

  call SpaceVim#mapping#space#regesit_lang_mappings('lilypond', function('s:mappings'))
endfunction

function! s:mappings() abort
  if !exists('g:_spacevim_mappings_space')
    let g:_spacevim_mappings_space = {}
  endif
  let g:_spacevim_mappings_space.l = {'name' : '+Language Specified'}
  if exists(':Make')
      call SpaceVim#mapping#space#langSPC('nmap', ['l','c'], 'Make "%"', 'compile curent file', 1)
      call SpaceVim#mapping#space#langSPC('nmap', ['l','b'], 'Make', 'build the project', 1)
  else
      call SpaceVim#mapping#space#langSPC('nmap', ['l','c'], 'make "%"', 'compile curent file', 1)
      call SpaceVim#mapping#space#langSPC('nmap', ['l','b'], 'make', 'build the project', 1)
  endif
endfunction

