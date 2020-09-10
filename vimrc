set background=dark
set ruler
set number
set backspace=indent,eol,start
set scrolloff=3
set complete=.,t
set completeopt=
set noswapfile
set nowrap
set splitright
set splitbelow
syntax on
filetype plugin indent on

let g:netrw_banner=0
let g:netrw_list_hide='^\.[^.].*'
let g:netrw_sizestyle='H'
nmap <space> <cr>

nmap gz de/\w<cr>vep``P

hi MatchParen ctermfg=Green ctermbg=NONE
hi LineNr ctermfg=DarkGray
hi link netrwMarkFile Title

fun! DiffMaster()
	let @d = system("git show master:./".bufname('%'))
	let l:ft = &ft
	set diff scrollbind
	vnew
	autocmd BufDelete <buffer> bufdo set nodiff noscrollbind
	exec "set buftype=nofile filetype=".l:ft
	put! d
	set diff scrollbind 
	diffupdate
endfun

fun! MySQL(login, database)
	exec 'ter ++close mysql --login-path="'.a:login.'" '.a:database
endfun

fun! MySQLExec(login, database, ...)
	let l:sql = join(a:000, ' ')
	exec 'ter mysql --login-path="'.a:login.'" '.a:database.' -e "'.l:sql.'"'
endfun

com! L 15Lexplore
com! U so ~/.vimrc
com! UR ter update-repo.sh
com! -nargs=? R exec "ter ".expand('%:p')." <args>"

com! -nargs=1 G ter ++rows=10 git <args>
com! -nargs=1 GG ter ++close commit-and-push.sh <args>
com! GD call DiffMaster()

com! -nargs=+ P py3 <args>
com! PF py3file %
com! PL compiler pylint | make %

com! -nargs=+ M call MySQL(<f-args>)
com! -nargs=+ ME call MySQLExec(<f-args>)
