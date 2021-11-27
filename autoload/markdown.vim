" File: autoload/markdown.vim
" Author: David Granström
" Description: Preview markdown files in the browser
" License: GPL3

let s:script_path = expand('<sfile>:p:h:h')
let s:css_path = s:script_path . '/css/'

let s:Pandoc = {'name': 'Pandoc'}
let s:output_path = tempname() . '.html'

function! s:Pandoc.generate(css, restart) abort
  let input_path = expand('%:p')
  let filename = expand('%:r')
  let stylesheet = s:css_path . a:css

  let self.server_index_path = s:output_path
  let self.server_root = fnamemodify(input_path, ':h')

  if filereadable(input_path)
    if a:restart > 0
      call s:LiveServer.stop()
    endif
    call jobstart([
          \ 'pandoc',
          \ '-f', 'gfm',
          \ input_path,
          \ '-o', s:output_path,
          \ '--standalone',
          \ '-t', 'html',
          \ '--metadata',
          \ 'pagetitle='.filename,
          \ '--include-in-header='.l:stylesheet,
          \ '--katex',
          \ ],
          \ self
          \ )
  endif
endfunction

function! s:Pandoc.on_exit(job_id, data, event)
  call s:LiveServer.start(self.server_root, self.server_index_path)
endfunction

function! s:Pandoc.on_stderr(job_id, data, event)
  let msg = join(a:data)
  if !empty(msg)
    echoerr printf('[%s] %s', self.name, join(a:data))
  endif
endfunction

let s:LiveServer = {'name': 'LiveServer'}

function! s:LiveServer.start(root, index_path)
  if !exists('self.pid')
    let mount_path = fnamemodify(a:index_path, ':h')
    let index = fnamemodify(a:index_path, ':t')
    let self.pid = jobstart([
          \ 'live-server',
          \ '--quiet',
          \ '--mount='.'/:'.mount_path,
          \ '--open='.index,
          \ ],
          \ self,
          \ )
  endif
endfunction

function! s:LiveServer.stop()
  if exists('self.pid')
    call jobstop(self.pid)
    unlet self.pid
  endif
endfunction

function! s:LiveServer.on_stderr(job_id, data, event)
  let msg = join(a:data)
  if !empty(msg)
    echoerr printf('[%s] %s', self.name, msg)
  endif
endfunction

" Interface

function! markdown#generate(css, restart) abort
  call s:Pandoc.generate(a:css, a:restart)
endfunction

function! markdown#server_start(file) abort
  call s:LiveServer.start(a:file)
endfunction

function! markdown#server_stop() abort
  call s:LiveServer.stop()
endfunction
