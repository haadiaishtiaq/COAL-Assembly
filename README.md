# COAL-Assembly

My COAL (Computer Organization and Assembly Language) programs for Fall 2026, written in 16-bit 8086 assembly.

**Name:** Hadia
**Roll No:** 25L-0530
**Section:** BCS-3H

## Assignment 3: Text Viewport Manager

This program builds a small text viewer directly in video memory (segment `0xB800`). It clears the screen, draws a double-line bordered window, and shows my roll number as a title banner in yellow on blue at the top. A short paragraph is then streamed into the window line by line, staying inside the borders with a margin on each side.

The window can scroll its text upward without touching the border or anything outside it. Each line is moved up with `movsw`, and the empty line left at the bottom is blanked with `stosw`. After that, the program searches the text on screen for the word "World" and highlights every match by changing only its attribute byte (blinking yellow on red), so the letters themselves stay the same. Finally, a status bar on row 23 shows how many matches were found, using a stack-based `printNum` routine to print the count.

Every subroutine takes its parameters through the stack, uses `bp` to reach them, and cleans up with `ret n`.

## Tools Used
- NASM (assembler)
- DOSBox (to run the `.com` file)
- Notepad++ (code editor)

## How to Assemble and Run
1. Assemble the program with NASM:
```
   nasm 25L-0530_A3.asm -o a3.com
```
2. Open DOSBox, mount the folder that contains `a3.com`, and run it:
```
   mount C .
   C:
   a3.com
```

DOSBox only understands file names of up to 8 characters, which is why the output file is called `a3.com`.

## Folder Structure
```
COAL-Assembly/
├── README.md
└── Assignment3/
    ├── 25L-0530_A3.asm
    └── screenshots/
        └── output.png
```

## Output Screenshot
![Program output in DOSBox](Assignment3/screenshots/output.png)
