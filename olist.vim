" ============================================================================
" Ordered List Manager (Independent Sets)
" ============================================================================

" ----------------------------------------------------------------------------
" ListAppend(list, value)
" Appends a value to the end of the specified list. 
" ----------------------------------------------------------------------------
function! ListAppend(list, value) abort
    call add(a:list, a:value)
endfunction

" ----------------------------------------------------------------------------
" ListInsert(list, index, value)
" Inserts a value at the specified index in the list.
" ----------------------------------------------------------------------------
function! ListInsert(list, index, value) abort
    call insert(a:list, a:value, a:index)
endfunction

" ----------------------------------------------------------------------------
" ListGet(list, index, [default])
" Retrieves a value by its index from the specified list.
" ----------------------------------------------------------------------------
function! ListGet(list, index, ...) abort
    let l:default = a:0 > 0 ? a:1 : v:null
    return get(a:list, a:index, l:default)
endfunction

" ----------------------------------------------------------------------------
" ListChange(list, index, value)
" Updates an existing value at the specified index.
" ----------------------------------------------------------------------------
function! ListChange(list, index, value) abort
    if a:index >= 0 && a:index < len(a:list)
        let a:list[a:index] = a:value
        return 1
    else
        echoerr "ListChange: Index '" . a:index . "' is out of bounds."
        return 0
    endif
endfunction

" ----------------------------------------------------------------------------
" ListDelete(list, index)
" Removes a value at the specified index.
" ----------------------------------------------------------------------------
function! ListDelete(list, index) abort
    if a:index >= 0 && a:index < len(a:list)
        return remove(a:list, a:index)
    else
        echoerr "ListDelete: Index '" . a:index . "' is out of bounds."
        return 0
    endif
endfunction

" ----------------------------------------------------------------------------
" ListSave(list, filepath)
" Serializes the specified list to JSON and writes it to disk.
" ----------------------------------------------------------------------------
function! ListSave(list, filepath) abort
    try
        let l:json = json_encode(a:list)
        call writefile([l:json], a:filepath)
        return 1
    catch
        echoerr "ListSave: Failed to write to " . a:filepath
        return 0
    endtry
endfunction

" ----------------------------------------------------------------------------
" ListLoad(list, filepath)
" Reads JSON from the specified file path and populates the given list.
" ----------------------------------------------------------------------------
function! ListLoad(list, filepath) abort
    if !filereadable(a:filepath)
        echoerr "ListLoad: File not readable at " . a:filepath
        return 0
    endif

    try
        let l:lines = readfile(a:filepath)
        if !empty(l:lines)
            let l:decoded = json_decode(l:lines[0])
            if type(l:decoded) == v:t_list
                " Clear the existing list and populate it with the decoded data
                call filter(a:list, '0')
                call extend(a:list, l:decoded)
                return 1
            else
                echoerr "ListLoad: JSON root is not a list."
                return 0
            endif
        endif
    catch
        echoerr "ListLoad: Failed to parse JSON from " . a:filepath
        return 0
    endtry
endfunction

" ----------------------------------------------------------------------------
" ListClear(list)
" Empties an existing list in place.
" ----------------------------------------------------------------------------
function! ListClear(list) abort
    call filter(a:list, '0')
endfunction

" ----------------------------------------------------------------------------
" ListIterateTemplate(list)
" Iterates across all items in the specified list.
" ----------------------------------------------------------------------------
function! ListIterateTemplate(list) abort
    let l:index = 0
    for l:value in a:list
        " Replace the line below with your custom logic
        echo "Index: " . l:index . " | Value: " . string(l:value)
        let l:index += 1
    endfor
endfunction

" ----------------------------------------------------------------------------
" ListDump(list)
" Optional Utility: Returns a copy of the specified list for inspection.
" ----------------------------------------------------------------------------
function! ListDump(list) abort
    return deepcopy(a:list)
endfunction

" ============================================================================
" USAGE EXAMPLES
" ============================================================================
" let my_tasks = []
" let my_history = []
"
" call ListAppend(my_tasks, 'Write code')
" call ListAppend(my_tasks, 'Review PR')
" call ListInsert(my_history, 0, 'Initial commit')
"
" echo ListGet(my_tasks, 0)
" echo ListDump(my_tasks)
" ============================================================================
" 1. Initialize and populate the list using the defined ListAppend function
" let my_fruits = []
" call ListAppend(my_fruits, 'Apple')
" call ListAppend(my_fruits, 'Banana')
" call ListAppend(my_fruits, 'Cherry')

" 2. Example A: Iterating directly in your script using a standard for loop
" let l:index = 0
" for l:fruit in my_fruits
"     echo "Item " . l:index . " is " . l:fruit
"     let l:index += 1
" endfor

" 3. Example B: Customizing the ListIterateTemplate for a specific task
" function! ProcessFruitList(list) abort
"     let l:index = 0
"     for l:fruit in a:list
"         Custom logic applied to each item (e.g., converting to uppercase)
"         let l:upper_fruit = toupper(l:fruit)
"         echo "Processed [" . l:index . "]: " . l:upper_fruit
"         let l:index += 1
"     endfor
" endfunction

" Execute the custom iteration function
" call ProcessFruitList(my_fruits)
