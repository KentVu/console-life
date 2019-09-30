"source ~/.vim/vundle.vim

map Y y$
map <F2> :w<CR>
imap <F2> <ESC>:w<CR>
"map <F3> :set cursorline!<CR>
map <F10> :confirm q<CR>
" eclipse-like scrolling
nmap <C-Up> <C-y>
nmap <C-Down> <C-e>
" search for currently selected text (visual mode)
"vnoremap // y:exec '/\M'.escape('<C-R>"', '/')<CR>
"nnoremap <Leader>c :let @+=@" \| let @"=@a \| let @a=@b \| let @b=@+ \| reg "ab<CR>
"map <C-\> <Plug>(easymotion-prefix)
nmap s <Plug>(easymotion-s)

if has("vms")
  set nobackup		" do not keep a backup file, use versions instead
else
  set backup		" keep a backup file (restore to previous version)
  set undofile		" keep an undo file (undo changes after closing)
  set backupdir=~/.vimbackup
  set undodir=~/.vimbackup
endif

if has("syntax")
  set foldmethod=syntax
  set foldlevelstart=3
  set foldcolumn=1
  filetype plugin on
  filetype indent on

  " syntaxes
  "let g:is_bash=1
  let g:sh_fold_enabled=3

  let java_highlight_java_lang_ids=1
  "let g:xml_syntax_folding = 1
endif

" In many terminal emulators the mouse works just fine, thus enable it.
if has('mouse')
  set mouse=a
  if !has('nvim')
    set ttymouse=sgr
    "set ttymouse=xterm2
  endif
endif
set pastetoggle=<F4>
set history=2000
set showcmd		" display incomplete commands
"set incsearch		" do incremental searching
set ignorecase nowrapscan smartcase
set ts=4 sw=4
"set sts=4
"set sw=4
" Switch syntax highlighting on, when the terminal has colors
" Also switch on highlighting the last used search pattern.
if &t_Co > 2 || has("gui_running")
  set hlsearch
  "colorscheme murphy
endif
set wildmenu
set wildmode=longest:full,full
"set ruler
set laststatus=2

" autocommands
" Only do this part when compiled with support for autocommands.
if has("autocmd")
  " Set UTF-8 as the default encoding for commit messages
  autocmd BufReadPre COMMIT_EDITMSG,MERGE_MSG,git-rebase-todo setlocal fileencodings=utf-8
  " Uncomment the following to have Vim jump to the last position when
  " reopening a file
  "au BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g'\"" | endif
  "au! BufWinEnter /tmp/bash-fc.*	set nofixendofline ft=sh | let g:is_bash=1
  " Remember the positions in files with some git-specific exceptions"
  autocmd BufReadPost *
  \ if line("'\"") > 0 && line("'\"") <= line("$")
  \           && &filetype !~# 'commit\|gitrebase'
  \           && expand("%") !~ "ADD_EDIT.patch"
  \           && expand("%") !~ "addp-hunk-edit.diff" |
  \   exe "normal g`\"" |
  \ endif

  autocmd BufNewFile,BufRead *.patch set filetype=diff
  autocmd Filetype diff
  \ highlight WhiteSpaceEOL ctermbg=red |
  \ match WhiteSpaceEOL /\(^+.*\)\@<=\s\+$/
endif " has("autocmd")

" Keep undo history across sessions by storing it in a file
" https://stackoverflow.com/a/22676189/1562087
if has('persistent_undo')
    let vimDir='~/.vim'
    let myUndoDir = expand(vimDir . '/undodir')
    " Create dirs
    silent call system('mkdir -pv ' . myUndoDir)
    let &undodir = myUndoDir
    set undofile
endif

"fugitive
"set statusline=%<%f\ %h%m%r%{fugitive#statusline()}%=%-14.(%l,%c%V%)\ %P
"set rulerformat=%<%f\ %h%m%r%{fugitive#statusline()}%=%-14.(%l,%c%V%)\ %P

" javacomplete2
"autocmd FileType java setlocal omnifunc=javacomplete#Complete

" vim-android
"let g:android_sdk_path = $HOME.'/Android/Sdk'

"function! Gl(args)
"    let s:lastdircmd='lcd '.getcwd()
"    lcd ~
"    "exec '!git '.join(a:000)
"    exec '!git '.a:args
"    exec s:lastdircmd
"endfunction
"command! -nargs=* -complete=shellcmd Gl call Gl('<args>')
"command! -nargs=* -complete=shellcmd G !git <args>
"command! GitLog !git log --graph --date-order --date=default -C -M --pretty=format:'\%Cred[\%h]\%Creset [\%ad] \%Cgreen\%d\%Creset \%n          [\%an] \%s' --all

if &term =~ '^screen'
    " tmux will send xterm-style keys when its xterm-keys option is on
    "execute "set <xUp>=\e[1;*A"
    "execute "set <xDown>=\e[1;*B"
    "execute "set <xRight>=\e[1;*C"
    "execute "set <xLeft>=\e[1;*D"
    "set background=dark
elseif &term =~ 'screen\..*' && &term =~ 'xterm'
    " Fix screen
    "set term=xterm-256color
    "exec 'set term='.substitute(&term,'screen\.', '', '')
    "set background=dark
endif
set background=dark
