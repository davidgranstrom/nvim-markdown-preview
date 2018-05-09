" File: autoload/markdown/markdown.vim
" Author: David Granström
" Description: Preview markdown files in the browser
" License: GPLv3

let s:script_path = expand('%:p:h:h')
let s:css_path = shellescape(s:script_path . '/css/github.css')
let s:html_output_path = '/tmp/markdown-preview.html'

let s:callbacks = {}

function! s:callbacks.on_exit(job_id, data, event)
  if !exists('s:pid')
    call markdown#server_start(s:html_output_path)
  endif
endfunction

function! s:callbacks.on_stderr(job_id, data, event)
  echoerr join(a:data)
endfunction

function! markdown#generate() abort
  let l:path = expand('%:p')
  let l:flags = ' --standalone --metadata pagetitle=markdown-preview' . ' --include-in-header=' . s:css_path
  call jobstart(['bash', '-c', 'pandoc ' . l:path . ' -o ' . s:html_output_path . l:flags ], s:callbacks)
endfunction

function! markdown#server_start(file) abort
  let s:pid = jobstart(['bash', '-c', 'live-server ' . a:file ])
endfunction

function! markdown#server_stop() abort
  if exists('s:pid')
    call jobstop(s:pid)
  endif
endfunction
