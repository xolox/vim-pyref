# Context-sensitive documentation <br> for Python source code in Vim

The `pyref.vim` script is a plug-in for the [Vim text editor](http://www.vim.org/) that helps you look up the documentation for keywords and identifiers from the following sources using your web browser:

 * [Python language reference](http://docs.python.org/reference/)
 * [Python library reference](http://docs.python.org/library/)
 * [Django documentation](http://docs.djangoproject.com/)

The `:PyRef` command looks up the identifier given as an argument while the `<F1>` mapping (only available in Python buffers) looks up the item under the text cursor. The lookup works by scanning through a special index file which is included in the ZIP archive below, but you can also create/update the index yourself using the Python script [spider.py](https://github.com/xolox/vim-pyref/blob/master/misc/pyref/spider.py).

## Install & usage

*Please note that the vim-pyref plug-in requires my vim-misc plug-in which is separately distributed.*

Unzip the most recent ZIP archives of the [vim-pyref] [download-pyref] and [vim-misc] [download-misc] plug-ins inside your Vim profile directory (usually this is `~/.vim` on UNIX and `%USERPROFILE%\vimfiles` on Windows), restart Vim and execute the command `:helptags ~/.vim/doc` (use `:helptags ~\vimfiles\doc` instead on Windows).

If you prefer you can also use [pathogen], [vundle], [vim-plug] or a similar tool to install & update the [vim-pyref] [github-pyref] and [vim-misc] [github-misc] plug-ins using a local clone of the git repository.

Now try it out: Open a Python script and press the `<F1>` key on something interesting. If it doesn't work or you want to change how it works, see the options documented below.

[download-misc]: http://peterodding.com/code/vim/downloads/misc.zip
[download-pyref]: http://peterodding.com/code/vim/downloads/pyref.zip
[github-misc]: http://github.com/xolox/vim-misc
[github-pyref]: http://github.com/xolox/vim-pyref
[pathogen]: http://www.vim.org/scripts/script.php?script_id=2332
[vundle]: https://github.com/gmarik/vundle
[vim-plug]: https://www.vim.org/scripts/script.php?script_id=4828

### The `g:pyref_mapping` option

If you press `<F1>` and nothing happens you're probably using a terminal that doesn't pass `<F1>` through to Vim. In this case you can change the key mapping by setting the global variable `g:pyref_mapping` according to the syntax expected by Vim's `:imap` and `:nmap` commands:

    :let g:pyref_mapping = 'K'

Note that setting `g:pyref_mapping` won't change the key mapping in existing buffers.

### The `g:pyref_python` option

This option is useful when you don't always have a reliable internet connection available while coding. Most Linux distributions have an installable package containing the Python documentation, for example on [Ubuntu](http://packages.ubuntu.com/python2.6-doc) and [Debian](http://packages.debian.org/python2.6-doc) you can execute the following command to install the documentation:

    $ sudo apt-get install python2.6-doc

The above package puts the documentation in `/usr/share/doc/python2.6/html/` which happens to be the default path checked by the `pyref.vim` script. If you've installed the documentation in a different location you can change the global variable `g:pyref_python`, e.g.:

    :let g:pyref_python = $HOME . '/docs/python'

### The `g:pyref_django` option

This option works like `g:pyref_python` but allows you to configure the path to your local Django documentation. On [Ubuntu](http://packages.ubuntu.com/python-django-doc) and [Debian](http://packages.debian.org/python-django-doc) you can execute the following command to install the Django documentation:

    $ sudo apt-get install python-django-doc

In this case you shouldn't have to change anything because `pyref.vim` is already configured to be compatible with the `python-django-doc` package.

### The `g:pyref_index` option

If you don't like the default location of the index file you can change it by setting the global variable `g:pyref_index`. A leading `~` in the `g:pyref_index` variable is expanded to your current home directory (`$HOME` on UNIX, `%USERPROFILE%` on Windows). Be aware that when you change the `g:pyref_index` option automatic updates using the [getscript plug-in](http://vimdoc.sourceforge.net/htmldoc/pi_getscript.html#getscript) won't update the index file anymore!

### General note about options

You can change the above options permanently by putting the relevant `:let` statements in your [vimrc script](http://vimdoc.sourceforge.net/htmldoc/starting.html#vimrc).

## Contact

If you have questions, bug reports, suggestions, etc. the author can be contacted at <peter@peterodding.com>. The latest version is available at <http://peterodding.com/code/vim/pyref/> and <http://github.com/xolox/vim-pyref>. If you like the script please vote for it on [Vim Online](http://www.vim.org/scripts/script.php?script_id=3104).

## License

This software is licensed under the [MIT license](http://en.wikipedia.org/wiki/MIT_License).  
© 2013 Peter Odding &lt;<peter@peterodding.com>&gt;.
