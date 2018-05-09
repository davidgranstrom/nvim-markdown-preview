" File: ftplugin/markdown/markdown.vim
" Author: David Granström
" Description: Preview markdown files in the browser
" License: GPLv3

if exists("b:did_markdown_preview")
  finish
endif

let b:did_markdown_preview = 1

function! MarkdownPreview()
  augroup markdown_preview
    autocmd!
    autocmd BufWritePost *.md,*.markdown call markdown#generate()
  augroup END

  call markdown#generate()
endfunction

command -buffer MarkdownPreview call MarkdownPreview()
noremap <buffer><silent> <Plug>(markdown-preview) :<c-u>call MarkdownPreview<cr>

command -buffer MarkdownPreviewStop call markdown#server_stop()
noremap <buffer><silent> <Plug>(markdown-preview-stop) :<c-u>call markdown#server_stop()<cr>
