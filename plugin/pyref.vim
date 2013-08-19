" Vim plug-in
" Author: Peter Odding <peter@peterodding.com>
" Last Change: August 19, 2013
" URL: http://peterodding.com/code/vim/pyref/

" Support for automatic update using the GLVS plug-in.
" GetLatestVimScripts: 3104 1 :AutoInstall: pyref.zip

" Don't source the plug-in when it's already been loaded or &compatible is set.
if &cp || exists('g:loaded_pyref')
  finish
else
  let g:loaded_pyref = 1
endif

" Make sure vim-misc is installed.
try
  " The point of this code is to do something completely innocent while making
  " sure the vim-misc plug-in is installed. We specifically don't use Vim's
  " exists() function because it doesn't load auto-load scripts that haven't
  " already been loaded yet (last tested on Vim 7.3).
  call type(g:xolox#misc#version)
catch
  echomsg "Warning: The vim-pyref plug-in requires the vim-misc plug-in which seems not to be installed! For more information please review the installation instructions in the readme (also available on the homepage and on GitHub). The vim-pyref plug-in will now be disabled."
  let g:loaded_pyref = 1
  finish
endtry

" Make sure the default paths below are compatible with Pathogen.
let s:plugindir = expand('<sfile>:p:h') . '/../misc/pyref'

" Default location of index file, should be fine in most cases.
if !exists('g:pyref_index')
  let g:pyref_index = s:plugindir . '/index'
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
