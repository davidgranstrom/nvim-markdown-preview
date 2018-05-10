" File: ftplugin/markdown.vim
" Author: David Granström
" Description: Preview markdown files in the browser
" License: GPL3

if exists('b:did_nvim_markdown_preview')
  finish
endif

let b:did_nvim_markdown_preview = 1

function! MarkdownPreview(css)
  let s:stylesheet = a:css != '' ? a:css . '.css' : 'github.css'

  augroup nvim_markdown_preview
    autocmd!
    autocmd BufWritePost *.md,*.markdown call markdown#generate(s:stylesheet)
  augroup END

  call markdown#generate(s:stylesheet)
endfunction

command -nargs=? -buffer MarkdownPreview call MarkdownPreview(<q-args>)
noremap <buffer><silent> <Plug>(nvim-markdown-preview) :<c-u>call MarkdownPreview<cr>
