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
" g:ShowPopupDict(num_cols, dict, [timeout_ms])
"
" Args:
"   num_cols: Number of columns to display (e.g., 2, 3, 4).
"   dict: A Dictionary of key-value pairs. Unused functions can be flagged
"         or we can highlight lines matching specific criteria.
"   [timeout_ms]: Optional. Time in milliseconds before auto-closing.
" ----------------------------------------------------------------------------
function! g:XXXXShowPopupDictInCols(num_cols, dict, ...) abort
    let l:keys = sort(keys(a:dict))
    let l:total = len(l:keys)

    if l:total == 0 || a:num_cols < 1
        call ShowPopupMessage(['[Empty Dictionary or Invalid Columns]'], a:0 > 0 ? a:1 : 0)
        return
    endif

    let l:cols = a:num_cols
    let l:rows = (l:total + l:cols - 1) / l:cols

    let l:formatted_items = []
    let l:max_lengths = repeat([0], l:cols)
    let l:unused_keys = []

    for l:i in range(l:total)
        let l:key = l:keys[l:i]
        let l:val = string(a:dict[l:key])
        let l:item = printf('%s : %s', l:key, l:val)

        " Track if this function is 'unused' (e.g., value is 0, false, or marked 'unused')
        " Adjust this condition based on how your script flags unused functions
        if a:dict[l:key] == 0 || a:dict[l:key] =~? 'unused'
            call add(l:unused_keys, l:key)
        endif

        call add(l:formatted_items, l:item)

        let l:c_idx = l:i / l:rows
        let l:item_len = strdisplaywidth(l:item)
        if l:item_len > l:max_lengths[l:c_idx]
            let l:max_lengths[l:c_idx] = l:item_len
        endif
    endfor

    let l:lines = []
    let l:pad = 3

    for l:r in range(l:rows)
        let l:row_str = ''
        let l:c in range(l:cols)
            let l:item_idx = l:c * l:rows + l:r
            if l:item_idx < l:total
                let l:item = l:formatted_items[l:item_idx]
                if l:c < l:cols - 1
                    let l:row_str .= printf('%-*s', l:max_lengths[l:c] + l:pad, l:item)
                else
                    let l:row_str .= l:item
                endif
            endif
        endfor
        call add(l:lines, l:row_str)
    endfor

    " Define standard popup options (default text color is normal/white)
    let l:options = {
        \ 'pos': 'center',
        \ 'padding': [1, 3, 1, 3],
        \ 'border': [],
        \ 'filter': function('s:AnyKeyFilter'),
        \ 'highlight': 'Normal'
        \ }

    if a:0 > 0
        let l:options['time'] = a:1
    endif

    if exists('*popup_create')
        " Create the popup window
        let l:winid = popup_create(l:lines, l:options)

        " Get the buffer number of the popup window to apply syntax matching
        let l:bufnr = winbufnr(l:winid)

        " Define custom highlight for unused items (Red)
        call setbufvar(l:bufnr, '&syntax', 'vimpopup')

        " Highlight lines or specific keys matching unused functions in red (ErrorMsg)
        if !empty(l:unused_keys)
            " Construct a regex pattern matching any of the unused keys
            let l:pat = '\v(' . join(l:unused_keys, '|') . ')\s*:\s*'
            call win_execute(l:winid, 'syntax match PopupUnused /' . l:pat . '/ conceal off')
            call win_execute(l:winid, 'highlight default link PopupUnused ErrorMsg')
        endif
    else
        echo join(l:lines, "\n")
    endfor
endfunction
" ----------------------------------------------------------------------------
" g:ShowPopupDictInCols(num_cols, dict, [timeout_ms])
"
" Args:
"   num_cols: Number of columns to display (e.g., 2, 3, 4).
"   dict: A Dictionary of key-value pairs to display.
"   [timeout_ms]: Optional. Time in milliseconds before auto-closing.
" ----------------------------------------------------------------------------
function! g:ShowPopupDictInCols(num_cols, dict, ...) abort
    let l:keys = sort(keys(a:dict))
    let l:total = len(l:keys)

    if l:total == 0 || a:num_cols < 1
        call ShowPopupMessage(['[Empty Dictionary or Invalid Columns]'], a:0 > 0 ? a:1 : 0)
        return
    endif

    let l:cols = a:num_cols
    " Calculate rows needed based on total items and column count
    let l:rows = (l:total + l:cols - 1) / l:cols

    " Format all key-value pairs first
    let l:formatted_items = []
    let l:max_lengths = repeat([0], l:cols)

    for l:i in range(l:total)
        let l:key = l:keys[l:i]
        let l:val = string(a:dict[l:key])
        let l:item = printf('%s : %s', l:key, l:val)
        call add(l:formatted_items, l:item)

        " Determine which column this item lands in
        let l:c_idx = l:i / l:rows
        let l:item_len = strdisplaywidth(l:item)
        if l:item_len > l:max_lengths[l:c_idx]
            let l:max_lengths[l:c_idx] = l:item_len
        endif
    endfor

    " Build the row lines by distributing items across columns (column-major order)
    let l:lines = []
    let l:pad = 3 " Spacing between columns

    for l:r in range(l:rows)
        let l:row_str = ''
        for l:c in range(l:cols)
            let l:item_idx = l:c * l:rows + l:r
            if l:item_idx < l:total
                let l:item = l:formatted_items[l:item_idx]
                " If it's not the last column, pad it to align with the column width
                if l:c < l:cols - 1
                    let l:row_str .= printf('%-*s', l:max_lengths[l:c] + l:pad, l:item)
                else
                    let l:row_str .= l:item
                endif
            endif
        endfor
        call add(l:lines, l:row_str)
    endfor

    " Handle optional timeout argument (passed as the 3rd argument here)
    if a:0 > 0
        call ShowPopupMessage(l:lines, a:1)
    else
        call ShowPopupMessage(l:lines)
    endif
endfunction
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
" ShowPopupList(list, [timeout_ms])
"
" Args:
"   list: A List of items to display.
"   [timeout_ms]: Optional. Time in milliseconds before auto-closing.
" ----------------------------------------------------------------------------
function! g:ShowPopupList(list, ...) abort
    " Convert the list into a List of formatted strings
    let l:lines = []
    let l:index = 0

    " Format each item with its index
    for l:val in a:list
        let l:str_val = string(l:val)
        let l:formatted = printf('[%d]: %s', l:index, l:str_val)
        call add(l:lines, l:formatted)
        let l:index += 1
    endfor

    " Handle optional timeout argument
    if a:0 > 0
        call ShowPopupMessage(l:lines, a:1)
    else
        call ShowPopupMessage(l:lines)
    endif
endfunction
