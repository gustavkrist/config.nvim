function! s:manageEditorSize(...)
    let count = a:1
    let to = a:2
    for i in range(1, count ? count : 1)
        call VSCodeNotify(to == 'increase' ? 'workbench.action.increaseViewSize' : 'workbench.action.decreaseViewSize')
    endfor
endfunction

function! s:vscodeCommentary(...) abort
    if !a:0
        let &operatorfunc = matchstr(expand('<sfile>'), '[^. ]*$')
        return 'g@'
    elseif a:0 > 1
        let [line1, line2] = [a:1, a:2]
    else
        let [line1, line2] = [line("'["), line("']")]
    endif

    call VSCodeCallRange("editor.action.commentLine", line1, line2, 0)
endfunction

function! s:openVSCodeCommandsInVisualMode()
    normal! gv
    let visualmode = visualmode()
    if visualmode == "V"
        let startLine = line("v")
        let endLine = line(".")
        call VSCodeNotifyRange("workbench.action.showCommands", startLine, endLine, 1)
    else
        let startPos = getpos("v")
        let endPos = getpos(".")
        call VSCodeNotifyRangePos("workbench.action.showCommands", startPos[1], endPos[1], startPos[2], endPos[2], 1)
    endif
endfunction

function! s:openWhichKeyInVisualMode()
    normal! gv
    let visualmode = visualmode()
    if visualmode == "V"
        let startLine = line("v")
        let endLine = line(".")
        call VSCodeNotifyRange("whichkey.show", startLine, endLine, 1)
    else
        let startPos = getpos("v")
        let endPos = getpos(".")
        call VSCodeNotifyRangePos("whichkey.show", startPos[1], endPos[1], startPos[2], endPos[2], 1)
    endif
endfunction

" Better Navigation
nnoremap <silent> <C-j> :call VSCodeNotify('workbench.action.navigateDown')<CR>
xnoremap <silent> <C-j> :call VSCodeNotify('workbench.action.navigateDown')<CR>
nnoremap <silent> <C-k> :call VSCodeNotify('workbench.action.navigateUp')<CR>
xnoremap <silent> <C-k> :call VSCodeNotify('workbench.action.navigateUp')<CR>
nnoremap <silent> <C-h> :call VSCodeNotify('workbench.action.navigateLeft')<CR>
xnoremap <silent> <C-h> :call VSCodeNotify('workbench.action.navigateLeft')<CR>
nnoremap <silent> <C-l> :call VSCodeNotify('workbench.action.navigateRight')<CR>
xnoremap <silent> <C-l> :call VSCodeNotify('workbench.action.navigateRight')<CR>

nnoremap gr <Cmd>call VSCodeNotify('editor.action.goToReferences')<CR>

" Bind C-/ to vscode commentary since calling from vscode produces double comments due to multiple cursors
xnoremap <expr> <C-/> <SID>vscodeCommentary()
nnoremap <expr> <C-/> <SID>vscodeCommentary() . '_'

nnoremap <silent> <C-w>_ :<C-u>call VSCodeNotify('workbench.action.toggleEditorWidths')<CR>

nnoremap <silent> <Space> :call VSCodeNotify('whichkey.show')<CR>
xnoremap <silent> <Space> :<C-u>call <SID>openWhichKeyInVisualMode()<CR>

xnoremap <silent> <C-P> :<C-u>call <SID>openVSCodeCommandsInVisualMode()<CR>

xmap gc  <Plug>VSCodeCommentary
nmap gc  <Plug>VSCodeCommentary
omap gc  <Plug>VSCodeCommentary
nmap gcc <Plug>VSCodeCommentaryLine

" Simulate same TAB behavior in VSCode
nmap <Tab> :Tabnext<CR>
nmap <S-Tab> :Tabprev<CR>

" Wrapping movement

nmap j gj
nmap k gk

" Move visual text

function! s:moveVisualTextDown()
    normal! gv
    let startLine = line("v")
    let endLine = line(".")
    call VSCodeCallRange("editor.action.moveLinesDownAction", startLine, endLine, 1)
    sleep 10m
    exec 'exec "norm! ojo"'
endfunction

function! s:moveVisualTextUp()
    normal! gv
    let startLine = line("v")
    let endLine = line(".")
    call VSCodeCallRange("editor.action.moveLinesUpAction", startLine, endLine, 1)
    sleep 10m
    exec 'exec "norm! ok"'
endfunction


xnoremap <silent> J :<C-u>call <SID>moveVisualTextDown()<CR>
xnoremap <silent> K :<C-u>call <SID>moveVisualTextUp()<CR>

" Stay in indent mode
vnoremap <silent> > >gv
vnoremap <silent> < <gv

set clipboard=unnamedplus
set hlsearch
set ignorecase
set smartcase
set smartindent

" Toggle terminal

nnoremap <silent> <C-T> :call VSCodeNotify('workbench.action.terminal.toggleTerminal')<CR>

" nmap s <Plug>(easymotion-s2)
" omap t <Plug>(easymotion-bd-tl)

" let g:EasyMotion_smartcase = 1


function! s:insertSnippetInVisualMode()
    normal! gv
    let visualmode = visualmode()
    if visualmode == "V"
        let startLine = line("v")
        let endLine = line(".")
        call VSCodeNotifyRange("editor.action.insertSnippet", startLine, endLine, 1)
        exec 'exec "norm! \<Esc>"'
        call feedkeys("i")
    else
        let startPos = getpos("v")
        let endPos = getpos(".")
        call VSCodeNotifyRangePos("editor.action.insertSnippet", startPos[1], endPos[1], startPos[2], endPos[2], 1)
        exec 'exec "norm! \<Esc>"'
        call feedkeys("i")
    endif
endfunction

" nnoremap <silent> <C-B> :<C-u>call VSCodeNotify("editor.action.insertSnippet")<CR>
vnoremap <silent> <C-]> :<C-u>call <SID>insertSnippetInVisualMode()<CR>
xnoremap <silent> <C-]> :<C-u>call <SID>insertSnippetInVisualMode()<CR>
