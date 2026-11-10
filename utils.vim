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
        call ShowPopupMessage("[" . a:1 ."]", 2000)
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
"
function! g:GetBufferFunctionList()
    let lines = getline(1, '$')
    let funcs = {}
    
    " Match function definitions: function foo, function! s:bar, def baz
    let def_pattern = '^\s*\(function!\?\|def\)\s\+\([a-zA-Z0-9#_:]\+\)'
    
    for i in range(len(lines))
        let match_res = matchlist(lines[i], def_pattern)
        if !empty(match_res)
            let func_name = match_res[2]
            let funcs[func_name] = {
                \ 'line': i + 1,
                \ 'count': 0
            }
        endif
    endfor

    " Handle empty buffers gracefully so popup_create doesn't crash
    if empty(funcs)
        return {'Status': 'No functions found in this buffer'}
    endif

    " Count total references across all lines for each function using boundary matching
    for name in keys(funcs)
        let total_count = 0
        let escaped_name = escape(name, '\^$.*[\~')
        let pattern = '\v(^|[^a-zA-Z0-9#_:])@<=' . escaped_name . '([^a-zA-Z0-9#_:]|$)@='
        
        for line in lines
            let idx = 0
            while 1
                let idx = match(line, pattern, idx)
                if idx == -1
                    break
                endif
                let total_count += 1
                let idx += max([1, strlen(name)])
            endwhile
        endfor
        let funcs[name].count = total_count
    endfor

    " Convert nested metadata into clean formatted strings for ShowPopupDict
    let popup_dict = {}
    for [name, info] in items(funcs)
        let popup_dict[name] = printf("Line %d (Refs: %d)", info.line, info.count)
    endfor

    return popup_dict
endfunction

" ----------------------------------------------------------------------------
" RunBashCommandAndShow(cmd, [timeout_ms])
"
" Runs a shell command explicitly inside 'bash', captures stdout/stderr,
" and puts each line of output into its own sequential entry in the dictionary
" so they display line-by-line in the popup.
"
" Args:
"   cmd:          The bash command line to run (String).
"   [timeout_ms]: Optional popup timeout in milliseconds.
"
" Example Usage:
"   " 1. Run a command and wait for a keypress to dismiss
"   call RunBashCommandAndShow('ls -la | head -n 5')
"
"   " 2. Run a command and auto-close the popup after 4 seconds (4000ms)
"   call RunBashCommandAndShow('uname -a', 4000)
"
"   " 3. Test failure capture
"   call RunBashCommandAndShow('cat /nonexistent/file', 5000)
" ----------------------------------------------------------------------------
function! RunBashCommandAndShow(cmd, ...) abort
    " Prepare bash execution with combined stdout and stderr
    " Using 'bash -c' ensures bash-specific syntax runs properly regardless of &shell
    let l:full_cmd = 'bash -c ' . shellescape(a:cmd)

    " Execute command and capture raw output
    let l:raw_output = system(l:full_cmd)
    let l:exit_code  = v:shell_error

    " Build the initial dictionary with command and status
    let l:res = {
        \ '1_cmd' : a:cmd,
        \ '2_sta'  : l:exit_code == 0 ? 'Success (0)' : printf('Failed (%d)', l:exit_code),
        \ }

    " Parse stdout into lines and add each line individually to the dictionary
    if empty(l:raw_output)
        let l:res['3_out_1'] = '<no output>'
    else
        " Split by newline, preserving the original line order
        let l:lines = split(l:raw_output, '\r\n\|\n')
        
        " Give each line its own sequential key so they stay ordered correctly
        let l:idx = 1
        for l:line in l:lines
            let l:key = printf('3_out_%02d', l:idx)
            let l:res[l:key] = l:line
            let l:idx += 1
        endfor
    endif

    " Forward dictionary and any optional arguments (such as timeout_ms) to g:ShowPopupDict
    if a:0 >  0
        call g:ShowPopupDict(l:res, a:1)
    else
        call g:ShowPopupDict(l:res)
    endif

    return l:res
endfunction
function! g:GetBufferFunctionList()
    let lines = getline(1, '$')
    let func_dict = {}

    " Match function definitions: function foo, function! s:bar, def baz
    let def_pattern = '^\s*\(function!\?\|def\)\s\+\([a-zA-Z0-9#_:]\+\)'

    for i in range(len(lines))
        let match_res = matchlist(lines[i], def_pattern)
        if !empty(match_res)
            let func_name = match_res[2]
            " Store the line number as an integer (Number type)
            " so string() outputs it without quotation marks.
            let func_dict[func_name] = i + 1
        endif
    endfor

    " Fallback if no functions are found so popup_create doesn't crash on empty dict
    if empty(func_dict)
        return {'[No Functions Found]': 0}
    endif

    return func_dict
endfunction
function! g:GetUnusedBufferFunctionList()
    let l:lines = getline(1, '$')
    if empty(l:lines)
        return {'[Empty Buffer]': 0}
    endif

    let l:func_lines = {}
    let l:func_counts = {}
    let l:def_pattern = '^\s*\(function!\?\|def\)\s\+\([a-zA-Z0-9#_:]\+\)'

    " Step 1: Find all defined functions and record their line numbers
    for l:i in range(len(l:lines))
        let l:match_res = matchlist(l:lines[l:i], l:def_pattern)
        if !empty(l:match_res)
            let l:func_name = l:match_res[2]
            let l:func_lines[l:func_name] = l:i + 1
            let l:func_counts[l:func_name] = 0
        endif
    endfor

    if empty(l:func_lines)
        return {'[No Functions Found]': 0}
    endif

    " Step 2: Count references across all lines using boundary matching
    for l:name in keys(l:func_lines)
        let l:total_count = 0
        let l:escaped_name = escape(l:name, '\^$.*[\~')
        let l:pattern = '\v(^|[^a-zA-Z0-9#_:])@<=' . l:escaped_name . '([^a-zA-Z0-9#_:]|$)@='

        for l:line in l:lines
            let l:idx = 0
            while 1
                let l:idx = match(l:line, l:pattern, l:idx)
                if l:idx == -1
                    break
                endif
                let l:total_count += 1
                let l:idx += max([1, strlen(l:name)])
            endwhile
        endfor
        let l:func_counts[l:name] = l:total_count
    endfor

    " Step 3: Build a simple flat dictionary (Name -> Line Number) for unused functions only
    let l:unused_dict = {}
    for l:name in keys(l:func_lines)
        " Count <= 1 means it only appears on its own definition line
        if l:func_counts[l:name] <= 1
            let l:unused_dict[l:name] = l:func_lines[l:name]
        endif
    endfor

    if empty(l:unused_dict)
        return {'[All Functions In Use]': 0}
    endif

    return l:unused_dict
endfunction

