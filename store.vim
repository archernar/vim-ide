" ============================================================================
" Name/Value Pair Store (Independent Sets)
" ============================================================================

" ----------------------------------------------------------------------------
" StorePut(store, name, value)
" Adds a name/value pair to the specified store. 
" ----------------------------------------------------------------------------
function! StorePut(store, name, value) abort
    let a:store[a:name] = a:value
endfunction

" ----------------------------------------------------------------------------
" StoreGet(store, name, [default])
" Retrieves a value by its name from the specified store. 
" ----------------------------------------------------------------------------
function! StoreGet(store, name, ...) abort
    let l:default = a:0 > 0 ? a:1 : v:null
    return get(a:store, a:name, l:default)
endfunction

" ----------------------------------------------------------------------------
" StoreChange(store, name, value)
" Updates an existing name/value pair in the specified store.
" ----------------------------------------------------------------------------
function! StoreChange(store, name, value) abort
    if has_key(a:store, a:name)
        let a:store[a:name] = a:value
        return 1
    else
        echoerr "StoreChange: Name '" . a:name . "' does not exist."
        return 0
    endif
endfunction

" ----------------------------------------------------------------------------
" StoreDelete(store, name)
" Removes a name/value pair from the specified store.
" ----------------------------------------------------------------------------
function! StoreDelete(store, name) abort
    if has_key(a:store, a:name)
        return remove(a:store, a:name)
    else
        echoerr "StoreDelete: Name '" . a:name . "' does not exist."
        return 0
    endif
endfunction

" ----------------------------------------------------------------------------
" StoreSave(store, filepath)
" Serializes the specified store to JSON and writes it to disk.
" ----------------------------------------------------------------------------
function! StoreSave(store, filepath) abort
    try
        let l:json = json_encode(a:store)
        call writefile([l:json], a:filepath)
        return 1
    catch
        echoerr "StoreSave: Failed to write to " . a:filepath
        return 0
    endtry
endfunction

" ----------------------------------------------------------------------------
" StoreLoad(store, filepath)
" Reads JSON from the specified file path and populates the given store.
" ----------------------------------------------------------------------------
function! StoreLoad(store, filepath) abort
    if !filereadable(a:filepath)
        echoerr "StoreLoad: File not readable at " . a:filepath
        return 0
    endif

    try
        let l:lines = readfile(a:filepath)
        if !empty(l:lines)
            let l:decoded = json_decode(l:lines[0])
            if type(l:decoded) == v:t_dict
                " Clear the existing dictionary and populate it with the decoded data
                call filter(a:store, '0')
                call extend(a:store, l:decoded)
                return 1
            else
                echoerr "StoreLoad: JSON root is not a dictionary."
                return 0
            endif
        endif
    catch
        echoerr "StoreLoad: Failed to parse JSON from " . a:filepath
        return 0
    endtry
endfunction

" ----------------------------------------------------------------------------
" StoreClear(store)
" Empties an existing store by removing all name/value pairs in place.
" ----------------------------------------------------------------------------
function! StoreClear(store) abort
    call filter(a:store, '0')
endfunction


" ----------------------------------------------------------------------------
" StoreIterateTemplate(store)
" Iterates across all name/value pairs in the specified store.
" ----------------------------------------------------------------------------
function! StoreIterateTemplate(store) abort
    for [l:name, l:value] in items(a:store)
        " Replace the line below with your custom logic
        echo "Name: " . l:name . " | Value: " . string(l:value)
    endfor
endfunction

" ----------------------------------------------------------------------------
" StoreDump(store)
" Optional Utility: Returns a copy of the specified store for inspection.
" ----------------------------------------------------------------------------
function! StoreDump(store) abort
    return deepcopy(a:store)
endfunction


" ============================================================================
" USAGE EXAMPLES
" ============================================================================
" let my_settings = {}
" let my_cache = {}
"
" call StorePut(my_settings, 'theme', 'dark')
" call StorePut(my_cache, 'last_run', '2023-10-05')
"
" echo StoreGet(my_settings, 'theme')
" echo StoreDump(my_cache)
" ============================================================================
