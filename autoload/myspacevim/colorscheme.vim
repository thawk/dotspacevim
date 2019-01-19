function! myspacevim#colorscheme#autoload()
    if s:handle_dynamic_colors()
        return
    endif
endfunction

function s:handle_dynamic_colors()
    let dynamic_colors_root = $DYNAMIC_COLORS_ROOT

    if dynamic_colors_root == ''
        return 0
    endif

    if !isdirectory(dynamic_colors_root)
        return 0
    endif

    let colorscheme_file = dynamic_colors_root . '/colorscheme'
    if !filereadable(colorscheme_file)
        return 0
    endif

    let dc_colorscheme = readfile(colorscheme_file, '', 1)[0]

    let m = matchlist(dc_colorscheme, '^\([^-]\+\)\([-_]\([^-]\+\)\(-.*\)\?\)\?$')
    if len(m) == 0
        return 0
    endif
    let name = m[1]
    let bg = m[3]

    let colorscheme = g:spacevim_colorscheme

    if name != ''
        if colorscheme == ''
            " If has same colorscheme with dynamic colors, use it
            let g:spacevim_colorscheme = name
            let colorscheme = g:spacevim_colorscheme
            if bg != ''
                let g:spacevim_colorscheme_bg = bg
            endif
        endif

        if name == 'solarized' && colorscheme == 'NeoSolarized'
            if g:spacevim_colorscheme_bg != bg
                let g:spacevim_colorscheme_bg=bg
            endif
        endif
    endif

    return 1
endfunction
