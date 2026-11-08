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
