" ============================================================================
" Ordered List Manager (Independent Sets - Enhanced)
" ============================================================================

function! ListAppend(list, value) abort
    call add(a:list, a:value)
    return 1
endfunction

function! ListInsert(list, index, value) abort
    if a:index >= 0 && a:index <= len(a:list)
        call insert(a:list, a:value, a:index)
        return 1
    else
        echoerr "ListInsert: Index '" . a:index . "' is out of bounds."
        return 0
    endif
endfunction

function! ListGet(list, index, ...) abort
    let l:default = a:0 > 0 ? a:1 : v:null
    return get(a:list, a:index, l:default)
endfunction

function! ListChange(list, index, value) abort
    if a:index >= 0 && a:index < len(a:list)
        let a:list[a:index] = a:value
        return 1
    else
        echoerr "ListChange: Index '" . a:index . "' is out of bounds."
        return 0
    endif
endfunction

function! ListDelete(list, index) abort
    if a:index >= 0 && a:index < len(a:list)
        return remove(a:list, a:index)
    else
        echoerr "ListDelete: Index '" . a:index . "' is out of bounds."
        return v:null
    endif
endfunction

function! ListSave(list, filepath) abort
    let l:path = expand(a:filepath)
    let l:dir = fnamemodify(l:path, ':h')
    
    " Automatically create parent directories if they don't exist
    if !isdirectory(l:dir)
        call mkdir(l:dir, 'p')
    endif

    try
        let l:json = json_encode(a:list)
        call writefile([l:json], l:path)
        return 1
    catch
        echoerr "ListSave: Failed to write to " . a:filepath
        return 0
    endtry
endfunction

function! ListLoad(list, filepath) abort
    let l:path = expand(a:filepath)
    if !filereadable(l:path)
        echoerr "ListLoad: File not readable at " . a:filepath
        return 0
    endif

    try
        let l:lines = readfile(l:path)
        if !empty(l:lines)
            let l:decoded = json_decode(l:lines[0])
            if type(l:decoded) == v:t_list
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

function! ListClear(list) abort
    call filter(a:list, '0')
endfunction

function! ListDump(list) abort
    return deepcopy(a:list)
endfunction`;
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

" ==============================================================================
" Vimscript Data Structures: Lists ([]) vs. Dictionaries ({})
" ==============================================================================
"
" Quick Comparison:
" ------------------------------------------------------------------------------
" Feature           | List ([])                        | Dictionary ({})
" ------------------------------------------------------------------------------
" Data Structure    | Ordered sequence (integer index) | Key-value pairs (string keys)
" Access Method     | Numeric index starting at 0      | String key (dict['key'] or dict.key)
" Data Types        | Mixed types allowed              | Mixed values; keys are strings
" Common Uses       | Sequences, lines, arguments      | Configurations, caching, mapping
" ------------------------------------------------------------------------------
"
" 1. LISTS ([])
" - An ordered collection where items are accessed by their numerical position.
" - Zero-indexed (0 is the first item, -1 is the last item).
" - Example usage:
"   let my_list = ['apple', 'banana', 'cherry']
"   echo my_list[0]        " Output: apple
"   echo my_list[-1]       " Output: cherry
"   call add(my_list, 'date')
"   let my_list = my_list + ['elderberry']
"
" 2. DICTIONARIES ({})
" - An unordered collection of key-value pairs.
" - Keys are always strings (numeric keys are automatically cast to strings).
" - Accessed via bracket notation (dict['key']) or dot notation (dict.key).
" - Example usage:
"   let my_dict = {'name': 'vim', 'version': 9.0, 'enabled': v:true}
"   echo my_dict['name']   " Output: vim
"   echo my_dict.version   " Output: 9.0
"   let my_dict['author'] = 'Bram Moolenaar'
"   let my_dict.version = 9.1
"
"   " Iterating through a dictionary:
"   for [key, value] in items(my_dict)
"     echo key . ': ' . value
"   endfor
" ==============================================================================
" ==============================================================================
" Advanced Vimscript Functions for Lists and Dictionaries
" ==============================================================================
"
" 1. map() - Modify elements in-place
" - Iterates through each element, evaluating an expression where 'v:val' 
"   represents the current value (and 'v:key' the index or key).
" - Example (Double every number in a list):
"   let numbers = [1, 2, 3, 4]
"   call map(numbers, 'v:val * 2')
"   " numbers is now [2, 4, 6, 8]
"
" 2. filter() - Keep or remove elements based on a condition
" - Evaluates an expression; if it evaluates to 0 (false), the item is removed.
" - Example (Keep only even numbers in a list):
"   let nums = [1, 2, 3, 4, 5, 6]
"   call filter(nums, 'v:val % 2 == 0')
"   " nums is now [2, 4, 6]
"
" 3. extend() - Combine collections
" - Appends items from one list/dictionary into another.
" - Example (Combining lists):
"   let list_a = [1, 2]
"   let list_b = [3, 4]
"   call extend(list_a, list_b)
"   " list_a is now [1, 2, 3, 4]
"
" 4. keys() and values() - Extract dictionary parts
" - Returns a list of a dictionary's keys or values.
" - Example:
"   let settings = {'theme': 'dark', 'tabstop': 4}
"   echo keys(settings)     " Output: ['theme', 'tabstop']
"   echo values(settings)   " Output: ['dark', 4]
"
" 5. sort() and reverse() - Order collections
" - Example:
"   let unsorted = ['banana', 'apple', 'cherry']
"   call sort(unsorted)
"   " unsorted is now ['apple', 'banana', 'cherry']
"   call reverse(unsorted)
"   " unsorted is now ['cherry', 'banana', 'apple']
" ==============================================================================


