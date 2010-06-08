" Vim plug-in
" Maintainer: Peter Odding <peter@peterodding.com>
" Last Change: June 8, 2010
" URL: http://peterodding.com/code/vim/pyref
" License: MIT
" Version: 0.5

" Support for automatic update using the GLVS plug-in.
" GetLatestVimScripts: 3104 1 :AutoInstall: pyref.zip

" Don't source the plug-in when its already been loaded or &compatible is set.
if &cp || exists('loaded_pyref')
  finish
endif

" Configuration defaults. {{{1

" Use a script-local function to define the configuration defaults so that we
" don't pollute Vim's global scope with temporary variables.

function! s:CheckOptions()
  if !exists('g:pyref_mapping')
    let g:pyref_mapping = '<F1>'
  endif
  if !exists('g:pyref_mirror')
    let local_mirror = '/usr/share/doc/python2.6/html'
    if isdirectory(local_mirror)
      let g:pyref_mirror = 'file://' . local_mirror
    else
      let g:pyref_mirror = 'http://docs.python.org'
    endif
  endif
  if !exists('g:pyref_index')
    if has('win32') || has('win64')
      let g:pyref_index = '~/vimfiles/pyref/index'
    else
      let g:pyref_index = '~/.vim/pyref/index'
    endif
  endif
  if !filereadable(fnamemodify(g:pyref_index, ':p'))
    let msg = "pyref.vim: The index file doesn't exist or isn't readable! (%s)"
    echoerr printf(msg, g:pyref_index)
    return 0 " Initialization failed.
  endif
  if !exists('g:pyref_browser')
    if has('win32') || has('win64')
      " On Windows the default web browser is accessible using the START command.
      let g:pyref_browser = 'CMD /C START ""'
    else
      " On UNIX we decide whether to use a CLI or GUI web browser based on
      " whether the $DISPLAY environment variable is set.
      if $DISPLAY == ''
        let known_browsers = ['lynx', 'links', 'w3m']
      else
        " Note: Don't use `xdg-open' here, it ignores fragment identifiers :-S
        let known_browsers = ['gnome-open', 'firefox', 'google-chrome', 'konqueror']
      endif
      " Otherwise we search for a sensible default browser.
      let search_path = substitute(substitute($PATH, ',', '\\,', 'g'), ':', ',', 'g')
      for browser in known_browsers
        " Use globpath()'s third argument where possible (since Vim 7.3?).
        try
          let matches = split(globpath(search_path, browser, 1), '\n')
        catch
          let matches = split(globpath(search_path, browser), '\n')
        endtry
        if len(matches) > 0
          let g:pyref_browser = matches[0]
          break
        endif
      endfor
      if !exists('g:pyref_browser')
        let msg = "pyref.vim: Failed to find a default web browser!"
        echoerr msg . "\nPlease set the global variable `pyref_browser' manually."
        return 0 " Initialization failed.
      endif
    endif
  endif
  return 1 " Initialization successful.
endfunction

if s:CheckOptions()
  " Don't reload the plug-in once its been successfully initialized.
  let loaded_pyref = 1
else
  " Don't finish sourcing the script when there's no point.
  finish
endif

" Automatic command to define key-mapping. {{{1

augroup PluginPyRef
  autocmd! FileType python call s:DefineMappings()
augroup END

function! s:DefineMappings() " {{{1
  let command = '%s <silent> <buffer> %s %s:call <Sid>PyRef()<CR>'
  " Always define the normal mode mapping.
  execute printf(command, 'nmap', g:pyref_mapping, '')
  " Don't create the insert mode mapping when "g:pyref_mapping" has been
  " changed to something like K because it'll conflict with regular input.
  if g:pyref_mapping =~ '^<[^>]\+>'
    execute printf(command, 'imap', g:pyref_mapping, '<C-O>')
  endif
endfunction

