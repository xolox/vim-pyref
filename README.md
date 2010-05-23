The file `pyref.vim` is a plug-in for the Vim text editor that maps the `<F1>`
key in Python buffers to search through the Python language and library
reference documentation for the keyword or identifier at the current cursor
position and open the first match in your web browser. This works in both
graphical Vim and console Vim.

The search works by scanning through a special index file with keyword, URL
pairs separated by tabs and delimited by newlines. You can create this index
yourself using a Python script I've written (see `create-index.py`) or you
can download the index that I've already created (see `vimpythonindex`).

 USAGE
=======

Save `pyref.vim` as `~/.vim/plugin/pyref.vim`, save `vimpythonindex` as
`~/.vimpythonindex` and restart Vim. Now try it out: Open some Python source
code in Vim and press the <F1> key. If it doesn't work our of the box you
probably need to change the global variable `pyref_browser` to the filename or
pathname of a working web browser executable, e.g. inside Vim type:

    :let pyref_browser = '/usr/bin/konqueror'

 CONTACT
=========

If you have questions, bug reports, suggestions, etc. the author can be
contacted at <peter@peterodding.com>. The latest version is available
at <http://peterodding.com/code/vim/pyref> and <http://github.com/xolox/vim-pyref>.
