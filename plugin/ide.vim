" *****************************************************************************************************
  "  ide.vim - a Simple Directory Lister/File Opener
  "
  "  For .bashrc
  "  alias ide='vim -c "autocmd VimEnter * call DIRPF()"'
  "  alias vde='vim -c "autocmd VimEnter * call DIRPF()"'
  "  alias vdec='vim -c "autocmd VimEnter * call DIRCPF()"'
  "  
  "  For airline, include in .vimrc   
  "  Disable the airline tabline extension completely (removes buffer/tab list from top)
  "  let g:airline#extensions#tabline#enabled = 0
  "  Ensure Vim's native tabline does not appear at the top either unless multiple tabs are open
  "  set showtabline=1
  " *************************************************************************************
  "
if exists("g:loaded_plugin_dir") || v:version < 700 || &cp
    finish
endif


function! g:SwitcherDir()
    if (g:WindowsExist('menu','client'))
        call g:JumpToWindowByName('menu')
        close
        call s:MyDirPwd(0)
        " Use all lines in the buffer
        let s:max_width = max(map(getline(1, '$'), 'strdisplaywidth(v:val)'))
        execute 'vertical resize ' . (s:max_width + 2)
    elseif (g:WindowsExist('dir','client'))
        call g:JumpToWindowByName('dir')
        close
        call  s:vde()
        call g:JumpToWindowByName('menu')
    endif
endfunction

function! g:Switcher()
    if (g:AnyWindowsExist('menu','term','client','dir'))
        if (g:IsCurrentWindow('client'))
            if (g:AnyWindowsExist('menu'))
                call g:JumpToWindowByName('menu')
            endif
            if (g:AnyWindowsExist('dir'))
                call g:JumpToWindowByName('dir')
            endif
            nnoremap <buffer> <Tab> :call g:Switcher()<cr>
            nnoremap <buffer> <leader>d :call g:SwitcherDir()<cr>
        elseif (g:IsCurrentWindow('menu'))
            call g:JumpToWindowByName('client')
            nnoremap <buffer> <Tab> :call g:Switcher()<cr>
            nnoremap <buffer> <leader>d :call g:SwitcherDir()<cr>
        elseif (g:IsCurrentWindow('dir'))
            call g:JumpToWindowByName('client')
            nnoremap <buffer> <Tab> :call g:Switcher()<cr>
            nnoremap <buffer> <leader>d :call g:SwitcherDir()<cr>
        elseif (g:IsCurrentWindow('term'))
            nnoremap <buffer> <Tab> :call g:Switcher()<cr>
            nnoremap <buffer> <leader>d :call g:SwitcherDir()<cr>
            let NOTHING=0
        endif
    endif
endfunction


nnoremap <Tab> :call g:Switcher()<cr>
nnoremap <leader>d :call g:SwitcherDir()<cr>

let s:nv_cache1 = {}
let s:nv_cache2 = {}
source ~/.vim/bundle/vim-ide/utils.vim

source ~/.vim/bundle/vim-ide/popup.vim
source ~/.vim/bundle/vim-ide/inputpopup.vim
source ~/.vim/bundle/vim-ide/store.vim

let g:loaded_plugin_dir=1

let s:BrowseMode = 0
let s:READFILEACTION = 0
let s:OPENFILEACTION = 1
let s:CLOSESPLITAFTERACTION = 0
let s:OPENSPLITAFTERACTION = 1
let s:KEEPSPLITOPEN = 0


" *****************************************************************************************************
                "  Command definitions
                " *************************************************************************************
command! UPDATEVIMIDE  :PluginUpdate vim-ide
command! DIR           :call s:MyDirPwd(1)
command! DIRC          :call s:MyDirPwd(0)
command! IDE           :call s:vde()
command! VDE           :call s:vde()


" *****************************************************************************************************
                "  Local/Script Functions
                " *************************************************************************************
let s:DirSet = ""
let s:DirMask = "/*"
let s:DirEditWindow=0
let s:DirCloseWindow=1
let s:DirWindow=0
function! s:DirSetMask(...)
    let s:DirMask = a:1
    return  s:DirMask
endfunction

" https://vim.fandom.com/wiki/Get_the_name_of_the_current_file
function! s:PathFileName(...)                  " Given a full filename path, return the filename part
    return fnamemodify(a:1, ':t')
endfunction
function! s:PathLastDirectory(...)             " Given a full filename path, return the last directoryi name only
    return fnamemodify(a:1, ':p:h:t')
