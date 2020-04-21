#!/usr/bin/env bash
# Time: 2020-04-21 09:47:27

sed -E -i "${HOME}/.SpaceVim.d/init.toml" \
    -e 's#^(\s*enable_guicolors\s*=\s*)\w+#\1false#' \
    -e 's#^(\s*statusline_separator\s*=\s*)"\w+"#\1"nil"#' \
    -e 's#^(\s*statusline_inactive_separator\s*=\s*)"\w+"#\1"nil"#' \
    -e 's#^(\s*enable_tabline_ft_icon\s*=\s*)\w+#\1false#' \
    -e 's#^(\s*enable_os_fileformat_icon\s*=\s*)\w+#\1false#' \
    -e 's#^(\s*statusline_unicode_symbols\s*=\s*)\w+#\10#' \
    -e 's#^(\s*buffer_index_type\s*=\s*)\w+#\14#' \
    -e 's#^(\s*window_index_type\s*=\s*)\w+#\14#'
