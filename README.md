This is my custom configuratin for [SpaceVim][].  Feel free to clone and modified.

You can put host dependent code into a ``vim`` file: ``~/.spacevim.local``, it will be source at the begin of ``bootstrap_before`` function.

For example, I disable all the programming related plugins in my FreeBSD Jail:

```vim
" vim: filetype=vim fileencoding=utf-8 foldmethod=marker foldlevel=0:

for l in [ 'VersionControl', 'lang#c', 'lang#clojure', 
            \ 'lang#go', 'lang#haskell', 'lang#haskell',
            \ 'lang#java', 'lang#javascript', 'lang#python',
            \ 'lang#lilypond', 'leaderf', 'lsp', 'tags']
    call SpaceVim#layers#disable(l)
endfor
```

## 安装依赖项

* ``lang#markdown``依赖的``remark``

  ```sh
  npm install --global remark-cli remark-html remark-preset-lint-markdown-style-guide
  ```

[SpaceVim]: https://spacevim.org