endfunction
function! s:PathFullDirectory(...)             " Given a full filename path, return thei path to the filename
    return fnamemodify(a:1, ':p:h')
endfunction
function! s:FileNameExtension(...)
    return split(a:1,"[.]")[-1]
endfunction
function! s:DirFileNameExtension(...)
    return split(a:1,"[.]")[-1]
endfunction
function! s:FileNameFirstPart(...)
    return split(a:1,"[.]")[0]
endfunction
function! s:FileNameSecondPart(...)
    return split(a:1,"[.]")[1]
endfunction
function! s:FileNameMiddlePart(...)
    return split(a:1,"[.]")[1]
endfunction
function! s:FileNameThirdPart(...)
    return split(a:1,"[.]")[2]
endfunction
function! s:FileNameLastPart(...)
    return split(a:1,"[.]")[-1]
endfunction
function! s:FileNameBookEnds(...)
    let l:nRet = 0
    if (split(a:1,"[.]")[0] == a:2) 
        if (split(a:1,"[.]")[-1] == a:3)
            let l:nRet = 1
        endif
    endif
    return l:nRet
endfunction
function! s:FileNameIs(...)
    let l:nRet = 0
    if (a:1 == a:2) 
            let l:nRet = 1
    endif
    return l:nRet
endfunction
function! s:DirFileName(...)
    return  join(split(a:1,"/")[-1:-1])
endfunction
function! s:DirToken(...)
    let l:ret = ""
    if (strlen(a:1) > 0)
        let l:ret = split(a:1," ")[-1]
    endif
    return l:ret
endfunction
function! s:DirSetPwd()
    let s:DirSet = getcwd()
    return s:DirSet
endfunction
function! s:DirSetUp()
    let s:DirSet = (s:DirSet == "/") ? "/" : ("/" . join( (split(s:DirSet,"/"))[:-2], "/" ))
    return s:DirSet
endfunction
function! s:DirSetInto(...)
    let s:DirSet = (a:1 == "") ?  s:DirSet : s:DirSet . "/" . a:1
    return s:DirSet
endfunction
let s:PutLineRow=0
function! s:PutLineSet(...)
    let s:PutLineRow = a:1 
endfunction

function! s:PutLine(...)
        call setline(s:PutLineRow, a:1)
        let s:PutLineRow = s:PutLineRow + 1
endfunction


function! s:MyDir(...)
        let l:CommandType = a:1
        call s:PutLineSet(0)
        " Load Directory Part
        let l:forcetype = "f"
        if (a:0 == 2)
            let l:list = split(glob(a:2),'\n')
        else
            if (a:0 == 3)
                let l:list = split(glob(a:2),'\n') + split(glob(a:3),'\n')
            else
                if (a:0 == 4)
                    let l:list = split(glob(a:2),'\n') + split(glob(a:3),'\n') + split(glob(a:4),'\n')
                else
                    if (a:0 == 5)
                        let l:list = split(glob(a:2),'\n') + split(glob(a:3),'\n') + split(glob(a:4),'\n') + split(glob(a:5),'\n')
                    else
                        if (a:0 == 6)
                            let l:list = readfile("./projectfile")
                        endif
                    endif
                endif
            endif
        endif

        " Create Window/Buffer Part
        " 8 Args
        "call g:NewWindow("Left", &columns/3, "<Enter> :call g:MyDirAction('r')", "x :call g:MyDirAction('e')", "n :call g:MyDirAction('n')", "p :call g:MyDirAction('p')", "v :call g:MyDirAction('v')","q :call g:MyDirAction('q')")
        call g:NewWindow("Left", &columns/3, "<Enter> :call g:MyDirAction('r')")
        "echom "<r> edit snip, <enter> read snip into current buffer, <l> load session file, <p> open and load project"
        let w:window_name = 'dir'
        setlocal wincolor=MyCustomBg
        setlocal nonumber norelativenumber

        let s:DirWindow = winnr()
        nnoremap <silent> <buffer> i <Nop>
        nnoremap <silent> <buffer> <F1> <Nop>
        nnoremap <silent> <buffer> q :close<cr>
        nnoremap <silent> <buffer> w <C-W>w
        nnoremap <silent> <buffer> W <C-W>w
        nnoremap <silent> <buffer> f /^f<cr>
        " For Examples
        nnoremap <silent> <buffer> e /^f E[.]<cr>
        nnoremap <silent> <buffer> E /^f E[.]<cr>
        " For Professor's site
        nnoremap <silent> <buffer> p /^f P[.]<cr>
        nnoremap <silent> <buffer> P /^f P[.]<cr>
        " For Harder Ones
        nnoremap <silent> <buffer> h /^f H[.]<cr>
        nnoremap <silent> <buffer> H /^f H[.]<cr>

        nnoremap <silent> <buffer> l /^f L<cr>
        nnoremap <silent> <buffer> L /^f L<cr>
        nnoremap <silent> <buffer> a /^f A<cr>
        nnoremap <silent> <buffer> A /^f A<cr>
        nnoremap <silent> <buffer> j /^f J<cr>
        nnoremap <silent> <buffer> J /^f J<cr>
        nnoremap <silent> <buffer> k /^f K<cr>
        nnoremap <silent> <buffer> K /^f K<cr>
    " Display Part
        setlocal cursorline
        call s:PutLineSet(1)
        call s:PutLine("[" . g:Strreplace(s:DirSet,$HOME,"$HOME") . "]")
        call s:PutLine("..")
        let l:templ = []

	for key in l:list
          let l:sz = s:DirFileName(key)
          let l:type=l:forcetype
          if (isdirectory(s:DirSet . "/" . l:sz) > 0)
               let l:type="d"
          endif
          call add(l:templ, l:type . " " . l:sz)
	endfor

	for key in sort(l:templ)
          call s:PutLine(key)
	endfor
        set nowrap
