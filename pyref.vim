" Vim plug-in
" Maintainer: Peter Odding <peter@peterodding.com>
" Last Change: May 23, 2010
" URL: http://peterodding.com/code/vim/pyref
" License: MIT

" Description:
" This is a Vim plug-in that maps <F1> in Python buffers to search the Python
" language and library reference documentation for the keyword or identifier
" at the current cursor position and open the first match in your web browser.
" This should work in both graphical Vim and console Vim. The search works by
" scanning through a special index file with keyword, URL pairs separated by
" tabs and delimited by newlines. You can create this index yourself using a
" Python script I've written or you can download an index that I'm making
" available based on http://docs.python.org/.
"
" Configuration options:
"
"  "pyref_mapping": If you don't want this plug-in to use the <F1> key then
"                   you can change this global variable according to the
"                   syntax expected by :imap and :nmap.
"  "pyref_browser": If the plug-in doesn't work out of the box you might have
"                   to change this global variable to the filename or pathname
"                   of your web browser (the plug-in tries to find a sensible
"                   default but that might not always work).
"  "pyref_index":   Set this global variable to change the location of the
"                   index file from its default which is "~/.vimpythonindex".
"  "pyref_mirror":  Sometimes I don't have an internet connection available,
"                   therefor I've installed the Ubuntu package `python2.6-doc'
"                   which puts the Python language and library reference in
"                   /usr/share/doc/python2.6/html/. If you're using the exact
"                   same package everything should just work, but if you've
"                   installed the Python documentation in another location
"                   you should set this global variable to the pathname of the
"                   directory containing the HTML files.
"
" Note that you can change any of these options permanently by putting the
" relevant :let statements in your ~/.vimrc script.
"
" Tweaks:
" You can improve Vim's startup speed slightly by setting the global variables
" "pyref_browser" and/or "pyref_mirror" in your ~/.vimrc because that avoids
" querying the file system and searching the $PATH.

" Define the configuration defaults.

if !exists('pyref_index')
  let pyref_index = '~/.vimpythonindex'
endif

if !exists('pyref_mirror')
  let s:local_mirror = '/usr/share/doc/python2.6/html'
  if isdirectory(s:local_mirror)
    let pyref_mirror = 'file://' . s:local_mirror
  else
    let pyref_mirror = 'http://docs.python.org'
  endif
  unlet s:local_mirror
endif

if !exists('pyref_mapping')
  let pyref_mapping = '<F1>'
endif

if !exists('pyref_browser')
  " Search for a sensible default browser.
  let s:search_path = substitute(substitute($PATH, ',', '\\,', 'g'), ':', ',', 'g')
  " Note: Don't use `xdg-open' here, it ignores fragment identifiers :-S
  for s:browser in ['gnome-open', 'firefox', 'google-chrome']
    let s:matches = split(globpath(s:search_path, s:browser, 1), '\n')
    if len(s:matches) > 0
      let pyref_browser = s:matches[0]
      break
    endif
  endfor
  unlet s:search_path s:browser s:matches
endif

" Use an automatic command to map <F1> only inside Python buffers.

augroup PluginPyRef
  autocmd! FileType python call s:DefineMappings()
augroup END

function! s:DefineMappings()
  let command = '%s <silent> <buffer> %s %s:call <Sid>PyRef()<CR>'
  execute printf(command, 'inoremap', g:pyref_mapping, '<C-O>')
  execute printf(command, 'nnoremap', g:pyref_mapping, '')
endfunction

" This list of lists contains [url_format, method_pattern] pairs that are used
" to recognize calls to methods of objects that are one of Python's standard
" types: strings, lists, dictionaries and file handles.
let s:object_methods = [
      \ ['library/stdtypes.html#str.%s', '\.\@<=\(capitalize\|center\|count\|decode\|encode\|endswith\|expandtabs\|find\|format\|index\|isalnum\|isalpha\|isdigit\|islower\|isspace\|istitle\|isupper\|join\|ljust\|lower\|lstrip\|partition\|replace\|rfind\|rindex\|rjust\|rpartition\|rsplit\|rstrip\|split\|splitlines\|startswith\|strip\|swapcase\|title\|translate\|upper\|zfill\)$'],
      \ ['tutorial/datastructures.html#more-on-lists', '\.\@<=\(append\|count\|extend\|index\|insert\|pop\|remove\|reverse\|sort\)$'],
      \ ['library/stdtypes.html#dict.%s', '\.\@<=\(clear\|copy\|fromkeys\|get\|has_key\|items\|iteritems\|iterkeys\|itervalues\|keys\|pop\|popitem\|setdefault\|update\|values\)$'],
      \ ['library/stdtypes.html#file.%s', '\.\@<=\(close\|closed\|encoding\|errors\|fileno\|flush\|isatty\|mode\|name\|newlines\|next\|read\|readinto\|readline\|readlines\|seek\|softspace\|tell\|truncate\|write\|writelines\|xreadlines\)$']]

function! s:PyRef()

  " Get the identifier under the cursor including any dots to match
  " identifiers like `os.path.join' instead of single words like `join'.
  try
    let isk_save = &isk
    let &isk = '@,48-57,_,192-255,.'
    let ident = expand('<cword>')
  finally
    let &isk = isk_save
  endtry

  " Do something useful when there's nothing at the current position.
  if ident == ''
    return s:OpenBrowser(g:pyref_mirror . '/contents.html')
  endif

  " Escape any dots in the expression so it can be used as a pattern.
  let pattern = substitute(ident, '\.', '\\.', 'g')

  " Escape the browser path so it can be used as shell command.
  let browser = shellescape(g:pyref_browser)

  " Search for an exact match of a module name or identifier in the index.
  try
    let lines = readfile(fnamemodify(g:pyref_index, ':p'))
  catch
    let lines = []
  endtry
  if s:JumpToEntry(lines, '^\(module-\)\?' . pattern . '\t')
    return
  endif

  " Try to match a method name of one of the standard Python types: strings,
  " lists, dictionaries and files (not exactly ideal but better than nothing).
  for [url, method_pattern] in s:object_methods
    let method = matchstr(ident, method_pattern)
    if method != ''
      if url =~ '%s'
        let url = printf(url, method)
      endif
      return s:OpenBrowser(g:pyref_mirror . '/' . url)
    endif
  endfor

  " Search for a substring match in the index.
  if s:JumpToEntry(lines, pattern)
    return
  endif

  " As a last resort, search all of http://docs.python.org/ using Google.
  call s:OpenBrowser('http://google.com/search?btnI&q=inurl:docs.python.org/+' . ident)

endfunction

function! s:JumpToEntry(lines, pattern)
  let index = match(a:lines, a:pattern)
  if index >= 0
    let url = split(a:lines[index], '\t')[1]
    call s:OpenBrowser(g:pyref_mirror . '/' . url)
    return 1
  endif
  return 0
endfunction

function! s:OpenBrowser(url)
  let browser = shellescape(g:pyref_browser)
  call system(browser . ' ' . shellescape(a:url))
  if v:shell_error
    let message = "pyref.vim: Failed to execute %s! (status code %i)"
    echoerr printf(message, browser, v:shell_error)
    return 0
  endif
  return 1
endfunction

" vim: ts=2 sw=2 et nowrap
