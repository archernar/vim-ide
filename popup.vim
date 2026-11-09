" ============================================================================
" Popup Message Function
" ============================================================================
" Displays a message in a centered popup window.
" The popup will disappear when the user presses ANY key, OR when an optional
" timeout expires (whichever happens first).
"
" Requires Vim 8.1.1364 or newer (Vim 8.2+ recommended).
" ============================================================================

" ----------------------------------------------------------------------------
" ShowPopupMessage(msg, [timeout_ms])
" 
" Args:
"   msg: String or List of strings to display.
"   [timeout_ms]: Optional. Time in milliseconds before auto-closing.
"                 If omitted, the popup stays until a key is pressed.
" ----------------------------------------------------------------------------
function! ShowPopupMessage(msg, ...) abort
    " Ensure the user's Vim version supports the popup API
    if !exists('*popup_create')
        echoerr "Your version of Vim does not support popups."
        return
    endif

    " Define the base popup options
    let l:options = {
        \ 'pos': 'center',
        \ 'padding': [1, 3, 1, 3],
        \ 'border': [],
        \ 'filter': function('s:AnyKeyFilter'),
        \ 'highlight': 'Normal'
        \ }

    " If a second argument is provided, use it as the timeout (in milliseconds)
    if a:0 > 0
        let l:options['time'] = a:1
    endif

    " Create the popup
    call popup_create(a:msg, l:options)
endfunction

" ----------------------------------------------------------------------------
" s:AnyKeyFilter(winid, key)
" This script-local function intercepts keystrokes while the popup is open.
" ----------------------------------------------------------------------------
function! s:AnyKeyFilter(winid, key) abort
    " Ignore background Vim events that aren't actual human keypresses.
    " This prevents the popup from accidentally closing on a <CursorHold> timeout.
    if a:key ==# "\<CursorHold>" || a:key ==# "\<CursorMoved>" || a:key ==# "\<Ignore>" || a:key ==# "\<MouseMove>"
        return 0 " Let Vim handle the event natively
    endif

    " For any actual keypress, close the specific popup window
    call popup_close(a:winid)
    
    " Return 1 to "consume" the keystroke so it doesn't type into the buffer
    return 1
endfunction


" ============================================================================
" USAGE EXAMPLES
" ============================================================================
" To test these out, uncomment the lines below and source this file (:source %),
" or run them manually in the Vim command prompt.
"
" " 1. Basic usage: Stays on screen forever until the user presses a key
" call ShowPopupMessage("Fatal Error: Please read this and press any key.")
"
" " 2. With timeout: Disappears after 3 seconds (3000ms), or immediately 
" "    if a key is pressed before the time is up.
" call ShowPopupMessage("Save Successful!", 3000)
"
" " 3. Multi-line message: Pass a List of strings
" call ShowPopupMessage(["Line 1: Build failed", "Line 2: Check the logs"], 5000)
" ============================================================================


" ----------------------------------------------------------------------------
" ShowPopupDict(dict, [timeout_ms])
"
" Args:
"   dict: A Dictionary of key-value pairs to display.
"   [timeout_ms]: Optional. Time in milliseconds before auto-closing.
" ----------------------------------------------------------------------------
function! g:ShowPopupDict(dict, ...) abort
    " Convert the dictionary into a List of formatted strings
    let l:lines = []

    " Find the maximum key length for neat alignment (optional, but clean)
    let l:max_len = 0
    for l:key in keys(a:dict)
        if len(l:key) > l:max_len
            let l:max_len = len(l:key)
        endif
    endfor

    " Format each key-value pair with padding
    for l:key in sort(keys(a:dict))
        let l:val = string(a:dict[l:key])
        " Format as "Key : Value" with aligned spacing
        let l:formatted = printf('%-*s : %s', l:max_len, l:key, l:val)
        call add(l:lines, l:formatted)
    endfor

    " Handle optional timeout argument
    if a:0 > 0
        call ShowPopupMessage(l:lines, a:1)
    else
        call ShowPopupMessage(l:lines)
    endif
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