endfunc

function! s:AssertExecution(...)
    silent execute a:1
endfunc


" *****************************************************************************************************
                "  Global/Public Functions
                " *************************************************************************************
function! s:MyDirSelect(...)
    let  s:DirCloseWindow = a:2
    let  s:DirEditWindow = winnr()
    call s:DirSetSpecific(a:1) 
    call s:MyDir(0, a:1 . s:DirMask)
endfunction

function! g:DIRPWDACTION(...)
    " a:1 is split close t/f
    " a:2 is slection action
    let s:DirCloseWindow = a:1
    let s:DirEditWindow = winnr()
    call s:DirSetPwd() 
    call s:MyDir(a:2, "." . s:DirMask)
endfunction

function! g:DIRPWD(...)
    call s:MyDirPwd(a:1)
endfunction
function! s:MyDirPwd(...)
    let s:DirCloseWindow = a:1
    let s:DirEditWindow = winnr()
    call s:DirSetPwd() 
    call s:MyDir(0, "." . s:DirMask, "./.*")
endfunction


function! s:DirSetSpecific(...)
    let s:DirSet = a:1
    return s:DirSet
endfunction

function! g:DIRSELECTOPEN(...)
    "full path with wildcards
    " open of close window on action
    call s:MyDirSelector(a:1, 1)
endfunction
function! g:DIRSELECTCLOSE(...)
    "full path with wildcards
    " open of close window on action
    call s:MyDirSelector(a:1, 0)
endfunction


"  function! s:PathFileName(...)
"  function! s:PathLastDirectory(...)
"  function! s:PathFullDirectory(...)
function! s:MyDirSelector(...)
    let  s:DirCloseWindow = a:2
    let  s:DirEditWindow = winnr()
    call s:DirSetSpecific(s:PathFullDirectory(a:1))
    call s:MyDir(1, a:1)
endfunction


function! s:RemoveFirstToken(str)
    let l:tokens = split(a:str)
    if len(l:tokens) <= 1
        return a:str
    endif
    return join(l:tokens[1:], ' ')
endfunction


function! g:MyDirAction(...)
     let l:sz   = s:RemoveFirstToken(getline("."))
     echom l:sz
     if (line(".") > 1) 
         if (strlen(l:sz) > 0)
             if (l:sz == "..")
                 silent execute "q"
                 let l:sz = s:DirSetUp()
                 call s:MyDir(0, s:DirSet . s:DirMask)
                 return
             endif
             let l:fs = s:DirSet . "/" . l:sz
             if ( isdirectory(s:DirSet . "/" . l:sz) == 0 )
                     " **************************
                     " This is the <enter> action
                     " **************************
                     if (a:1 == 'r')
                         call g:JumpToWindowByName('client')
                         execute "e " . l:fs
                         normal! k
                     endif
             else
                 silent execute "q"
                 call s:DirSetInto(l:sz)
                 call s:MyDir(0, s:DirSet . s:DirMask)
             endif
         endif
     endif
