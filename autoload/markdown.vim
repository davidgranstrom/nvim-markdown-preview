" File: autoload/markdown.vim
" Author: David Granström
" Description: Preview markdown files in the browser
" License: GPL3

let s:script_path = expand('%:p:h:h')
let s:css_path = s:script_path . '/css/'
let s:html_output_path = '/tmp/markdown-preview.html'

let s:Pandoc = {'name': 'Pandoc'}

function! s:Pandoc.generate(css) abort
  let l:path = expand('%:p')
  let l:flags = ' --standalone --metadata pagetitle=markdown-preview' . ' --include-in-header=' . s:css_path . a:css
  call jobstart(['bash', '-c', 'pandoc ' . l:path . ' -o ' . s:html_output_path . l:flags ], self)
endfunction

function! s:Pandoc.on_exit()
  call s:LiveServer.start(s:html_output_path)
endfunction

function! s:Pandoc.on_stderr(job_id, data, event)
  echoerr printf('[%s] %s', self.name, join(a:data))
endfunction


let s:LiveServer = {'name': 'LiveServer'}

function! s:LiveServer.start(file)
  if !exists('self.pid')
    let self.pid = jobstart(['bash', '-c', 'live-server ' . a:file ], self)
  endif
endfunction

function! s:LiveServer.stop()
  if exists('self.pid')
    call jobstop(self.pid)
    unlet self.pid
  endif
endfunction

function! s:LiveServer.on_stderr(job_id, data, event)
  echoerr printf('[%s] %s', self.name, join(a:data))
endfunction

" Interface

function! markdown#generate(css) abort
  call s:Pandoc.generate(a:css)
endfunction

function! markdown#server_start(file) abort
  call s:LiveServer.start(a:file)
endfunction

function! markdown#server_stop() abort
  call s:LiveServer.stop()
endfunction
