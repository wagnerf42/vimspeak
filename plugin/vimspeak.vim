" Adapted from unimpaired.vim by Tim Pope.
function! s:DoAction(algorithm,type)
  let sel_save = &selection
  let cb_save = &clipboard
  set selection=inclusive clipboard-=unnamed clipboard-=unnamedplus
  let reg_save = @@
  if a:type =~ '^\d\+$'
  silent exe 'normal! V'.a:type.'$y'
  elseif a:type =~ '^.$'
  silent exe "normal! `<" . a:type . "`>y"
  elseif a:type == 'line'
  silent exe "normal! '[V']y"
  elseif a:type == 'block'
  silent exe "normal! `[\<C-V>`]y"
  else
  silent exe "normal! `[v`]y"
  endif
  let repl = s:{a:algorithm}(@@)
  if type(repl) == 1
  call setreg('@', repl, getregtype('@'))
  normal! gvp
  endif
  let @@ = reg_save
  let &selection = sel_save
  let &clipboard = cb_save
endfunction

function! s:ActionOpfunc(type)
  return s:DoAction(s:encode_algorithm, a:type)
endfunction

function! s:ActionSetup(algorithm)
  let s:encode_algorithm = a:algorithm
  let &opfunc = matchstr(expand('<sfile>'), '<SNR>\d\+_').'ActionOpfunc'
endfunction

function! MapAction(algorithm, key)
  exe 'nnoremap <silent> <Plug>actions'.a:algorithm.
            \' :<C-U>call <SID>ActionSetup("'.a:algorithm.'")<CR>g@'
  exe 'xnoremap <silent> <Plug>actions'.a:algorithm.
            \' :<C-U>call <SID>DoAction("'.a:algorithm.'",visualmode())<CR>'
  exe 'nnoremap <silent> <Plug>actionsLine'.a:algorithm.
            \' :<C-U>call <SID>DoAction("'.a:algorithm.'",v:count1)<CR>'
  exe 'nmap '.a:key.'  <Plug>actions'.a:algorithm
  exe 'xmap '.a:key.'  <Plug>actions'.a:algorithm
  exe 'nmap '.a:key.a:key[strlen(a:key)-1].' <Plug>actionsLine'.a:algorithm
endfunction

if !exists("g:vimspeak_args")
  let g:vimspeak_args="-k30"
endif

if !exists("g:vimspeak_speed")
  let g:vimspeak_speed="-s 300"
endif

if !exists("g:vimspeak_punct")
  let g:vimspeak_punct="--punct"
endif

if !exists("g:vimspeak_enabled")
  let g:vimspeak_enabled=1
endif

let s:is_speaking = 0

function! s:Speak(str)
  if g:vimspeak_enabled != 1
    return
  endif
  if s:is_speaking == 1
    return
  endif
  let s:is_speaking = 1
  call job_start(["/bin/sh", "-c",
        \"espeak".
        \" ".g:vimspeak_args.
        \" ".g:vimspeak_speed.
        \" ".g:vimspeak_punct.
        \" ".shellescape(a:str).
        \" >/dev/null 2>&1 </dev/null"])
  let s:is_speaking = 0
endfunction

function! s:SpeakToggle()
  if g:vimspeak_enabled == 1
    call s:Speak("vim speak off")
    let g:vimspeak_enabled = 0
  else
    let g:vimspeak_enabled = 1
    call s:Speak("vim speak on")
  endif
endfunction

function! s:SpeakCancel()
  call job_start(["/bin/sh", "-c",
        \"pkill espeak >/dev/null 2>&1 &"])
endfunction

function! s:SpeakSpeed()
  call inputsave()
  call s:Speak("set new speed")
  let speed = input('Set new speed: ')
  call inputrestore()
  let g:vimspeak_speed="-s ".speed
  call s:Speak("set to ".speed)
endfunction

function! s:SpeakPunct()
  if g:vimspeak_punct == "--punct"
    let g:vimspeak_punct=""
    call s:Speak("punctuation off")
  else
let g:vimspeak_punct="--punct"
call s:Speak("punctuation on")
  endif
endfunction

function! s:SpeakCommandLine()
  call s:SpeakCancel()
  call s:Speak(getcmdline())
endfunction

call MapAction('Speak','s')
nnoremap St :<C-U>call <SID>SpeakToggle()<CR>
nnoremap Sc :<C-U>call <SID>SpeakCancel()<CR>
nnoremap Sl :<C-U>call <SID>Speak("line ".line('.'))<CR>
nnoremap Ss :<C-U>call <SID>SpeakSpeed()<CR>
nnoremap Sp :<C-U>call <SID>SpeakPunct()<CR>
nnoremap Sb :<C-U>call <SID>Speak("file ".bufname("%"))<CR>

autocmd BufEnter * :call <SID>Speak('buffer '.bufname("%"))
autocmd BufWritePost * :call <SID>Speak('wrote '.bufname("%"))
autocmd DirChanged * :call <SID>Speak('directory '.getcwd())
autocmd InsertEnter * :call <SID>Speak('insert mode')
autocmd InsertLeave * :call <SID>Speak('normal mode')
autocmd CmdlineEnter * :call <SID>Speak('e x command')
autocmd CmdlineLeave * :call <SID>Speak('normal mode')
