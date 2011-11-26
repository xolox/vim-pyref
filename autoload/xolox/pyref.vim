" Vim auto-load script
" Author: Peter Odding <peter@peterodding.com>
" Last Change: November 26, 2011
" URL: http://peterodding.com/code/vim/pyref/

let g:xolox#pyref#version = '0.7.8'
let s:script = expand('<sfile>:p:~')

function! xolox#pyref#enable() " {{{1
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

function! xolox#pyref#complete(arglead, cmdline, cursorpos) " {{{1
  let entries = map(s:read_index(), 'matchstr(v:val, ''^\S\+'')')
  let pattern = xolox#misc#escape#pattern(a:arglead)
  call filter(entries, 'v:val =~ pattern')
  if len(entries) > &lines
    let entries = entries[0 : &lines - 1]
    call add(entries, '...')
  endif
  return entries
endfunction

function! xolox#pyref#lookup(identifier) " {{{1

  let ident = xolox#misc#str#trim(a:identifier)

  " Do something useful when there's nothing at the current position.
  if ident == ''
    call s:show_match('http://docs.python.org/contents.html')
    return
  endif

  " Escape any dots in the expression so it can be used as a pattern.
  let pattern = substitute(ident, '\.', '\\.', 'g')
  let lines = s:read_index()

  " Search for an exact match of a module name or identifier in the index.
  if s:try_lookup(lines, '^\C\(module-\|exceptions\.\)\?' . pattern . '\t')
    return
  endif

  " Search for a substring match on word boundaries.
  if s:try_lookup(lines, '\C\<' . pattern . '\>.*\t')
    return
  endif

  " Try to match a method name of one of the standard Python types: strings,
  " lists, dictionaries and files (not exactly ideal but better than nothing).
  for [url, method_pattern] in [
          \ ['library/stdtypes.html#str.%s', '\C\.\@<=\(capitalize\|center\|count\|decode\|encode\|endswith\|expandtabs\|find\|format\|index\|isalnum\|isalpha\|isdigit\|islower\|isspace\|istitle\|isupper\|join\|ljust\|lower\|lstrip\|partition\|replace\|rfind\|rindex\|rjust\|rpartition\|rsplit\|rstrip\|split\|splitlines\|startswith\|strip\|swapcase\|title\|translate\|upper\|zfill\)$'],
          \ ['tutorial/datastructures.html#more-on-lists', '\C\.\@<=\(append\|count\|extend\|index\|insert\|pop\|remove\|reverse\|sort\)$'],
          \ ['library/stdtypes.html#dict.%s', '\C\.\@<=\(clear\|copy\|fromkeys\|get\|has_key\|items\|iteritems\|iterkeys\|itervalues\|keys\|pop\|popitem\|setdefault\|update\|values\)$'],
          \ ['library/stdtypes.html#file.%s', '\C\.\@<=\(close\|closed\|encoding\|errors\|fileno\|flush\|isatty\|mode\|name\|newlines\|next\|read\|readinto\|readline\|readlines\|seek\|softspace\|tell\|truncate\|write\|writelines\|xreadlines\)$']]
    let method = matchstr(ident, method_pattern)
    if method != ''
      if url =~ '%s'
        let url = printf(url, method)
      endif
      call s:show_match('http://docs.python.org/' . url)
      return
    endif
  endfor

  " Search for a substring match in the index.
  if s:try_lookup(lines, '\C' . pattern . '.*\t')
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
    if s:try_lookup(lines, pattern)
      return
    endif
  endwhile

  " As a last resort, try Google's "I'm Feeling Lucky" search.
  call xolox#misc#open#url('http://google.com/search?btnI&q=python+' . ident)

endfunction

function! s:try_lookup(lines, pattern) " {{{1
  call xolox#misc#msg#debug("pyref.vim %s: Trying to match pattern %s", g:xolox#pyref#version, a:pattern)
  let index = match(a:lines, a:pattern)
  if index >= 0
    let url = split(a:lines[index], '\t')[1]
    call s:show_match(url)
    return 1
  endif
endfunction

function! s:show_match(url) " {{{1
  let python_docs = xolox#misc#option#get('pyref_python')
  let django_docs = xolox#misc#option#get('pyref_django')
  let url = a:url
  if url =~ '^http://docs\.python\.org/' && isdirectory(python_docs)
    let url = substitute(url, '^http://docs\.python\.org', 'file://' . python_docs, '')
  elseif url =~ '^http://docs\.djangoproject\.com/en/1\.1/' && isdirectory(django_docs)
    let url = substitute(url, '/#', '.html#', '')
    let url = substitute(url, '^http://docs\.djangoproject\.com/en/1\.1', 'file://' . django_docs, '')
  endif
  call xolox#misc#open#url(url)
endfunction

function! s:find_index() " {{{1
  let abspath = fnamemodify(g:pyref_index, ':p')
  if !filereadable(abspath)
    let msg = "pyref.vim %s: The index file doesn't exist or isn't readable! (%s)"
    call xolox#misc#msg#warn(msg, g:xolox#pyref#version, index)
    return
  endif
  return abspath
endfunction

function! s:read_index() " {{{1
  let indexfile = s:find_index()
  try
    return readfile(indexfile)
  catch
    call xolox#misc#msg#warn("pyref.vim %s: Failed to read index file! (%s)", g:xolox#pyref#version, indexfile)
    return []
  endtry
endfunction

" vim: ts=2 sw=2 et nowrap
