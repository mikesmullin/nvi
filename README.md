# Very opinionated Node.JS VI clone

my dream collaborative editor:

a vim clone

except just taking the best parts of vim
 and making them better
   line numbers
   buffers
   macros
   modes
   block edit
   highly configurable via modern programming (javascript or coffeescript)
   plugins (by default does almost nothing)
     nerdtree
     ctags
     object browser









http://www.cs.tut.fi/~jkorpela/chars/c0.html

but not a vim clone
 ability to switch into a notepad-like n00b mode

with support for collaborative editing

using multi-colored cursors
  and the shortest possible network language to communicate changes


e.g. the collab feature should have:
  follow mode
  multiple cursors
  multiple colored cursors
  colored fg/background text matching users who edited
  support for syntax highlighting

  only transmit files when they are needing to be opened, as they need to be opened,
    and only the parts of the file that need to be rendered

  detect changes to files on disk using mtime
    and auto-sync those to the group

  detect an out-of-sync state (what is hash of chars on line RAND characters RANDx - RANDY?) if its not the same then resend the document




later i would add support for:

  coffeescript
    syntax highlighting
    type inference
    code completion







there's only one buffer per file
a buffer does not have to be a file
multiple views can share a buffer
a view can have one or more cursor

buffer is closely tied to the view
  it only fetches enough bytes to fill the view
it grabs chunks equal to the current view's line in bytes

buffer is aware of how many views are using it
  before it seeks the file for more data,
  it determines which stripes are being used across all views
  it considers overlapping views
  and only fetches each line it needs once, in order from first byte to last byte in file
  and and when it fetches an area of the buffer that is overlapping in the view render
  it updates both views not one then again for the other

so views have: w, x, buf_offset_y, cursors: pos: x:,  y:

cursors have: user_id, color, pos: { x:, y: },

users have name and color

cursors are relative to their views






for my collaborative mode, we'll connect at first over a regular tcp socket
there will be one instance in a 'host' mode
and zero or more instances in a 'guest' mode
the guests will not receive mirror copies of the entire directory
the host will share the directory skeleton for the current directory
  and recursively but only upon a watch request
    watchers will receive push notification from the host (e.g. file added or removed under watchdir)

any file a client requests to open, the client, and all other clients will be aware of
  client will request the file from host
  host will broadcast to other clients that the client has opened the file
  and when it has closed the file

host will spoon-feed data to the clients like a buffer would
  so the clients only get the data they need to look at that moment

also, diffs are only broadcasted within the context of the all clients collective views, as well

if a file changes on the host system
  then we only broadcast that change if it is within the overlapped views of clients


this is very similar to how ssh vim tmux session would go, except we now have multiple cursors

cursor position updates will be notified (client->host) and rebroadcasted (others) with a throttle
but diffs will not be based on cursor position and exact keypress matches
  they will be actual patch diffs in a minimalist format

and what about binary files?
  these will not attempt to be diffed
  on modification, the latest (mtime) copy overrides everyone else's
    (clients will need to have a filesystem mtime watch too)
    the process for updating a binary file as a client would be:
      connect
      right-click > download the file or folder
      modify the file locally
      mtime inotify triggers guests to receive the bin file as well
      any new files created (atime) get auto-shared to the host

      client can be asked to resolve merge conflicts

its basically like a rapid git session

except i don't like all the assumptions made above re. bin files
  i think if the client wants to share a new file, it should be explicit, at least for now
    and let's see if it becomes a hassle
  or if a client wants to modify an existing binfile, it should also be explicit
    because in reality these will change a lot (e.g. during a photoshop editing session)
    and we really only care about the final result
    and most likely the group will want to talk it over and approve it before accepting it anyway


it would be cool if it had git support so that team commits could be saved with attribution for the authors involved when the commit was made
  and so the commits only happened on the host side
  same with pushes

NO that silly git diff shit is not applicable; it doesn't resolve changes on the same line
  so i need my own
  i think instead i will just translate the cursor/block edit operations to binary opcodes

  basically whatever you can do with a block, there's an opcode for that
    so shift selection one character right, shift selection one character left (unlikely use case)
    duplicate selection up/down
    delete selection
    insert before selection
    insert after selection
    move selection up/down
    backspace/delete x characters
    insert "literal" characters; assume we are working on an ascii file always
      pretty confident that's a safe assumption; collaborative editing binary files
      will have their own app and experience
    move cursor absolute x, y or relative -x, -y


when syncing hydrabuffers / views
  clients will write changes to disk, without filler
  as the view scrolls up/down the file will be prepended/appended
  until the file is complete

  if a user changes a file outside of nvim which they don't have a complete dataset for
   hmm

  ok getting too fancy here / prematurely optimizing / overengineering
  let's K.I.S.S.

  we'll transfer the whole ascii file to clients as they request to view it
  and then we'll work to keep it in sync from there
  its really not that much data to transfer

  except am i solving anything the other way around?
  a lot of times sync errors happen while users are editing in the areas
  we aren't currently watching for changes in

  i kind of like my ssh-vim-like approach

  ok so in that vain, the client does not buffer or store ANY data locally
  this way it cannot possibly go out of sync
  if it does, they just close/reopen the file to get back in sync
  sync will happen on a per-view basis

  same as if you opened a file and someone changed it while you were reading it

  this is also good because it functionally reinforces the idea of
  requiring clients to check-in new files or binary file changes
  by issuing special commands to have them imported to the host

  and then with that i can refuse to render binary files altogether
  just display an error like 'binary files unsupported; utf8 text only'

  so if someone wanted to edit a binary file in this flow, they would
  have to issue a special command to fetch the binfile
  then edit it locally
  then issue a special command to upload the binfile
  thus greatly reducing incidental sync errors
  and unnecessary data transfer






for a view statusbar just show:

relative path, bold filename
dont show line endings like 'unix | mac | win' thats pointless
instead highlight whitespace aggressively and with favoritism for unix
show percentage of file remaining
and cursor x:y pos


show treeview directory structure
  i'll have to implement this too because it needs remote support

the modes i'll implement will be:
  NORMAL except i'll call it COMBO
  INSERT except i'll call it NORMAL
  REPLACE i'll keep this the same
  V-LINE except i'll call it LINE-BLOCK
  V-BLOCK exept i'll call it BLOCK



treat views like a tiling window manager
create a Tab object like tmux-style tabs
  tabs will have user's names in collab mode

so it starts with one tab and one view
you can never have fewer than one view open
if you do its just resetting the file to an untitled in-memory buffer

