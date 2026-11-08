" ============================================================================
" Synchronous Popup Input Script for Vim 8
" ============================================================================
" Prompts the user for string input inside a modal, centered popup dialog box, 
" allows real-time typing, handles Backspace/Delete, and returns the resulting 
" string directly so it can be assigned to a local variable.
"
" Requires Vim 8.1.1364 or newer (Vim 8.2+ recommended)[cite: 1].
" ============================================================================

" ----------------------------------------------------------------------------
" PromptPopupInput(title)
" 
" Args:
"   title: String to display as the title/header of the prompt dialog.
" Returns:
"   String entered by the user, or an empty string '' if cancelled/aborted.
" ----------------------------------------------------------------------------
function! PromptPopupInput(title, deftitle) abort



    " Clear any lingering keypresses (like the <Enter> used to select the menu item)
    while getchar(0) != 0
    endwhile

    " Force screen redraw so the popup renders correctly from a mapping
    redraw!



    " Ensure the user's Vim version supports the popup dialog API
    if !exists('*popup_dialog')
        echoerr "Your version of Vim does not support popup_dialog."
        return ''
    endif

    " Keep track of the input state in a dictionary
    let l:state = {
        \ 'text': '',
        \ 'title': a:title
        \ }

    " Define modal popup options
    let l:options = {
        \ 'title': a:title,
        \ 'pos': 'center',
        \ 'padding': [1, 2, 1, 2],
        \ 'border': [1, 1, 1, 1],
        \ 'filter': function('s:PromptFilter', [l:state]),
        \ 'highlight': 'Normal'
        \ }

    " popup_dialog() blocks execution until popup_close() is called, 
    " and returns the result code passed to it.
    let l:result = popup_dialog(['Comment: ', a:deftitle,'',a:title, '', '> '], l:options)

    " If user pressed Enter (success code 1), return the typed text; otherwise empty string
    if l:result == 1
        return l:state.text
    endif
    
    return ''
endfunction

" ----------------------------------------------------------------------------
" s:PromptFilter(state, winid, key)
" Script-local filter function that intercepts keystrokes to build the input 
" string in real time and handle editing keys like Backspace and Enter.
" ----------------------------------------------------------------------------
function! s:PromptFilter(state, winid, key) abort
    " Submit input on Enter
    if a:key ==# "\<CR>" || a:key ==# "\<Enter>"
        call popup_close(a:winid, 1) " Close with success code (1)
        return 1
    
    " Cancel input on Escape or Ctrl-C
    elseif a:key ==# "\<Esc>" || a:key ==# "\<C-c>"
        call popup_close(a:winid, 0) " Close with cancel code (0)
        return 1
    
    " Handle Backspace / Delete
    elseif a:key ==# "\<BS>" || a:key ==# "\<Del>" || a:key ==# "\<C-h>"
        if len(a:state.text) > 0
            let a:state.text = a:state.text[:-2]
        endif
    
    " Capture printable characters
    elseif a:key >=# ' ' && a:key <=# '~'
        let a:state.text .= a:key
    else
        " Ignore or pass through other keys
        return 0
    endif

    " Update the popup display with the newly typed text
    call popup_settext(a:winid, [a:state.title, 'Type your input and press <Enter>:', '> ' . a:state.text])
    return 1
endfunction


" ============================================================================
" USAGE EXAMPLES & DOCUMENTATION
" ============================================================================
" To test this out, source this file (:source %), then run the example 
" function using `:call CreateNewFeatureBranch()`.
"
" Example Function demonstrating local variable assignment:
"
" function! CreateNewFeatureBranch()
"     " 1. Call the popup and assign the user's string directly to a local variable
"     let l:branch_name = PromptPopupInput("Enter new branch name:")
"
"     " 2. Check if the user entered text (and didn't cancel with Esc)
"     if empty(l:branch_name)
"         echo "Operation cancelled by user."
"         return
"     endif
"
"     " 3. Use the local variable in your workflow logic
"     echo "Creating git branch: " . l:branch_name
"     " e.g., execute 'Git checkout -b ' . l:branch_name
" endfunction
" ============================================================================
