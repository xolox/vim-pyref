" Vim plug-in
" Author: Peter Odding <peter@peterodding.com>
" Last Change: December 19, 2010
" URL: http://peterodding.com/code/vim/pyref/
" License: MIT
" Version: 0.7

" Support for automatic update using the GLVS plug-in.
" GetLatestVimScripts: 3104 1 :AutoInstall: pyref.zip

" Don't source the plug-in when its already been loaded or &compatible is set.
if &cp || exists('g:loaded_pyref')
  finish
else
  let g:loaded_pyref = 1
endif

" Default location of index file, should be fine in most cases.
if !exists('g:pyref_index')
  if xolox#is_windows()
    let g:pyref_index = '~/vimfiles/misc/pyref_index'
  else
    let g:pyref_index = '~/.vim/misc/pyref_index'
  endif
endif

" Local Python documentation as installed by e.g. sudo apt-get install python2.6-doc
if !exists('g:pyref_python')
  let g:pyref_python = '/usr/share/doc/python2.6/html'
endif

" Local Django documentation as installed by e.g. sudo apt-get install python-django-doc
if !exists('g:pyref_django')
  let g:pyref_django = '/usr/share/doc/python-django-doc/html'
endif

" Automatic command to enable key mapping in Python buffers.
augroup PluginPyRef
  autocmd! FileType python call xolox#pyref#enable()
augroup END

" User command that looks up given argument and supports completion.
command! -nargs=? -complete=customlist,xolox#pyref#complete PyRef call xolox#pyref#lookup(<q-args>)

" vim: ts=2 sw=2 et
