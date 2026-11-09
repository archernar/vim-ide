" *****************************************************************************************************
" *****************************************************************************************************
                "  utils.vim - 
                "
                " *************************************************************************************
                "
" ============================================================================
" Unicode Box-Drawing & Graphic Character Variables
" ============================================================================

" Single-Line Box Characters (Light)
let g:BoxHoriz      = '─'
let g:BoxVert       = '│'
let g:BoxTopLeft    = '┌'
let g:BoxTopRight   = '┐'
let g:BoxBotLeft    = '└'
let g:BoxBotRight   = '┘'
let g:BoxTLeft      = '┤'
let g:BoxTRight     = '├'
let g:BoxTDown      = '┬'
let g:BoxTUp        = '┴'
let g:BoxCross      = '┼'

" Double-Line Box Characters
let g:BoxDHoriz     = '═'
let g:BoxDVert      = '║'
let g:BoxDTopLeft   = '╔'
let g:BoxDTopRight  = '╗'
let g:BoxDBotLeft   = '╚'
let g:BoxDBotRight  = '╝'
let g:BoxDTLeft     = '╣'
let g:BoxDTRight    = '╠'
let g:BoxDTDown     = '╦'
let g:BoxDTUp       = '╩'
let g:BoxDCross     = '╬'

" Blocks, Shading, and UI Symbols
let g:BlockFull     = '█'
let g:BlockDark     = '▓'
let g:BlockMedium   = '▒'
let g:BlockLight    = '░'
let g:BlockLeft     = '▌'
let g:BlockRight    = '▐'
let g:BlockBottom   = '▄'
let g:BlockTop      = '▀'

" UI Pointers & Indicators
let g:IconPointer   = '▸'
let g:IconBullet    = '•'
let g:IconCheck     = '✓'
let g:IconCross     = '✗'

function! g:GetVimVersionString() abort
    let l:major = v:version / 100
    let l:minor = v:version % 100
    return printf('%d.%d', l:major, l:minor)
endfunction


function! g:Log(msg)
    " Specify your log file path
    let l:logfile = expand('~/.vim/debug.log')
    " Format message with a timestamp
    let l:entry = strftime('%Y-%m-%d %H:%M:%S') . ': ' . a:msg
    " Append to file (list of lines, file path, append mode)
    call writefile([l:entry], l:logfile, 'a')
endfunction

function! g:SystemCommand(...)
    let l:sz = a:1
    " Run commit and push silently in the background using system()
    let l:output = system(l:sz)
    " Optional: Check if an error occurred (v:shell_error is non-zero on failure)
    if v:shell_error != 0
        call ShowPopupMessage("Error: " . l:output, 5000)
    else
        call ShowPopupMessage("Done", 3000)
    endif
    "execute a:1
endfunction


function! g:ReplaceCurrentLine(new_text)
  call setline('.', a:new_text)
endfunction


function! g:JumpToLineWithStr(search_str)
    let l:last_line = line('$')

    " Loop through every line in the current buffer from top to bottom
    for l:i in range(1, l:last_line)
        " Check if the line contains the search string literally
        if stridx(getline(l:i), a:search_str) != -1
            " Move cursor to the matching line (column 1)
            call cursor(l:i, 1)
            return l:i
        endif
    endfor

    " Echo a message if the string wasn't found in the buffer
    echo "String not found: " . a:search_str
    return 0
endfunction


function! g:StartsWith(prefix, str) abort
    return stridx(a:str, a:prefix) == 0
endfunction


function! g:RemovePrefix(prefix, str) abort
    if stridx(a:str, a:prefix) == 0
        " Slice the string starting from the byte-length of the prefix
        return strpart(a:str, strlen(a:prefix))
    endif
    return a:str
endfunction


function! g:NewWindow(...)
        " for wincmdH is Left  L is Right  K is Top  J is Bottom
        " H is Left  L is Right  K is Top  J is Bottom
        vnew
        let l:sz = tolower(a:1)

        if (l:sz == "left")
             wincmd H
        else
            if (l:sz == "right")
                 wincmd L
            else
                if (l:sz == "top")
                     wincmd K
                else
                    if (l:sz == "bottom")
                         wincmd J
                    endif
                endif
            endif
        endif

        setlocal nobuflisted buftype=nofile bufhidden=wipe noswapfile
        nnoremap <silent> <buffer> q :close<cr>
