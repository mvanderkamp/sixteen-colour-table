let s:bufname = '__SixteenColourTable__'

""
" Go to or open (in a vertical split) a window containing the sixteen-colour
" table.
""
function! sixteen_colour_table#window() abort
    let bufid = bufnr(s:bufname)
    let winid = bufwinnr(bufid)

    if bufid == -1
        " Create new buffer
        execute 'vsplit ' .. s:bufname
    elseif winid == -1
        " Reopen existing buffer
        execute 'vsplit +buffer' . bufid
    else
        " Go to open window
        execute winid . 'wincmd w'
    endif
endfunction

""
" Draw a table showing all possible combinations of the basic 16 terminal
" colours. Columns show consistent background colours and rows show consistent
" foreground colours. The light background columns are shown below their
" respective dark background columns.
""
function! sixteen_colour_table#write_table() abort
    let l:dark_lines = []
    let l:bright_lines = []
    for l:fg in range(16)
        let l:line = []
        for l:bg in range(16)
            " Use match instead of keyword so that the spaces will also be
            " matched
            let l:name = s:text(l:fg, l:bg)
            execute 'syntax match ' .. l:name .. ' /' .. l:name .. '/'
            call s:highlight_cell(l:fg, l:bg)
            call add(l:line, l:name)
            if l:bg == 7
                call add(l:dark_lines, join(l:line, ''))
                let l:line = []
            endif
        endfor
        call add(l:bright_lines, join(l:line, ''))
    endfor

    let lines = extendnew(l:dark_lines, l:bright_lines)
    call add(lines, '')
    call add(lines, 'b :: toggle bold')
    call append(0, lines)
    call s:set_buffer_options()
endfunction

""
" fg: int, foreground colour number
" bg: int, background colour number
" return: string, text to show, can also be used as highlight group name
""
function! s:text(fg, bg) abort
    return printf(' f%02db%02d ', a:fg, a:bg)
endfunction

""
" Pretty self-explanatory. Sets buffer options.
""
function! s:set_buffer_options() abort
    let &l:buftype = 'nofile'
    let &l:bufhidden = 'hide'
    let &l:buflisted = v:true
    let &l:readonly = v:true
    let &l:cursorcolumn = v:false
    let &l:cursorline = v:false
    let &l:list = v:false
    let &l:modifiable = v:false
    let &l:modified = v:false
    let &l:spell = v:false
    let &l:swapfile = v:false

    nmap <silent> <buffer> b :call <SID>toggle_bold()<CR>

    " Colorschemes often call `highlight clear';
    " register a handler to deal with this
    augroup SixteenColourTableBuffer
        autocmd! * <buffer>
        autocmd ColorScheme <buffer> call s:highlight_table()
    augroup END
endfunction

""
" Bold text can make colours look different against some backgrounds,
" this function toggles the highlight grounds between bold/normal.
""
function! s:toggle_bold() abort
    let l:currently_bold = synIDattr(synIDtrans(hlID('f00b00')), 'bold')
    let l:bold = l:currently_bold ? 'NONE' : 'bold'
    let l:cterm = ' cterm=' .. l:bold

    for l:fg in range(16)
        for l:bg in range(16)
            let l:name = s:text(l:fg, l:bg)
            execute 'highlight ' .. l:name .. ' ' .. l:cterm
        endfor
    endfor
endfunction

""
" Set highlight groups for the table
""
function! s:highlight_table() abort
    for l:fg in range(16)
        for l:bg in range(16)
            call s:highlight_cell(l:fg, l:bg)
        endfor
    endfor
endfunction

""
" Set highlight groups for a cell
""
function! s:highlight_cell(fg, bg) abort
    let l:name = s:text(a:fg, a:bg)
    let l:hl_cmd = 'highlight '
                \ .. l:name
                \ .. ' cterm=NONE'
                \ .. ' ctermfg=' .. a:fg
                \ .. ' ctermbg=' .. a:bg
    call execute(l:hl_cmd)
endfunction
