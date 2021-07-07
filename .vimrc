" useful vim configs
" mappings:
nnoremap <F10> :mksession! \| :confirm q<CR>
inoremap <F10> <ESC>:mksession! \| :confirm q<CR>
" Alt-Shift-←/→: move tab
nmap <M-S-Right> :tabm +1<CR>
nmap <M-S-Left> :tabm -1<CR>

" Copy " register to real clipboard 
function Osc52Copy
  "execute "silent !echo -e '".system('yank',@")."'"
  exec '!echo '.shellescape(system('yank',@"))
endfunc
