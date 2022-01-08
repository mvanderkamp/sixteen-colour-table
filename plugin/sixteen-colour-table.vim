" sixteen-colour-table.vim
" License: MIT

" Based on http://github.com/guns/xterm-color-table.vim
" Inspired by `xfce4-terminal --color-table`

" We have a dependency on buffer-local autocommands
if v:version < 700
    echo 'FAIL: SixteenColourTable requires vim 7.0+'
    finish
endif

command! SixteenColourTable call sixteen_colour_table#window()

augroup SixteenColourTable
    autocmd!
    autocmd BufNewFile  __SixteenColourTable__ call sixteen_colour_table#write_table()
    autocmd ColorScheme * silent! doautoall SixteenColourTableBuffer ColorScheme
augroup END
