#!/usr/bin/env bash
# Time: 2020-04-21 09:47:27

sed -E -i "${HOME}/.SpaceVim.d/init.toml" \
    -e "s#^(\s*checkinstall\s*=\s*)\w+#\10#"
