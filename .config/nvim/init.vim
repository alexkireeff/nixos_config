set tabstop=2
set softtabstop=2
set shiftwidth=2
set expandtab
set autoindent
set vb t_vb=
set number
syntax on
set clipboard+=unnamedplus
set background=dark
let skip_defaults_vim=1
set viminfo=
:let @d='Oimport IPython; IPython.embed();'
:let @t='Oimport time; time.sleep(1);'
:command C let @/=''

fun! StripTrailingWhitespace()
    let l:save = winsaveview()
    keeppatterns %s/\s\+$//e
    call winrestview(l:save)
endfun

:command W call StripTrailingWhitespace()