endfunction

" SECHIGH
" *****************************************************************************************************
                "  Highlights
                " *************************************************************************************
highlight ColorRed     ctermfg=Red     guifg=#ff0000 cterm=bold gui=bold
"highlight ColorGreen   ctermfg=Green   guifg=#00ff00 cterm=bold,reverse,underline gui=bold,reverse,underline
highlight ColorGreenBold   ctermfg=Green   guifg=#00ff00 cterm=bold gui=bold
highlight ColorGreen       ctermfg=Green   guifg=#00ff00
highlight ColorBlue    ctermfg=Blue    guifg=#0087ff cterm=bold gui=bold
highlight ColorYellow  ctermfg=Yellow  guifg=#ffff00 cterm=bold gui=bold
highlight ColorCyan    ctermfg=Cyan    guifg=#00ffff cterm=bold gui=bold
highlight ColorMagenta ctermfg=Magenta guifg=#ff00ff cterm=bold gui=bold
highlight ColorMagentaReverse ctermfg=Magenta guifg=#ff00ff cterm=bold,reverse gui=bold,reverse
highlight ColorWhite   ctermfg=White   guifg=#ffffff cterm=bold gui=bold
highlight ColorBlack   ctermfg=Black   guifg=#000000 
highlight ColorGray    ctermfg=Gray    guifg=#808080 cterm=NONE gui=NONE
highlight MyCustomBg guibg=#00005f ctermbg=17 guifg=#ffffff ctermfg=255

function! s:MakeCertainLinesWhite()
    "call clearmatches()
    "call matchadd('ColorWhite', '\%>0l\%<4l.*')
    call matchadd('ColorWhite', '\%>0l\%<'.  (s:listlength+4) . 'l.*')
endfunction
function! s:MakeAllLinesWhite()
    call clearmatches()
    call matchadd('ColorWhite', '.*')
endfunction
function! s:PutLineColor(...)
    " a:000[0] is the highlight group (a:1)
    " a:000[1:] contains all the subsequent string arguments
    for l:str in a:000[1:]
        call s:PutLine(l:str)
        call matchadd(a:000[0], "\\%" . (s:PutLineRow - 1) . "l^.*$")
    endfor
endfunction

" General helper function: takes a highlight group and a line number
function! s:HighlightLine(hl_group, line_num)
    call matchadd(a:hl_group, "\\%" . a:line_num . "l^.*$")
endfunction
function! s:PutInLineHeader(hl_group, title)
    let l:width = winwidth(0) - 4
    let l:pad = max([2, (l:width - strdisplaywidth(a:title)) / 2])
    let l:line = repeat('─', l:pad) . ' ' . a:title . ' ' . repeat('─', l:pad)
    call s:PutLineColor(a:hl_group, l:line)
endfunction
function! s:PutInBox(...) abort
        let l:sz = g:BoxTopLeft
        let l:sz = l:sz . repeat( g:BoxHoriz, winwidth(0)-4)
        let l:sz = l:sz . g:BoxTopRight
        call s:PutLineColor(a:1, l:sz)

        let l:sz = g:BoxVert
        let l:sz = l:sz . CenterString(a:2, winwidth(0)-4)
        " let l:sz = l:sz . repeat( " ", winwidth(0)-4)
        let l:sz = l:sz . g:BoxVert
        call s:PutLineColor(a:1, l:sz)

        let l:sz = g:BoxBotLeft
        let l:sz = l:sz . repeat( g:BoxHoriz, winwidth(0)-4)
        let l:sz = l:sz . g:BoxBotRight
        call s:PutLineColor(a:1, l:sz)
endfunction

" Main function: takes a highlight group, a search string, and an optional mode ('first' or 'all')
"
" USAGE NOTES & EXAMPLES:
" --------------------------------------------------------------------------
" 1. Highlight only the first occurrence (default behavior):
"    :call s:MakeAllLinesWhite()
"    :call HighlightLineWithStr('ColorRed', 'TODO')
"
" 2. Highlight all occurrences using a specific highlight group:
"    :call HighlightLineWithStr('ColorBlue', 'FIXME', 'all')
"
" 3. Explicitly pass 'first' if you want to be clear about the default behavior:
"    :call HighlightLineWithStr('WarningMsg', 'ERROR', 'first')
" --------------------------------------------------------------------------
function! HighlightLineWithStr(hl_group, search_str, ...)
    " Default to 'first' if no third argument is provided
    let l:mode = get(a:, 1, 'first')
    let l:last_line = line('$')

    " Loop through every line in the current buffer
    for l:i in range(1, l:last_line)
        " Check if the line contains the search string literally
        if stridx(getline(l:i), a:search_str) != -1
            call s:HighlightLine(a:hl_group, l:i)
            
            " Stop after the first match by default
            if l:mode ==# 'first'
                break
            endif
        endif
    endfor
