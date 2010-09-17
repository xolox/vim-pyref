# To-do list

 * Convert `pyref.vim` to an autoload plug-in?
 * Outsource `openurl()` to shell.vim?!
   * **Pros:** I don't want to implement this functionality twice because getting it right takes a bit of work. I could just include the `shell.vim` plug-in with the ZIP archive for `pyref.vim` and be done with it.
   * **Cons:** The `shell.vim` plug-in includes a Windows DLL which means the ZIP archive for `pyref.vim` would also include this DLL, even for users on other platforms. If I were trying a Vim plug-in that did this I might dismiss it out of hand...
