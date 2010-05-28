The file [pyref.vim][formatted_pyref_vim] is a plug-in for the Vim text editor
that maps the `<F1>` key in Python buffers to search through the Python
language and library reference documentation for the keyword or identifier at
the current cursor position and open the first match in your web browser. When
no GUI is available a command-line web browser like `lynx` or `w3m` will be
used, otherwise the plug-in prefers a graphical web browser like Mozilla
Firefox or Google Chrome.

The search works by scanning through a special index file with keyword, URL
pairs separated by tabs and delimited by newlines. You can create this index
yourself using a Python script I've written (see [create-index.py][formatted_create_index_py])
or you can download the index that I've already created (see [vimpythonindex][formatted_vimpythonindex]).

[formatted_pyref_vim]: http://github.com/xolox/vim-pyref/blob/master/pyref.vim
[formatted_create_index_py]: http://github.com/xolox/vim-pyref/blob/master/create-index.py
[formatted_vimpythonindex]: http://github.com/xolox/vim-pyref/blob/master/vimpythonindex

 USAGE
=======

Right-click and save [pyref.vim][raw_pyref_vim] as `~/.vim/plugin/pyref.vim`
(if you're on Windows save the file as `%USERPROFILE%\vimfiles\plugin\pyref.vim`),
likewise save [vimpythonindex][raw_vimpythonindex] as `~/.vimpythonindex` (if
you're on Windows then save this file as `%USERPROFILE%\_vimpythonindex`) and
restart Vim. Now try it out: Open some Python source code in Vim and press the
`<F1>` key. If it doesn't work out of the box you probably need to change the
global variable `pyref_browser` to the filename or pathname of a working web
browser executable, e.g. inside Vim type:

    :let pyref_browser = '/usr/bin/konqueror'

[raw_pyref_vim]: http://github.com/xolox/vim-pyref/raw/master/pyref.vim
[raw_vimpythonindex]: http://github.com/xolox/vim-pyref/raw/master/vimpythonindex

 CONTACT
=========

If you have questions, bug reports, suggestions, etc. the author can be
contacted at <peter@peterodding.com>. The latest version is available
at <http://peterodding.com/code/vim/pyref> and <http://github.com/xolox/vim-pyref>.
If you like the script you can vote for it on [vim.org][vim_scripts_entry].

[vim_scripts_entry]: http://www.vim.org/scripts/script.php?script_id=3104

 LICENSE
=========

Vim-PyRef is licensed under the MIT license.
Copyright 2010 Peter Odding <peter@peterodding.com>.