endfunction


" SECVDE SECVDI
" *****************************************************************************************************
                "  Vim Development Environment
                " *************************************************************************************
function! s:vde()
    call g:DIRPF()
endfunction
function! s:vdecreate()
    call g:DIRCPF()
endfunction

function! g:DIRPF()
    let s:DirCloseWindow = 0
    call s:DirSetPwd() 
    let s:DirSet = "./"
    call s:MyProject()
endfunction

function! g:DIRCPF()
    " Search upwards from the current file's directory for .git
    if (!(!empty(finddir('.git', '.;')) || !empty(findfile('.git', '.;'))))
        echom "Not a git repository."
        return
    else
        call ShowPopupMessage('You are in a git repository',1500)
        let l:szCommand="git ls-files --full-name | sort > ./projectfile"
        call system(l:szCommand)
    endif

    let s:DirCloseWindow = 0
    call s:DirSetPwd() 
    let s:DirSet = "./"

    call s:MyProject()
endfunction


function! s:MyProject(...)

        if !filereadable($HOME . "/projects")
            return
        endif
        let l:projectlist = readfile($HOME . "/projects")
        let l:first_project = l:projectlist[0]
        if getcwd() ==# expand('~')
            call chdir(expand(l:first_project))
        endif

        if !filereadable("./projectfile")
            return
        endif

        call s:PutLineSet(0)
        let l:list = readfile("./projectfile")
        let l:first_file = l:list[0]
        let s:listlength = len(l:list)

        let l:n=-1
        let l:k=0
        for key in l:list
              let l:k=strlen(key)
              if ( l:k > l:n )
                  let l:n=l:k
              endif
        endfor
        let l:n=l:n+6

        let s:client_win = win_getid()
        " Create Window/Buffer Part
        let w:window_name = 'client'
        call g:NewWindow("Left", l:n, "<Enter> :call g:MySelectionAction('rx')")
        let w:window_name = 'menu'
        nnoremap <buffer> <Tab> :call g:Switcher()<cr>
        let s:menu_win = win_getid()

        setlocal wincolor=MyCustomBg
        setlocal nonumber norelativenumber

        let s:DirWindow = winnr()

        " Display Part
        setlocal cursorline
        call s:PutLineSet(1)
        let l:dir_name = fnamemodify(getcwd(), ':t')
        call s:PutInLineHeader('ColorMagenta', l:dir_name)

        call StoreClear(s:nv_cache2)

        exe "wincmd w"
        execute "e " .  $HOME . "/" . "LUCIEN"
        call g:CloseBuffersExceptLucien() 
        exe "wincmd w"

        " Create an empty dictionary to store bufnr as key and filename as value
        let l:buffer_dict = {}

        " Iterate through all listed buffers
        for l:buf in getbufinfo({'buflisted': 1})
            if !empty(l:buf.name)
               let l:buffer_dict[l:buf.name] = l:buf.bufnr
           endif
        endfor

        for key in l:list
              call s:PutLine(key)
              call g:JumpToLineWithStr(key)
                 call StorePut(s:nv_cache2, key, key)
                 call g:JumpToWindowByName('client')
                 execute "e " .  s:DirSet . "/" . key
                 call g:JumpToWindowByName('menu')
        endfor


        call g:JumpToWindowByName('client')
        call g:CloseLucienBuffer()
        call g:JumpToWindowByName('menu')

        let s:cmdBrowseMode="Browse-On"
        let s:cmdBrowseModeOff="Browse-Off"
        let s:cmdSetComment="Set-Comment"
        let s:cmdCommitBuffer="Commit-Buffer"
        let s:cmdCommitAll="Commit-All"
        let s:cmdPush="Push"
        let s:cmdCommitPush="Commit-Push"
        let s:cmdViewLog="View-Log"
        let s:cmdStatus="Git-Status"
        let s:cmdLog="Git-Log"
        let s:cmdUnusedFunctions="UnFunctions"
        let s:cmdFunctions="Functions"

        set nowrap

        call s:PutInLineHeader('ColorMagenta', "Actions-Config")
        call s:PutLineColor('ColorYellow', "Vim" . g:GetVimVersionString() . (exists('*popup_dialog') ? ", ":", No ") . "Popups")
        call s:PutLineColor('ColorYellow',s:cmdBrowseModeOff, s:cmdSetComment, "", s:cmdCommitBuffer,s:cmdCommitAll, s:cmdPush, s:cmdCommitPush, s:cmdViewLog, s:cmdStatus, s:cmdLog, s:cmdFunctions,s:cmdUnusedFunctions)
        call s:PutInLineHeader('ColorMagenta', "Projects")

        for repo in l:projectlist
              let l:sz = "PRJ " . s:PathFileName(repo)
              call StorePut(s:nv_cache1, l:sz, repo)
              call s:PutLineColor('ColorYellow', l:sz )
        endfor


        if filereadable(s:DirSet . "/" . l:first_file)
            call HighlightLineWithStr('ColorGreen', l:first_file)
			call g:JumpToLineWithStr(l:first_file)
            exe "wincmd w"
            execute "e " .  s:DirSet . "/" . l:first_file
            if (s:BrowseMode == 1)
                exe "wincmd w"
            endif
        endif

        set nowrap

