# Context-sensitive documentation <br> for Python source code in Vim

The `pyref.vim` script is a plug-in for the [Vim text editor](http://www.vim.org/) that maps the `<F1>` key in [Python](http://python.org/) buffers to search through the [Python language reference](http://docs.python.org/reference/index.html) and [library reference](http://docs.python.org/library/index.html) documentation for the keyword or identifier at the current cursor position and open the first match in your web browser. When no GUI is available a command-line web browser like `lynx` or `w3m` will be used, otherwise the plug-in prefers a graphical web browser like Mozilla Firefox or Google Chrome.

## How does it work?

The search works by scanning through a special index file with keyword, URL pairs separated by tabs and delimited by newlines. The index file is included in the ZIP archive linked to below but you can also create it yourself using the Python script [spider.py](http://github.com/xolox/vim-pyref/blob/master/spider.py).

## Install & usage

Unzip the most recent [ZIP archive](http://peterodding.com/code/vim/downloads/pyref) file inside your Vim profile directory (usually this is `~/.vim` on UNIX and `%USERPROFILE%\vimfiles` on Windows), restart Vim and execute the command `:helptags ~/.vim/doc` (use `:helptags ~\vimfiles\doc` instead on Windows). Now try it out: Open a Python script and press the `<F1>` key.

The following paragraphs explain the available options:

### The `g:pyref_mapping` option

If you press `<F1>` and nothing happens you're probably using a terminal that doesn't pass `<F1>` through to Vim. In this case you can change the key mapping by setting the global variable `g:pyref_mapping` according to the syntax expected by Vim's `:imap` and `:nmap` commands:

    :let g:pyref_mapping = 'K'

Note that setting `g:pyref_mapping` won't change the key mapping in existing buffers.

### The `g:pyref_mirror` option

This option is useful when you don't always have a reliable internet connection available while coding. Most Linux distributions have an installable package containing the Python documentation, for example on Ubuntu and Debian you can execute the following command to install the documentation:

    $ sudo apt-get install python2.6-doc

The above package puts the documentation in `/usr/share/doc/python2.6/html/` which happens to be the default location checked by the `pyref.vim` script. If you've installed the documentation elsewhere you can change the global variable `g:pyref_mirror` accordingly.

### The `g:pyref_index` option

If you don't like the default location of the index file you can change it by setting the global variable `g:pyref_index`. A leading `~` in the `g:pyref_index` variable is expanded to your current home directory (`$HOME` on UNIX, `%USERPROFILE%` on Windows). Be aware that when you change the `g:pyref_index` option automatic updates using the [getscript plug-in](http://vimdoc.sourceforge.net/htmldoc/pi_getscript.html#getscript) won't update the index file anymore!

### General note about options

You can change the above options permanently by putting the relevant `:let` statements in your [vimrc script](http://vimdoc.sourceforge.net/htmldoc/starting.html#vimrc).

## Contact

If you have questions, bug reports, suggestions, etc. the author can be contacted at <peter@peterodding.com>. The latest version is available at <http://peterodding.com/code/vim/pyref/> and <http://github.com/xolox/vim-pyref>. If you like the script please vote for it on [www.vim.org](http://www.vim.org/scripts/script.php?script_id=3104).

## License

This software is licensed under the [MIT license](http://en.wikipedia.org/wiki/MIT_License).  
© 2010 Peter Odding &lt;<peter@peterodding.com>&gt;.
