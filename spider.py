#!/usr/bin/python

# Copyright 2010 Peter Odding <peter@peterodding.com>
# This program is licensed under the MIT license.

# This Python script indexes a local/remote tree of Python HTML documentation
# and creates/updates an index file that maps identifiers to their associated
# URL in the documentation. Each line starts with a keyword or an identifier
# followed by a tab and ends with the associated URL. The index file is used by
# the pyref.vim plug-in for Vim to provide context sensitive documentation.
# For more information visit http://peterodding.com/code/vim/pyref/

import os
import re
import sys
import time
import urllib

DEBUG = False

indexfile = os.path.expanduser('~/.vim/misc/pyref_index')
scriptname = os.path.split(sys.argv[0])[1]

def message(text, *args):
  text = '%s: ' + text + '\n'
  text %= (scriptname,) + args
  sys.stderr.write(text)

def verbose(text, *args):
  if DEBUG:
    message(text, *args)

def error(text, *args):
  message(text, *args)
  sys.exit(1)

# Make sure the Beautiful Soup HTML parser is available.
try:
  from BeautifulSoup import BeautifulSoup
except ImportError:
  error("""You'll need to install the Beautiful Soup HTML parser. If you're running
Debian/Ubuntu try the following: sudo apt-get install python-beautifulsoup""")

# Make sure the user provided a location to spider.
if len(sys.argv) < 2:
  error("Please provide the URL to spider as a command line argument.")

# Validate/munge the location so it points to an index.html page.
root = sys.argv[1].replace('file://', '')
if not root.startswith('http://'):
  root = os.path.realpath(root)
  if os.path.isdir(root):
    page = os.path.join(root, 'index.html')
    if os.path.isfile(root):
      root = page
    else:
      error("Failed to determine index page in %r!", root)
  elif not os.path.isfile(root):
    error("The location %r doesn't seem to exist!", root)
  root = 'file://' + root
first_page = root
root = os.path.split(root)[0]

# If the index file already exists, read it so we can merge the results.
anchors = {}
if os.path.isfile(indexfile):
  message("Reading existing entries from %s", indexfile)
  handle = open(indexfile)
  nfiltered = 0
  for line in handle:
    anchor, target = line.strip().split('\t')
    if target.startswith(root):
      nfiltered += 1
    else:
      anchors[anchor] = target
  handle.close()
  message("Read %i and filtered %i entries", len(anchors), nfiltered)

# Start from the given location and collect anchors from all related pages.
queued_pages = [first_page]
visited_pages = {}
while queued_pages:
  location = queued_pages.pop()
  # Fetch the selected page.
  try:
    verbose("Fetching %r", location)
    handle = urllib.urlopen(location)
    contents = handle.read()
    handle.close()
    if not location.startswith('file://'):
      # Rate limit fetching of remote pages.
      time.sleep(1)
  except:
    verbose("Failed to fetch %r!", location)
    continue
  # Mark the current page as visited so we don't fetch it again.
  visited_pages[location] = True
  # Parse the page's HTML to extract links and anchors.
  verbose("Parsing %r", location)
  tagsoup = BeautifulSoup(contents)
  npages = 0
  for tag in tagsoup.findAll('a', href=True):
    target = tag['href']
    # Strip anchors and ignore anchor-only links.
    target = re.sub('#.*$', '', target)
    if target:
      # Convert the link target to an absolute, canonical URL?
      if not re.match(r'^\w+://', target):
        target = os.path.join(os.path.split(location)[0], target)
        scheme, target = target.split('://')
        target = scheme + '://' + os.path.normpath(target)
      # Ignore links pointing outside the root URL and don't process any page more than once.
      if target.startswith(root) and target not in visited_pages and target not in queued_pages:
        queued_pages.append(target)
        npages += 1
  nidents = 0
  for tag in tagsoup.findAll(True, id=True):
    anchor = tag['id']
    if anchor not in anchors:
      anchors[anchor] = '%s#%s' % (location, anchor)
      nidents += 1
    else:
      verbose("Ignoring identifier %r duplicate target %r!", anchor, location)
  message("Extracted %i related pages, %i anchors from %r..", npages, nidents, location)

message("Scanned %i pages, extracted %i anchors", len(visited_pages), len(anchors))

# Write the tab delimited list of (keyword, URL) pairs to the index file.
message("Writing index file %r", indexfile)
handle = open(indexfile, 'w')
bytes_written = 0
for anchor in sorted(anchors.keys()):
  line = '%s\t%s\n' % (anchor, anchors[anchor])
  handle.write(line)
  bytes_written += len(line)
handle.close()
message("Done, wrote %i KB to %r", bytes_written / 1024, indexfile)

# vim: ts=2 sw=2 et