endfunc

function! g:MySelectionAction(...)

     let l:sz   = s:DirToken(getline("."))
     let l:sz   = getline(".")
     " **************************
     " This is the <enter> action
     " **************************
     if (a:1 == 'rx')
         if (l:sz == s:cmdCommitAll)
             echom l:sz
             execute "!git commit -a -m \"Commit-All\""
         elseif (l:sz == s:cmdPush)
             echom l:sz
             execute "!git push origin master"
         elseif (l:sz == s:cmdCommitPush)
             "call g:RunBashCommandAndShow("git commit -a -m \"Commit-All\"")
             "call g:RunBashCommandAndShow("git push origin master")
             call g:RunBashCommand("git commit -a -m \"Commit-All\"")
             call g:RunBashCommand("git push origin master")
         elseif (l:sz == s:cmdUnusedFunctions)
             call g:JumpToWindowByName('client')
             let l:my_unused = g:GetUnusedBufferFunctionList()
             call g:ShowPopupDict(l:my_unused)
         elseif (l:sz == s:cmdFunctions)
             call g:JumpToWindowByName('client')
             let l:my_unused = g:GetBufferFunctionList()
             call g:ShowPopupDict(l:my_unused)
         elseif (l:sz == s:cmdStatus)
             let l:command = "git status"
             call g:RunBashCommandAndShow(l:command)
         elseif (l:sz == s:cmdLog)
             let l:command = "git log -n 5 --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) <%an>%Creset' --stat"
             call g:RunBashCommandAndShow(l:command)
         elseif (l:sz == s:cmdCommitBuffer)
             call g:JumpToWindowByName('client')
             let l:fn=expand('%')
             execute "!git add" . " " . l:fn
             execute "!git commit -m \"Update\"" . " " . l:fn
             call g:JumpToWindowByName('menu')
         elseif (l:sz == s:cmdViewLog)
             call g:JumpToWindowByName('client')
             execute "e " . expand('~/.vim/debug.log')
             normal! k
         elseif (l:sz == s:cmdSetComment)
             let s:comment = readfile($HOME . "/comments")[0]
             let s:comment = PromptPopupInput("New comment:", s:comment)
             redraw!
         elseif (g:StartsWith("Browse-", l:sz))
             let s:BrowseMode = s:BrowseMode ? 0 : 1
             call setline('.', s:BrowseMode ? s:cmdBrowseMode : s:cmdBrowseModeOff)
         elseif (g:StartsWith("PRJ ", l:sz))
             call ShowPopupMessage('cd ' .  StoreGet(s:nv_cache1, l:sz), 1000)
             execute 'cd ' .  StoreGet(s:nv_cache1, l:sz)
             execute 'q'
             call s:vde()
          else
             call HighlightLineWithStr('ColorGreen', l:sz)
             call g:JumpToLineWithStr(l:sz)
             call g:JumpToWindowByName('client')
             execute "e " .  s:DirSet . "/" . l:sz
             if (s:BrowseMode == 1)
                 call g:JumpToWindowByName('menu')
             endif
         endif
     endif
     echom ""
endfunction
