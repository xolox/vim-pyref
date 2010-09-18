" Vim plug-in
" Author: Peter Odding <peter@peterodding.com>
" Last Change: September 18, 2010
" URL: http://peterodding.com/code/vim/pyref/
" License: MIT
" Version: 0.6

" Support for automatic update using the GLVS plug-in.
" GetLatestVimScripts: 3104 1 :AutoInstall: pyref.zip

" Don't source the plug-in when its already been loaded or &compatible is set.
if &cp || exists('g:loaded_pyref')
  finish
else
  let g:loaded_pyref = 1
endif

" Automatic command to enable plug-in for Python buffers only.

augroup PluginPyRef
  autocmd! FileType python call xolox#pyref#enable()
augroup END

" vim: ts=2 sw=2 et nowrap
