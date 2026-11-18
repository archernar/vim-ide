" ============================================================================
" Popup Flashcard Viewer (Strictly Fixed Size & Buffer Export)
" ============================================================================

function! ShowFlashcardFile(filename) abort
    if !filereadable(a:filename)
        echoerr "Flashcard file not readable: " . a:filename
        return
    endif

    let l:lines = readfile(a:filename)
    let l:pages = []
    let l:current_page = []

    " Parse file into pages delimited by lines starting with "FLASHCARD"[cite: 1, 3]
    for l:line in l:lines
        if l:line =~# '^FLASHCARD'
            if !empty(l:current_page)
                call add(l:pages, l:current_page)
                let l:current_page = []
            endif
        endif
        call add(l:current_page, l:line)
    endfor
    if !empty(l:current_page)
        call add(l:pages, l:current_page)
    endif

    if empty(l:pages)
        echoerr "No flashcards found in " . a:filename
        return
    endif

    let l:state = {
        \ 'pages': l:pages,
        \ 'idx': 0,
        \ 'total': len(l:pages)
        \ }

    " Calculate fixed size covering ~85% of available screen space[cite: 3]
    let l:win_width  = float2nr(&columns * 0.85)
    let l:win_height = float2nr(&lines * 0.85)

    " Configure fixed dimensions and lock min/max bounds[cite: 3]
    let l:options = {
        \ 'pos': 'center',
        \ 'padding': [1, 3, 1, 3],
        \ 'border': [1, 1, 1, 1],
        \ 'filter': function('s:FlashcardInteractiveFilter'),
        \ 'width': l:win_width,
        \ 'height': l:win_height,
        \ 'minwidth': l:win_width,
        \ 'maxwidth': l:win_width,
        \ 'minheight': l:win_height,
        \ 'maxheight': l:win_height,
        \ 'scrollbar': 1,
        \ 'title': ' Flashcard 1 / ' . l:state.total . ' ',
        \ 'highlight': 'Normal'
        \ }

    let l:winid = popup_create(l:pages[0], l:options)
    call setwinvar(l:winid, 'fc_state', l:state)
endfunction

" ----------------------------------------------------------------------------
" s:FlashcardInteractiveFilter(winid, key)
" Handles pagination, scrolling, buffer generation, and closing[cite: 3].
" ----------------------------------------------------------------------------
function! s:FlashcardInteractiveFilter(winid, key) abort
    if a:key ==# "\<CursorHold>" || a:key ==# "\<CursorMoved>" || a:key ==# "\<Ignore>" || a:key ==# "\<MouseMove>"
        return 0
    endif

    let l:state = getwinvar(a:winid, 'fc_state', {})
    if empty(l:state)
        call popup_close(a:winid)
        return 1
    endif

    let l:pages = l:state.pages
    let l:idx = l:state.idx
    let l:total = l:state.total

    " Page Forward (Next card): n, Space, f, Ctrl-f, Enter[cite: 3]
    if a:key ==# 'n' || a:key ==# "\<Space>" || a:key ==# 'f' || a:key ==# "\<C-f>" || a:key ==# "\<CR>"
        let l:state.idx = (l:idx + 1) % l:total
        call setwinvar(a:winid, 'fc_state', l:state)
        call popup_settext(a:winid, l:pages[l:state.idx])
        call popup_setoptions(a:winid, {'title': ' Flashcard ' . (l:state.idx + 1) . ' / ' . l:total . ' '})
        return 1

    " Page Backward (Previous card): p, b, Ctrl-b[cite: 3]
    elseif a:key ==# 'p' || a:key ==# 'b' || a:key ==# "\<C-b>"
        let l:state.idx = (l:idx - 1 + l:total) % l:total
        call setwinvar(a:winid, 'fc_state', l:state)
        call popup_settext(a:winid, l:pages[l:state.idx])
        call popup_setoptions(a:winid, {'title': ' Flashcard ' . (l:state.idx + 1) . ' / ' . l:total . ' '})
        return 1

    " Scroll Down within long card: j or Ctrl-e[cite: 3]
    elseif a:key ==# 'j' || a:key ==# "\<C-e>"
        call win_execute(a:winid, "normal! \<C-e>")
        return 1

    " Scroll Up within long card: k or Ctrl-y[cite: 3]
    elseif a:key ==# 'k' || a:key ==# "\<C-y>"
        call win_execute(a:winid, "normal! \<C-y>")
        return 1

    " NEW: Open current flashcard in a new scratch buffer ('e' for edit/export)
    elseif a:key ==# 'e'
        let l:current_card_text = l:pages[l:idx]
        " Close the popup first so we return to normal layout
        call popup_close(a:winid)
        " Open a new scratch buffer and populate it with the card text
        enew
        call setline(1, l:current_card_text)
        setlocal buftype=nofile bufhidden=wipe nobuflisted noswapfile
        execute 'file Flashcard_' . (l:idx + 1)
        redraw
        echo "Opened Flashcard " . (l:idx + 1) . " in a new buffer."
        return 1

    " Quit / Close: q or Esc[cite: 3]
    elseif a:key ==# 'q' || a:key ==# "\<Esc>"
        call popup_close(a:winid)
        return 1
    endif

    return 1
endfunction