"       nnoremap <silent> <buffer> = :vertical resize +5<cr>
"       nnoremap <silent> <buffer> - :vertical resize -5<cr>
        nnoremap <silent> <buffer> = :exe "vertical resize +" . winwidth(0)/4<cr>
        nnoremap <silent> <buffer> - :exe "vertical resize -" . winwidth(0)/4<cr>
        call cursor(1, 1)
        execute "vertical resize " . a:2
        if ( a:0 > 2)
            execute "nnoremap <silent> <buffer> " . a:3 . "<cr>"
        endif
        if ( a:0 > 3)
            execute "nnoremap <silent> <buffer> " . a:4 . "<cr>"
        endif
        if ( a:0 > 4)
            execute "nnoremap <silent> <buffer> " . a:5 . "<cr>"
        endif
        if ( a:0 > 5)
            execute "nnoremap <silent> <buffer> " . a:6 . "<cr>"
        endif
        if ( a:0 > 6)
            execute "nnoremap <silent> <buffer> " . a:7 . "<cr>"
        endif
        if ( a:0 > 7)
            execute "nnoremap <silent> <buffer> " . a:8 . "<cr>"
        endif
        if ( a:0 > 8)
            execute "nnoremap <silent> <buffer> " . a:9 . "<cr>"
        endif
        if ( a:0 > 9)
            execute "nnoremap <silent> <buffer> " . a:10 . "<cr>"
        endif
endfunction


function! CloseNormalBuffers()
  " Loop through all possible buffer numbers from 1 to the maximum allocated buffer number
  for l:buf in range(1, bufnr('$'))
    " Check if the buffer exists and is listed in the buffer list
    if buflisted(l:buf)
      " Retrieve the &buftype of the buffer
      let l:buftype = getbufvar(l:buf, '&buftype')

      " If buftype is empty, it's a normal file buffer—close it.
      " (Scratch/special buffers have non-empty buftypes like 'nofile', 'help', etc.)
      if empty(l:buftype)
        try
          execute 'bdelete ' . l:buf
        catch
          " Silently catch errors, such as when a buffer has unsaved changes
        endtry
      endif
    endif
  endfor
endfunction

" Create a convenient user command (:CloseExceptScratch)
" command! CloseExceptScratch call CloseNormalBuffers()
function! CloseNormalBuffersKeepWindows()
  " 1. Create a new scratch buffer to safely house any windows we transition
  enew
  setlocal buftype=nofile bufhidden=hide noswapfile
  let l:scratch_buf = bufnr('%')

  " 2. Switch any window currently showing a normal file buffer over to the scratch buffer
  windo if buflisted(bufnr('%')) && empty(&buftype) | execute 'buffer ' . l:scratch_buf | endif

  " 3. Now delete all listed normal file buffers across Vim
  for l:buf in range(1, bufnr('$'))
    if buflisted(l:buf) && empty(getbufvar(l:buf, '&buftype'))
      try
        execute 'bdelete ' . l:buf
      catch
        " Silently catch errors (e.g., if a buffer has unsaved changes)
      endtry
    endif
  endfor
endfunction

" Create a convenient user command
"command! CloseExceptScratchKeepWindows call CloseNormalBuffersKeepWindows()
function! CloseOtherBuffers()
  " Get the buffer number of the currently active buffer
  let l:current_buf = bufnr('%')

  " Loop through all possible buffer numbers
  for l:buf in range(1, bufnr('$'))
    " Check if the buffer exists, is listed, and is NOT the current buffer
    if buflisted(l:buf) && l:buf != l:current_buf
      try
        execute 'bdelete ' . l:buf
      catch
        " Silently catch errors (e.g., if another buffer has unsaved changes)
      endtry
    endif
  endfor
endfunction

" Create a convenient user command (:CloseOthers)
command! CloseOthers call CloseOtherBuffers()
function! CloseAllBuffersKeepWindow()
  " 1. Collect all currently listed buffer numbers
  let l:bufs_to_delete = []
  for l:i in range(1, bufnr('$'))
    if buflisted(l:i)
      call add(l:bufs_to_delete, l:i)
    endif
  endfor

  " 2. Open a fresh new buffer so the window has a safe home
  enew

  " 3. Delete all the old buffers we collected
  for l:buf in l:bufs_to_delete
    try
      execute 'bdelete ' . l:buf
    catch
      " Silently catch errors (e.g., if a buffer has unsaved changes)
    endtry
  endfor
