" Only do this when not done yet for this buffer
if exists("b:did_c_path_settings")
    finish
endif
let b:did_c_path_settings = 1

let s:cpp_include_path_ready = 0
let s:cpp_include_path = []

function! s:AddComponentsToPath(path)
    let l:path = fnamemodify(a:path, ':p')

    if index(b:proj_processed_components, l:path) >= 0
        return
    endif

    call add(b:proj_processed_components, l:path)

    " 把path目录下，两层子目录内的include等目录加入路径中
    for l:name in ["include"]
        for l:p in finddir(l:name, l:path . "/**2", -1)
            call s:AddPath(l:p)
        endfor
    endfor

    for l:name in ["3rd"]
        for l:p in finddir(l:name, l:path . "/**2", -1)
            call s:AddComponentsToPath(l:p)
        endfor
    endfor

    " 把path目录下，两层子目录内的boost/sscc等目录的上一层目录加入路径中
    for l:name in ["boost", "sscc"]
        for l:p in finddir(l:name, l:path . "/**2", -1)
            call s:AddPath(fnamemodify(l:p, ":h"))
        endfor
    endfor

    " 把path目录下，所有包含头文件的直接子目录include路径中
    for l:p in split(glob(l:path . "/*"), "\n")
        if findfile("*.h", l:p) || findfile("*.hpp", l:p)
            call s:AddPath(l:p)
        endif

        if isdirectory(l:p . "/lib")
            call s:AddComponentsToPath(l:p . "/lib")
        endif
    endfor
endfunction

function! s:AddPath(path)
    let l:p = fnamemodify(a:path, ":p:h")
    if isdirectory(l:p) && index(b:proj_processed_paths, l:p) < 0
        call add(b:proj_processed_paths, l:p)
        exec "setlocal path+=" . l:p
    endif
endfunction

function! s:AddCppDefaultIncludePath()
    if !s:cpp_include_path_ready
        let s:cpp_include_path_ready = 1

        if executable("g++") && executable("sed")
            let l:output = system("echo '' | g++ -E -x c++ - -v |& sed -e '1,/#include <.*search starts here/d' -e '/End of search list/,$d'")
            for l:p in split(l:output)
                call add(s:cpp_include_path, fnamemodify(l:p, ":p"))
            endfor
        endif

        " 未能从编译器取得include列表，自行查找
        let l:cpp_include_path = substitute(substitute(glob("/usr/include/c++/*/"), "^.*\n", "", ""), "/$", "", "")
        if isdirectory(l:cpp_include_path)
            call add(s:cpp_include_path, l:cpp_include_path)

            " 在/usr/include/c++/4.4.6/x86_64-redhat-linux/bits有需要的文件，因此
            " 把/usr/include/c++/4.4.6/x86_64-redhat-linux加入路径中
            for l:p in finddir("bits", l:cpp_include_path . '/**2', -1)
                call add(s:cpp_include_path, fnamemodify(l:p, ":p:h:h"))
            endfor
        endif
    endif

    for l:p in s:cpp_include_path
        call s:AddPath(l:p)
    endfor
endfunction

function! s:SetupEnvironment()
    " 使用当前目录
    "setlocal path=.
    let b:proj_processed_components = []
    let b:proj_processed_paths = []

    let l:path = expand('%:p:h')

    " 找出到workspace下一层的目录。如/home/user/workspace/proj/dir1/dir2 =>
    " /home/usr/workspace/proj
    let l:curr = l:path
    let l:parent = fnamemodify(l:curr, ':h')

    let l:workspace_dir = $HOME
    let l:stop_dir = ''
    while l:parent != l:curr
        " 如果有多个工作区目录，可以加到这个列表中。遇到这些目录中任意一个时，就
        " 不会再往上找了。如所有项目都放到$HOME/workspace/下的话，就设置为
        " workspace。这样，workspace/cs/*就会只查找workspace/cs/及其子目录，不
        " 会找workspace下的其它项目
        if index(['workspace', 'program'], fnamemodify(l:parent, ':t')) >= 0
            " l:parent目录符合要求的目录名
            let l:workspace_dir = l:parent
            " 为路径加上结束的/，这样才能在这层停下来。否则将在workspace_dir才
            " 停，多了一层
            let l:stop_dir = fnamemodify(l:curr, ':p')
            break
        endif

        let l:curr = l:parent
        let l:parent = fnamemodify(l:curr, ':h')
    endwhile

    let l:search_path = l:path . ';' . l:stop_dir

    " 加入路径上所有lib/3rd/util/framework目录下的库
    for l:d in ["lib", "3rd", "framework"]
        for l:p in finddir(l:d, l:search_path, -1)
            call s:AddComponentsToPath(l:p)
        endfor
    endfor

    " 加入路径上所有include目录及有include子目录的目录
    for l:p in finddir("include", l:path . '/**1;', -1)
        call s:AddPath(l:p)
    endfor

    " Boost库
    if match(&path, "boost") < 0    " 路径中没有boost库才需要加入
        if isdirectory($BOOST_ROOT)
            call s:AddPath($BOOST_ROOT)
        else
            let l:boost_dirs = sort(split(glob(l:workspace_dir . "/boost_*/"), "\n"))
            if len(l:boost_dirs) > 0
                call s:AddPath(l:boost_dirs[0])
            endif
        endif
    endif

    " 加入路径上所有Jamroot/Jamfile所在目录，这种目录通常都在include路径中
    for l:name in ["Jamfile", "Jamfile.v2", "Jamfile.jam", "Jamroot", "Jamroot.v2", "Jamroot.jam"]
        for l:p in findfile(l:name, l:search_path, -1)
            call s:AddPath(fnamemodify(l:p, ":p:h"))
        endfor
    endfor

    " 如果在Boost目录，则加上boost目录的上一层目录
    let l:boost_include = finddir("boost", l:search_path)
    if len(l:boost_include) > 0
        " 当前在Boost库的目录下
        call s:AddPath(fnamemodify(l:boost_include, ":p:h:h"))
    endif

    call s:AddPath("/usr/include")
    call s:AddCppDefaultIncludePath()
endfunction

call s:SetupEnvironment()
" vim: filetype=vim fileencoding=utf-8
