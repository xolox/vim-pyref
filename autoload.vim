" Vim auto-load script
" Author: Peter Odding <peter@peterodding.com>
" Last Change: September 18, 2010
" URL: http://peterodding.com/code/vim/pyref/

let s:script = expand('<sfile>:p:~')

function! xolox#pyref#enable() " {{{1
  command! -buffer -nargs=? PyRef call xolox#pyref#lookup(<q-args>)
  let command = '%s <silent> <buffer> %s %s:call xolox#pyref#at_cursor()<CR>'
  let mapping = exists('g:pyref_mapping') ? g:pyref_mapping : '<F1>'
  execute printf(command, 'nmap', mapping, '')
  if mapping =~ '^<[^>]\+>'
    execute printf(command, 'imap', mapping, '<C-O>')
  endif
endfunction

function! xolox#pyref#at_cursor() " {{{1
  try
    let isk_save = &isk
    let &isk = '@,48-57,_,192-255,.'
    let ident = expand('<cword>')
  finally
    let &isk = isk_save
  endtry
  call xolox#pyref#lookup(ident)
endfunction

function! xolox#pyref#lookup(identifier) " {{{1

  let mirror = s:find_mirror()
  let ident = xolox#trim(a:identifier)

  " Do something useful when there's nothing at the current position.
  if ident == ''
    call xolox#open#url(mirror . '/contents.html')
    return
  endif

  " Escape any dots in the expression so it can be used as a pattern.
  let pattern = substitute(ident, '\.', '\\.', 'g')

  " Search for an exact match of a module name or identifier in the index.
  let indexfile = s:find_index()
  try
    let lines = readfile(indexfile)
  catch
    let lines = []
    call xolox#warning("%s: Failed to read index file! (%s)", s:script, indexfile)
  endtry
  if s:try_lookup(lines, mirror, '^\C\(module-\|exceptions\.\)\?' . pattern . '\t')
    return
  endif

  " Search for a substring match on word boundaries.
  if s:try_lookup(lines, mirror, '\C\<' . pattern . '\>.*\t')
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
      call xolox#open#url(mirror . '/' . url)
      return
    endif
  endfor

  " Search for a substring match in the index.
  if s:try_lookup(lines, mirror, '\C' . pattern . '.*\t')
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
    if s:try_lookup(lines, mirror, pattern)
      return
    endif
  endwhile

  " As a last resort, search all of http://docs.python.org/ using Google.
  call xolox#open#url('http://google.com/search?btnI&q=inurl:docs.python.org/+' . ident)

endfunction

" This list of lists contains [url_format, method_pattern] pairs that are used
" to recognize calls to methods of objects that are one of Python's standard
" types: strings, lists, dictionaries and file handles.
let s:object_methods = [
      \ ['library/stdtypes.html#str.%s', '\C\.\@<=\(capitalize\|center\|count\|decode\|encode\|endswith\|expandtabs\|find\|format\|index\|isalnum\|isalpha\|isdigit\|islower\|isspace\|istitle\|isupper\|join\|ljust\|lower\|lstrip\|partition\|replace\|rfind\|rindex\|rjust\|rpartition\|rsplit\|rstrip\|split\|splitlines\|startswith\|strip\|swapcase\|title\|translate\|upper\|zfill\)$'],
      \ ['tutorial/datastructures.html#more-on-lists', '\C\.\@<=\(append\|count\|extend\|index\|insert\|pop\|remove\|reverse\|sort\)$'],
      \ ['library/stdtypes.html#dict.%s', '\C\.\@<=\(clear\|copy\|fromkeys\|get\|has_key\|items\|iteritems\|iterkeys\|itervalues\|keys\|pop\|popitem\|setdefault\|update\|values\)$'],
      \ ['library/stdtypes.html#file.%s', '\C\.\@<=\(close\|closed\|encoding\|errors\|fileno\|flush\|isatty\|mode\|name\|newlines\|next\|read\|readinto\|readline\|readlines\|seek\|softspace\|tell\|truncate\|write\|writelines\|xreadlines\)$']]

function! s:try_lookup(lines, mirror, pattern) " {{{1
  call xolox#debug("%s: Trying to match pattern %s", s:script, a:pattern)
  let index = match(a:lines, a:pattern)
  if index >= 0
    let url = split(a:lines[index], '\t')[1]
    call xolox#open#url(a:mirror . '/' . url)
    return 1
  endif
endfunction

function! s:find_mirror() " {{{1
  if exists('g:pyref_mirror')
    return g:pyref_mirror
  else
    let local_mirror = '/usr/share/doc/python2.6/html'
    if isdirectory(local_mirror)
      return 'file://' . local_mirror
    else
      return 'http://docs.python.org'
    endif
  endif
endfunction

function! s:find_index() " {{{1
  if exists('g:pyref_index')
    let index = g:pyref_index
  elseif xolox#is_windows()
    let index = '~/vimfiles/misc/pyref_index'
  else
    let index = '~/.vim/misc/pyref_index'
  endif
  let abspath = fnamemodify(index, ':p')
  if !filereadable(abspath)
    let msg = "%s: The index file doesn't exist or isn't readable! (%s)"
    call xolox#warning(msg, s:script, index)
    return
  endif
  return abspath
endfunction

" vim: ts=2 sw=2 et nowrap
