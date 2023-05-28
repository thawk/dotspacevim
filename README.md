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

## Offline usage

You can use ``offline.sh`` to disable ``checkupdate`` to be used at an offline environment.

You can use ``nogui.sh`` to be used in an terminal without nerd-font.

## Dependencies

```sh
pip install pynvim neovim
```

* ``lang#markdown`` depends on ``remark``

  ```sh
  npm install --global remark-cli remark-html remark-preset-lint-markdown-style-guide
  ```

* ``lang#c`` depends on

  ```sh
  pip install clang
  ```

* ``lang#python`` depends on

  ```sh
  pip install jedi
  ```

* `lang#javascript` depends on

  ```sh
  npm install -g typescript typescript-language-server
  ```

## Work with pyenv for neovim

* Create the neovim virtualenvs

  * <https://github.com/deoplete-plugins/deoplete-jedi/wiki/Setting-up-Python-for-Neovim>

  * python2

    ```sh
    pyenv install 2.7.15
    pyenv virtualenv 2.7.15 neovim2
    pyenv activate neovim2
    pip install pynvim neovim
    pyenv which python  # Note the path
    ```

  * python3

    ```py
    pyenv install 3.7.3
    pyenv virtualenv 3.7.3 neovim3
    pyenv activate neovim3
    pip install clang jedi neovim pynvim
    pyenv which python  # Note the path
    ```

* Set environment

  * using vim script

    ```py
    let g:python_host_prog = '/full/path/to/neovim2/bin/python'
    let g:python3_host_prog = '/full/path/to/neovim3/bin/python'
    ```py

  * using shell

    ```sh
    export PYTHON_HOST_PROG="$(pyenv root)/neovim2/bin/python"
    export PYTHON3_HOST_PROG="$(pyenv root)/neovim3/bin/python"
F
    ```

[SpaceVim]: https://spacevim.org
