" File: ftplugin/markdown.vim
" Author: David Granström
" Description: Preview markdown files in the browser
" License: GPL3

if exists('b:did_nvim_markdown_preview')
  finish
endif
let b:did_nvim_markdown_preview = 1

function! s:markdown_preview(css)
  let default_theme = get(g:, 'nvim_markdown_preview_theme', 'github')
  let s:stylesheet = a:css != '' ? a:css : default_theme
  let s:stylesheet = s:stylesheet . '.css'

  try
    let error_msg = "Can't find %s in $PATH"

    if !executable('pandoc')
      throw printf(error_msg, 'pandoc')
    endif

    if !executable('live-server')
      throw printf(error_msg, 'live-server')
    endif
  catch
      echoerr v:exception
  endtry

  augroup nvim_markdown_preview
    autocmd!
    autocmd BufWritePost *.md,*.markdown call markdown#generate(s:stylesheet, 0)
  augroup END

  call markdown#generate(s:stylesheet, 1)
endfunction

command -nargs=? -buffer MarkdownPreview silent call <SID>markdown_preview(<q-args>)
noremap <buffer><silent> <Plug>(nvim-markdown-preview) :<c-u>MarkdownPreview<cr>