endfunction

" Create a convenient user command (:CloseAllKeepWindow)
command! CloseAllKeepWindow call CloseAllBuffersKeepWindow()


function! CenterString(text, width, ...) abort
    " Use the provided padding character, or default to a space
    let l:pad_char = a:0 > 0 ? a:1 : ' '
    let l:text_len = strdisplaywidth(a:text)

    if l:text_len >= a:width
        return a:text
    endif

    let l:total_pad = a:width - l:text_len
    let l:left_pad = l:total_pad / 2
    let l:right_pad = l:total_pad - l:left_pad

    return repeat(l:pad_char, l:left_pad) . a:text . repeat(l:pad_char, l:right_pad)
endfunction



" ----------------------------------------------------------------------------
" Close all buffers except any buffer named 'LUCIEN'
" ----------------------------------------------------------------------------
function! g:CloseBuffersExceptLucien() abort
    for l:buf in range(1, bufnr('$'))
        if buflisted(l:buf)
            " Extract just the filename (ignoring directory paths)
            let l:fname = fnamemodify(bufname(l:buf), ':t')

            " Close any buffer whose filename is not 'LUCIEN'
            if l:fname !=# 'LUCIEN'
                silent! execute 'bdelete ' . l:buf
            endif
        endif
    endfor
endfunction

" Command mapping for convenience
"command! CloseExceptLucien call CloseBuffersExceptLucien()
"
"


" ----------------------------------------------------------------------------
" Close any buffer named 'LUCIEN'
" ----------------------------------------------------------------------------
function! g:CloseLucienBuffer() abort
    for l:buf in range(1, bufnr('$'))
        if buflisted(l:buf)
            " Extract just the filename (ignoring directory paths)
            let l:fname = fnamemodify(bufname(l:buf), ':t')

            " Close the buffer if its filename matches 'LUCIEN'
            if l:fname ==# 'LUCIEN'
                silent! execute 'bdelete ' . l:buf
            endif
        endif
    endfor
endfunction

" Command mapping for convenience
" command! CloseLucien call CloseLucienBuffer()
function! g:GetCurrentWindowName() abort
    return getwinvar(0, 'window_name', '')
endfunction

function! g:AnyWindowsExist(...) abort
    " Loop through each target name passed as an argument
    for l:target_name in a:000
        " Check all open windows to see if this target name exists
        for l:i in range(1, winnr('$'))
            if getwinvar(l:i, 'window_name', '') ==# l:target_name
                return 1
            endif
        endfor
    endfor
    " None of the specified window names were found
    return 0
endfunction

function! g:IsCurrentWindow(name) abort
    return getwinvar(0, 'window_name', '') ==# a:name
endfunction

function! g:WindowsExist(...) abort
    " Loop through each window name passed as an argument
    for l:target_name in a:000
        let l:found = 0
        " Check all open windows to see if the current target name exists
        for l:i in range(1, winnr('$'))
            if getwinvar(l:i, 'window_name', '') ==# l:target_name
                let l:found = 1
                break
            endif
        endfor
        " If any name from the arguments is missing, return 0 immediately
        if !l:found
            return 0
        endif
    endfor
    " All specified window names were found
    return 1
endfunction

function! g:WindowExists(name) abort
    for l:i in range(1, winnr('$'))
        if getwinvar(l:i, 'window_name', '') ==# a:name
            return 1
        endif
    endfor
    return 0
endfunction

" 1. Name the current window
"let w:window_name = 'sidebar'

" 2. Helper function to jump to a window by its custom name
function! g:JumpToWindowByName(name)
    for l:i in range(1, winnr('$'))
        if getwinvar(l:i, 'window_name', '') ==# a:name
            execute l:i . 'wincmd w'
            return 1
        endif
    endfor
    echohl WarningMsg | echom "Window not found: " . a:name | echohl None
    return 0
endfunction

" 3. Usage
"call JumpToWindowByName('sidebar')