function! s:PyRef() " {{{1

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

  " Search for an exact match of a module name or identifier in the index.
  let indexfile = fnamemodify(g:pyref_index, ':p')
  try
    let lines = readfile(indexfile)
  catch
    let lines = []
    echoerr "pyref.vim: Failed to read index file! (" . indexfile . ")"
  endtry
  if s:JumpToEntry(lines, '^\C\(module-\|exceptions\.\)\?' . pattern . '\t')
    return
  endif

  " Search for a substring match on word boundaries.
  if s:JumpToEntry(lines, '\C\<' . pattern . '\>.*\t')
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
  if s:JumpToEntry(lines, '\C' . pattern . '.*\t')
    return
  endif

  " Split the expression on all dots and search for a progressively smaller
  " suffix to resolve object attributes like "self.parser.add_option" to
  " global identifiers like "optparse.OptionParser.add_option". This relies
  " on the uniqueness of the method names in the standard library.
  let parts = split(ident, '\.')
  while len(parts) > 1
    call remove(parts, 0)
    let pattern = '\C\<' . join(parts, '\.') . '$'
    if s:JumpToEntry(lines, pattern)
      return
    endif
  endwhile

  " As a last resort, search all of http://docs.python.org/ using Google.
  call s:OpenBrowser('http://google.com/search?btnI&q=inurl:docs.python.org/+' . ident)

endfunction

" This list of lists contains [url_format, method_pattern] pairs that are used
" to recognize calls to methods of objects that are one of Python's standard
" types: strings, lists, dictionaries and file handles.
let s:object_methods = [
      \ ['library/stdtypes.html#str.%s', '\C\.\@<=\(capitalize\|center\|count\|decode\|encode\|endswith\|expandtabs\|find\|format\|index\|isalnum\|isalpha\|isdigit\|islower\|isspace\|istitle\|isupper\|join\|ljust\|lower\|lstrip\|partition\|replace\|rfind\|rindex\|rjust\|rpartition\|rsplit\|rstrip\|split\|splitlines\|startswith\|strip\|swapcase\|title\|translate\|upper\|zfill\)$'],
      \ ['tutorial/datastructures.html#more-on-lists', '\C\.\@<=\(append\|count\|extend\|index\|insert\|pop\|remove\|reverse\|sort\)$'],
      \ ['library/stdtypes.html#dict.%s', '\C\.\@<=\(clear\|copy\|fromkeys\|get\|has_key\|items\|iteritems\|iterkeys\|itervalues\|keys\|pop\|popitem\|setdefault\|update\|values\)$'],
      \ ['library/stdtypes.html#file.%s', '\C\.\@<=\(close\|closed\|encoding\|errors\|fileno\|flush\|isatty\|mode\|name\|newlines\|next\|read\|readinto\|readline\|readlines\|seek\|softspace\|tell\|truncate\|write\|writelines\|xreadlines\)$']]

function! s:JumpToEntry(lines, pattern) " {{{1
  if &verbose
    echomsg "pyref.vim: Trying to match" string(a:pattern)
  endif
  let index = match(a:lines, a:pattern)
  if index >= 0
    let url = split(a:lines[index], '\t')[1]
    call s:OpenBrowser(g:pyref_mirror . '/' . url)
    return 1
  endif
  return 0
endfunction

function! s:OpenBrowser(url) " {{{1
  let browser = g:pyref_browser
  if browser =~ '\<\(lynx\|links\|w3m\)\>'
    execute '!' . browser fnameescape(a:url)
  else
    if browser !~ '^CMD /C START'
      let browser = shellescape(browser)
    endif
    call system(browser . ' ' . shellescape(a:url))
  endif
  if v:shell_error && browser !~ '^CMD /C START'
    " When I tested this on Windows Vista the START command worked just fine
    " but it always exited with a status code of 1. Therefor the status code
    " of the START command is now ignored.
    let message = "pyref.vim: Failed to execute %s! (status code %i)"
    echoerr printf(message, browser, v:shell_error)
    return 0
  endif
  return 1
endfunction

" vim: ts=2 sw=2 et nowrap
