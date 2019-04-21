"=============================================================================
" lilypond.vim --- lilypond layer for SpaceVim
" Copyright (c) 2019 thawk009
" Author: thawk009
" URL: https://spacevim.org
" License: GPLv3
"=============================================================================
function! SpaceVim#layers#lang#lilypond#plugins() abort
  let plugins = []
  call add(plugins, ['gisraptor/vim-lilypond-integrator', {'merged' : 0}])
  return plugins
endfunction

function! SpaceVim#layers#lang#lilypond#config() abort
  augroup spacevim_lang_lilypond
    autocmd FileType lilypond compiler lilypond
  augroup END

  call SpaceVim#mapping#space#langSPC('nmap', ['l','b'], 'make %', 'compile', 1)
endfunction

