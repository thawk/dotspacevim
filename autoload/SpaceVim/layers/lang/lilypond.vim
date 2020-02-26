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
    autocmd! BufNewFile,BufRead *.ly
                \ setlocal errorformat+=%f:%l:%c:\ %m,%f:%l:\ %m,In\ file\ included\ from\ %f:%l:,\^I\^Ifrom\ %f:%l%m |
                \ setlocal errorformat+=%DChanging\ working\ directory\ to:\ `%f' |
                \ setlocal errorformat+=%XConverting\ to |
                \ call SpaceVim#plugins#tasks#reg_provider(funcref('s:detect_tasks'))
  augroup END
endfunction

function! s:detect_tasks() abort
    let tasks = {
                \ "Compile" : {
                \   "command" : "lilypond '${relativeFile}'",
                \   "isDetected" : 1,
                \   "detectedName" : "lilypond: ",
                \ }}

    return tasks
endfunction
