unlet! skip_defaults_vim
source $VIMRUNTIME/defaults.vim

" ----- options -----

" hacker mode
set background=dark

" spaces > tabs
set tabstop=4 shiftwidth=4 expandtab

" disable unwanted features
set mouse= nowrap noswapfile viminfo=

" always show file name
set laststatus=2 statusline=\ %f\ ---\ %l/%L\ %h%r%m%=%c\  

" complete only from current buffer
set complete=.

" keep undo history on unload
set hidden

" universal brief error format
set errorformat=%A%f:%l:\ %m,%-G%.%#

" use autocmd to reset formatoptions after ftplugins
autocmd BufEnter * setlocal formatoptions=

" disable parenthese highlighting
let loaded_matchparen = 1

" make MySQL the default SQL dialect
let g:sql_type_default='mysql'

" quick save
nmap <Space> :w<CR>

" avoid escape key
imap jj <Esc>

" open parent directory
nmap - :edit %:h/<CR>


" netrw

let g:netrw_banner=0
let g:netrw_list_hide='\(^\|\s\s\)\zs\.\S\+'

" fix marked file highlighting
autocmd FileType netrw hi netrwMarkFile ctermbg=1

com! B let g:netrw_sizestyle=( g:netrw_sizestyle == 'H' ? 'b' : 'H' )<CR><C-L>


" list reordering

fun! GetItemBounds(line, csel)
    let cmax = len(a:line) - 1

    let cleft = a:csel
    while cleft > 0 && index([',', '(', '[', '{'], a:line[cleft-1]) == -1
        let cleft -= 1
    endwhile
    while a:line[cleft] == ' '
        let cleft += 1
    endwhile

    let cright = a:csel
    while cright < cmax && index([',', ')', ']', '}'], a:line[cright+1]) == -1
        let cright += 1
    endwhile
    while a:line[cright] == ' '
        let cright -= 1
    endwhile

    return [cleft, cright]
endfun

fun! ShiftItem(left)
    let line = getline('.')
    let csrc = col('.')

    if a:left
        let [c3, c4] = GetItemBounds(line, csrc)
        let [c1, c2] = GetItemBounds(line, c3 - 3)
    else
        let [c1, c2] = GetItemBounds(line, csrc)
        let [c3, c4] = GetItemBounds(line, c2 + 3)
    endif

    let pre = line[:c1-1]
    let left = line[c1:c2]
    let sep = ', '
    let right = line[c3:c4]
    let post = line[c4+1:]

    call setline('.', pre . right . sep . left . post)
    if a:left
        let cdst = len(pre) + 1
    else
        let cdst = len(pre) + len(right) + len(sep) + 1
    endif
    call cursor(line('.'), cdst)
endfun

nmap L :call ShiftItem(0)<CR>
nmap H :call ShiftItem(1)<CR>


" shell integrations

com! -bar ST new | setl bt=nofile bh=wipe nobl
com! -bar VT vert new | setl bt=nofile bh=wipe nobl

let g:dt_dir = $HOME.'/dotfiles'
let g:dt_gitrc = g:dt_dir.'/git-env/.bashrc'
let g:dt_bufnr = 0

let stat = 'echo `date` `pwd`'
let sep = 'echo ==='
let g:dt_scrpt = [stat, sep, '', sep, stat]

fun! Script(name, lines)
    let opts = {'term_name': a:name}

    let winids = win_findbuf(g:dt_bufnr)
    if len(winids)
        call win_gotoid(winids[0])
        let opts['curwin'] = 1
    else
        let opts['vertical'] = 1
    endif

    let scrpt = substitute(join(a:lines, '; '), '"', '\"', 'g')
    echo scrpt

    let g:dt_bufnr = term_start(['bash', '-c', scrpt], opts)
endfun

com! O so ~/.vimrc
com! U exec '!cd ' . g:dt_dir . '; git pull --ff-only' | so ~/.vimrc
com! L call term_start('bash --rcfile '. g:dt_gitrc, {'term_finish': 'close'})
com! P call term_start('python', {'term_finish': 'close'})

com! -nargs=1 -complete=file R let g:dt_scrpt[2] = <q-args> | call Script(<q-args>, g:dt_scrpt)
com! RR call Script(g:dt_scrpt[2], g:dt_scrpt)

com! D let fn = expand('%:.') | let ft = &ft | VT | exec 'silent read !git show "HEAD:./' . fn . '"' | let &ft = ft

com! -nargs=1 DB let g:dt_db = '--login-path=<args>'
com! -nargs=1 -complete=file Q ST | exec 'silent read !mysql ' . g:dt_db . ' -vv -e "<args>"' | 0 | setl ts=20
" TODO: substitute(query, '"', '\"', 'g')
com! -range=% QQ exec 'Q ' . join(getline(<line1>,<line2>), ' ')
com! QB Q SHOW DATABASES
com! QT Q SHOW TABLES
com! -nargs=1 QS Q DESCRIBE <args>
com! -nargs=1 QA Q SELECT * FROM <args>
com! -nargs=1 QC Q SELECT COUNT(*) FROM <args>

fun! PylintCallback(job, status)
    lfile
    echo 'pylint finished'
    exec '!rm ' . &errorfile
endfun

com! PL call job_start('pylint --output-format=parseable -sn ' . expand('%'), {'out_io': 'file', 'out_name': &errorfile, 'exit_cb': 'PylintCallback'})


" leader mappings

nmap <Leader>' :lnext<CR>
nmap <Leader>; :lprev<CR>

nmap <Leader>] :setlocal tabstop+=4<CR>
nmap <Leader>[ :setlocal wrap!<CR>:setlocal wrap?<CR>
nmap <Leader>p :setlocal paste!<CR>:setlocal paste?<CR>
