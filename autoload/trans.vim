" ============================================================================
" File:        trans.vim
" Description: Autoload functions for translate-shell.vim
" Maintainer:  Egor Churaev <egor.churaev@gmail.com>
" Licence:     GPLv3
"
" ============================================================================

function! trans#TransTerm(...)
    if s:check() || v:version < 800
        return
    endif
    let args = common#trans#GenerateArgs(g:trans_default_direction, a:000)
    let cmd = common#trans#GenerateCMD(args)
    execute "term ".cmd
endfunction

function! trans#Trans(...)
    if s:check()
        return
    endif
    let text = common#trans#PrepareTextToTranslating(expand("<cword>"))
    let args = common#trans#GenerateArgs(g:trans_default_direction, a:000)
    let cmd = common#trans#GenerateCMD(args, text)
    call common#window#OpenTrans(cmd)
endfunction

function! trans#TransVisual(...)
    if s:check()
        return
    endif
    let text = common#common#GetVisualSelection()
    if g:trans_join_lines > 0
        let text = common#common#JoinLinesInText(text)
    endif
    let text = common#trans#PrepareTextToTranslating(text)
    let args = common#trans#GenerateArgs(g:trans_default_direction, a:000)
    let cmd = common#trans#GenerateCMD(args, text)
    call common#window#OpenTrans(cmd)
endfunction

function! trans#TransSelectDirection()
    if s:check()
        return
    endif

    let size_trans_directions_list = len(g:trans_directions_list)
    if size_trans_directions_list == 0
        call trans#Trans()
        return
    endif

    let selected_number = 0
    if size_trans_directions_list > 1
        let shown_items = common#trans#GetItemsForInputlist()
        let selected_number = inputlist(shown_items) - 1
    endif

    let trans_direction = common#trans#GenerateTranslateDirection(selected_number)
    if trans_direction == ""
        return
    endif
    let text = common#trans#PrepareTextToTranslating(expand("<cword>"))
    let cmd = common#trans#GenerateCMD(trans_direction, text)
    call common#window#OpenTrans(cmd)
endfunction

function! trans#TransVisualSelectDirection()
    if s:check()
        return
    endif

    let size_trans_directions_list = len(g:trans_directions_list)
    if size_trans_directions_list == 0
        call trans#TransVisual()
        return
    endif

    let selected_number = 0
    if size_trans_directions_list > 1
        let shown_items = common#trans#GetItemsForInputlist()
        let selected_number = inputlist(shown_items) - 1
    endif

    let trans_direction = common#trans#GenerateTranslateDirection(selected_number)
    if trans_direction == ""
        return
    endif
    let text = common#common#GetVisualSelection()
    if g:trans_join_lines > 0
        let text = common#common#JoinLinesInText(text)
    endif
    let text = common#trans#PrepareTextToTranslating(text)
    let cmd = common#trans#GenerateCMD(trans_direction, text)
    call common#window#OpenTrans(cmd)
endfunction

function! trans#TransInteractive(...)
    if s:check()
        return
    endif

    let selected_number = 0
    if len(g:trans_directions_list) > 1 && len(a:000) == 0
        let shown_items = common#trans#GetItemsForInputlist()
        let selected_number = inputlist(shown_items) - 1
    endif

    let args = common#trans#GenerateTranslateDirection(selected_number)
    if args == "" || len(a:000) > 0
        let args = common#trans#GenerateArgs(g:trans_default_direction, a:000)
        let text = input("Translate (cmd: ".common#trans#GenerateCMD(args)."): ")
    else
        let human_direction = common#trans#GetHumanDirectionsList()[selected_number]
        let text = input(human_direction." Translate: ")
    endif
    let text = common#trans#PrepareTextToTranslating(text)
    let cmd = common#trans#GenerateCMD(args, text)
    call common#window#OpenTrans(cmd)
endfunction

function! trans#TransOpenHistoryWindow()
    if s:check()
        return
    endif
    call common#window#OpenTransHistoryWindow()
endfunction

function! s:check() abort
    let cmd = common#trans#GetPathToBin()
    let cmd = cmd.'trans'
    if !executable(cmd)
        echohl WarningMsg | echomsg "Trans unavailable! CMD: ".cmd | echohl None
        return 1
    endif
    return 0
endfunction

