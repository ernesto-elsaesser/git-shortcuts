unlet! skip_defaults_vim
source $VIMRUNTIME/defaults.vim

" --- options ---

" spaces over tabs
set tabstop=4 shiftwidth=4 expandtab

" disable unwanted features
set mouse= nowrap noswapfile viminfo=

" always show status line
set laststatus=2

" complete only from current buffer, no popup menu
set complete=. completeopt=

" keep undo history on unload
set hidden

" universal error format [FILE:LINE: ERR_MSG]
set errorformat=%A%f:%l:\ %m,%-G%.%#


" --- variables ---

" disable parenthese highlighting
let loaded_matchparen = 1

" hide netrw banner
let g:netrw_banner = 0

" make MySQL the default SQL dialect
let g:sql_type_default = 'mysql'

" disable stupid SQL <C-C> mapping
let g:omni_sql_no_default_maps = 1


" --- mappings ---

imap jj <Esc>
nmap <Space> :w<CR>
nmap <CR> :setl wrap!<CR>

cmap w!! w !sudo tee > /dev/null %

set pastetoggle=<C-Y>

nmap <C-E> :cn<CR>


" --- autocmds ---

augroup vimrc
    autocmd!

    " disable comment continuation after ftplugins
    autocmd BufEnter * setlocal formatoptions-=o formatoptions-=r

    " toggle netrw size style
    autocmd FileType netrw nmap <buffer> s :let g:netrw_sizestyle='H'<CR><C-L>
    autocmd FileType netrw nmap <buffer> x :let g:netrw_sizestyle='b'<CR><C-L>

    " fix netrw highlighting (red background)
    autocmd FileType netrw hi netrwMarkFile ctermbg=1
augroup END


" --- temporary buffers ---

com! -bar B new | setl bt=nofile bh=wipe nobl
com! -bar BB vert new | setl bt=nofile bh=wipe nobl


" --- script execution ---

fun! Script(name, lines)
    let scrpt = substitute(join(a:lines, '; '), '"', '\"', 'g')
    let cmd = ['bash', '-c', scrpt]

    for info in getwininfo()
        if get(info['variables'], 'script')
            call win_gotoid(info['winid'])
            call term_start(cmd, {'term_name': a:name, 'curwin': 1})
            return
        endif
    endfor

    call term_start(cmd, {'term_name': a:name, 'vertical': 1})
    let w:script = 1
endfun

let s:sl = 'echo "###" `date` `pwd` "###"'

" run a script with info header/footer
com! -nargs=1 -complete=file R let w:sc = [s:sl, <q-args>, s:sl] | call Script(<q-args>, w:sc)

" rerun last script
com! RR call Script(w:sc[1], w:sc)


" --- git ---

if has('macunix')
    let g:git_env = {'ZDOTDIR': $HOME . '/dotfiles/git-env', 'SHELL_SESSIONS_DISABLE': 1}
    let g:git_cmd = 'zsh'
else
    let g:git_env = {}
    let g:git_cmd = 'bash --rcfile ~/dotfiles/git-env/.bashrc'
endif

" open git shell
com! L call term_start(g:git_cmd, {'env': g:git_env, 'term_finish': 'close'})

" show HEAD version of current file (diff)
com! H let t = [expand('%:.'), line('.'), &ft] | BB | exec 'silent read !git show "HEAD:./' . t[0] . '"' | exec t[1] | let &ft = t[2]


" --- MySQL ---

" set login path and optionally database (e.g. :DB main databaseta)
com! -nargs=1 D let g:sql_cmd = 'mysql --login-path=<args> -e "$QRY" | column -t -s $''\t'''

" set login path and optionally database (verbose output, no tabulation)
com! -nargs=1 DD let g:sql_cmd = 'mysql --login-path=<args> -vv -e "$QRY"'

" paste the results of the specified SQL query into the current buffer
com! -nargs=1 Q let $QRY = <q-args> | ST | exec 'silent 0read !' . g:sql_cmd | 0

" execute the last yanked SQL query
com! QQ exec 'Q ' . substitute(@", '"', "'", 'g')

cnoremap SW SHOW 
cnoremap DA DATABASES
cnoremap TA TABLES
cnoremap VA VARIABLES
cnoremap ST GLOBAL STATUS
cnoremap PR FULL PROCESSLIST
cnoremap CL FULL COLUMNS FROM 

cnoremap SE SELECT 
cnoremap SA SELECT * FROM 
cnoremap SC SELECT COUNT(*) FROM 
cnoremap LI LIMIT 50


" -- misc --

" reload config
com! O so ~/.vimrc

" update config
com! U exec '!cd "$HOME/dotfiles"; git pull --ff-only' | O

" set tab width
com! -nargs=1 T set tabstop=<args>

" Python REPL
com! P ter ++close python

" swap list items
vmap a :s/\%V\([^,]\+\)\(.*\), \([^,]\+\%V.\)/\3\2, \1/<CR>
" test: (aaaaa, bbbb, ccc, ddddddd)

" open web page in text-based browser
com! -nargs=1 W ter ++close lynx -accept_all_cookies <args>
