Files are saved as .cdl files. You can open these in Notepad if you want.
While developer_mode is true(only changable in code), press U to switch between gameplay and editor mode.
Editor mode locks gameplay inputs and allows you to do everything described here.

up/down/left/right moves the camera. Holding Shift key will make the camera pan faster. 
- and = control camera zoom. _ (shift and minus) will reset it to 1,1. 

Ctrl+S to save current level.
Ctrl+L to load current level.
The upper textbox changes which file name you're editing, saving or loading. This will be referred to as current level or var currentlevel in code.
When the textbox is in focus, keyboard commands become unavailable. To unfocus the textbox, press Enter or ESC.
Enter sets the currentlevel var to the textbox value, ESC does not.  Note that clicking away from the textbox does NOT unfocus the textbox.
The middle textbox changes the extents of the current level. Make sure to use the format [extentX],[extentY] or else the interpreter will crash. Newly genned levels will use the same extents.
The lower textbox sets the filename the next door you'll be placing down will switch to. 


Press B to switch brush type between tile brush and unit brush. 
0 to 9 number inputs will let you switch what you'll be drawing with the brush. 0 is the eraser.
Shift + number will access cards 10 through 19.
Ctrl+ number will access cards 20 through 29. Ctrl+0 is an empty tile.
The small card in the UI shows what you will draw.

Right click will hide a tile, and middle click will unhide it. This is visually buggy during editing, but no problems should occur during real gameplay.