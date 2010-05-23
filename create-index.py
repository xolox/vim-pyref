#!/usr/bin/python

# Copyright 2010 Peter Odding <peter@peterodding.com>
# This program is licensed under the MIT license.

# This program indexes the keywords and identifiers in the Python language and
# library reference HTML documentation and creates an index file with keywords
# and their associated URL. Each line starts with a keyword or an identifier
# followed by a tab and ends with the associated URL. The index file is used
# by the pyref.vim plug-in for Vim to provide context sensitive documentation.

# If you have the HTML documentation available on your hard drive (e.g. by
# installing the Ubuntu package `python2.6-doc') then I recommend that you
# index those files by setting the "local_dir" variable below, otherwise
# http://docs.python.org/library/ will be indexed which can take a while.

local_dir = '/usr/share/doc/python2.6/html/'
docs_mirror = 'http://docs.python.org/'
index_file = '~/.vimpythonindex'

# You shouldn't need to change anything below here.

import os, re, time, urllib

# If local documentation is available then use that,
# otherwise default to the latest online documentation.
selected_docs = os.path.isdir(local_dir) and ('file://' + local_dir) or docs_mirror

def getpage(url):
  try:
    handle = urllib.urlopen(url)
    contents = handle.read().decode('utf-8')
    handle.close()
    if not url.startswith('file://'):
      # Rate-limit the number of connections to http://python.org/
      time.sleep(1)
    return contents
  except:
    print "\rFailed to get %s!" % url
    return ''

pages = []

# Prepare to index the language and library references.
for directory in 'reference', 'library':
  directory = os.path.join(selected_docs, directory)
  url = os.path.join(directory, 'index.html')
  pattern = '<li class="toctree-l[12]"><a class="reference external" href="([^"]+)'
  print "\rScanning %s" % url,
  for target in re.findall(pattern, getpage(url)):
    # Strip fragment identifiers.
    target = re.sub('#.*$', '', target)
    # Convert relative to absolute URLs.
    if target.startswith('/') or not target.startswith('http://'):
      target = os.path.join(directory, target)
    if target not in pages:
      pages.append(target)

# Create a dictionary with all anchors in the documentation.
anchors = {}
duplicates = 0
for page in sorted(pages):
  print "\rIndexing %s" % page,
  for anchor in re.findall('\sid="([^"]+)">', getpage(page)):
    url = page + '#' + anchor
    if anchor in anchors:
      # sys.stderr.write("\rConflicting anchors! (%s and %s)\n" % (anchors[anchor], url))
      duplicates += 1
    anchors[anchor] = url

print "\nIndexed %i pages, %i anchors (%i duplicates)" % (len(pages), len(anchors), duplicates)

# Finally write a tab-delimited list of (keyword, URL) pairs to the index file.
index_file = os.path.expanduser(index_file)
print "Writing index file %s.. " % index_file,
handle = open(index_file, 'w')
bytes_written = 0
for keyword in sorted(anchors.keys()):
  url = anchors[keyword]
  # Convert absolute to relative URLs.
  if url.startswith(selected_docs):
    url = url[len(selected_docs):]
  line = '%s\t%s\n' % (keyword, url)
  handle.write(line)
  bytes_written += len(line)
handle.close()
print "OK, wrote", bytes_written / 1024, "KB"

# vim: ts=2 sw=2 et
