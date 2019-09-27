" We want to keep comments within a column limit, but not code.
" These two options give us that
setlocal formatoptions+=c   " Auto-wrap comments using textwidth
setlocal formatoptions+=r   " Automatically insert the current comment leader after hitting
                            " <Enter> in Insert mode.
setlocal formatoptions+=q   " Allow formatting of comments with "gq".
setlocal formatoptions-=t   " Do no auto-wrap text using textwidth (does not apply to comments)

" This makes doxygen comments work the same as regular comments
setlocal comments-=://
setlocal comments+=:///,://

" indentation
setlocal cinoptions=
setlocal cinoptions+=^      " no specific indent for function
setlocal cinoptions+=:0     " case label indent
setlocal cinoptions+=l1     " align with a case label
setlocal cinoptions+=g0     " c++ scope declaration not indent
setlocal cinoptions+=ps     " K&R-style parameter declaration indent
setlocal cinoptions+=t0     " function return type declaration indent
setlocal cinoptions+=i2     " C++ base class declarations and constructor initializations
setlocal cinoptions+=+s     " continuation line indent
setlocal cinoptions+=c3     " comment line indent
setlocal cinoptions+=(0     " align to first non-white character after the unclosed parentheses
setlocal cinoptions+=us     " same as (N, but for one level deeper
setlocal cinoptions+=U0     " do not ignore the indenting specified by ( or u in case that the unclosed parentheses is the first non-white charactoer in its line
setlocal cinoptions+=w1
setlocal cinoptions+=Ws     " indent line ended with open parentheses

" Highlight strings inside C comments
let c_comment_strings=1

inoremap  <buffer>  /**<CR>     /**<CR><CR>/<Esc>kA<Space>@brief<Space>
inoremap  <buffer>  /**<        /**<<Space>@brief<Space><Space>*/<Left><Left><Left>
vnoremap  <buffer>  /**<        /**<<Space>@brief<Space><Space>*/<Left><Left><Left>
inoremap  <buffer>  ///<        ///<<Space>
vnoremap  <buffer>  ///<        ///<<Space>
inoremap  <buffer>  /**<Space>  /**<Space>@brief<Space><Space>*/<Left><Left><Left>
vnoremap  <buffer>  /**<Space>  /**<Space>@brief<Space><Space>*/<Left><Left><Left>

setlocal keywordprg=man\ -S2:3

