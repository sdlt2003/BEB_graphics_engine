
# mg library #

This is the source code of `mg`, a toy graphical engine for the
*"Bistaraketa eta Ingurune Birtualak/Visualización y Entornos
Virtuales"* class of the Faculty of Informatics in San
Sebastian/Donostia.

## LICENSE (DO NOT MAKE PUBLIC) ##

The `mg` graphic engine is for educational purposes **and can not be
made public by any means**. **You will receive a grade of zero (0)**
if you put this software in a public repository accessible to others
(such as github or bitnucket).

## Instalation ##

the following command would do in on an Ubuntu system:

```
sudo apt-get install build-essential cmake freeglut3-dev libglew-dev
```

## Build the project (Recommended)

`mg` uses the CMAKE suite to compile the project. In CMAKE, you have
to perform two steps:

- Perform this command **only once**

```
cmake CMakeLists.txt
```

this will create the appropriate `Makefile` files, as well as the
`compile_commands.json` file, which is used by many editors to enable
auto-completion facilities.

- Afterwards, you can build the project anytime by running:

```
make
```

this will create the main executables of the project, namely
`browser_gobj` and `browser`.

- you can clean the project running

```
make clean
```

### Build using makefile (Only use this option if the above CMAKE method does not work) ###

clean the project


- Build the project running:

```
make -f makefile.orig
```

- you can clean the project running

```
make -f makefile.orig distclean
make -f makefile.orig clean
```

## Run the project

Just run the following:

```
./browser
```


Sometimes you have to uncomment this line in `Browser/browser.c`
(around line 446):

```
  // Uncomment following line if you have problems initiating GLEW
  //
-  // glewExperimental = GL_TRUE;
+  glewExperimental = GL_TRUE;
```

## Keys

The following keybindings are available:

| Key               | Action                         |
|:------------------|:-------------------------------|
| `ESC`             | exit                           |
| `arrow keys`      | move camera                    |
| `pg up / pg down` | camera advance / go back       |
| `Home`            | go to default location         |
| `alt-c`           | print camera                   |
| `alt-f`           | change to/from cull camera     |
|                   |                                |
| `a`               | rotate object left (Y)         |
| `d`               | rotate object right (-Y)       |
| `w`               | rotate object down (X)         |
| `x`               | move object up (-X)            |
| `q/Q`             | spin object left/right         |
| `i/I`             | move object along local X (-X) |
| `o/O`             | move object along local Y (-Y) |
| `p/P`             | move object along local Z (-Z) |
| `alt-1`           | go to parent node              |
| `alt-2`           | go to first child node         |
| `alt-3`           | go to next sibling             |
|                   |                                |
| `0`               | animate                        |
| `1 .. 7`          | switch light on/off            |
| `.`               | change walk/fly                |
| `f`               | increase fovy (zoom in)        |
| `F`               | decrease fovy (zoom out)       |
| `alt-C`           | toggle collisions              |
|                   |                                |
| `l`               | set all lights                 |
| `L`               | disable all lights             |
| `s`               | enable shading                 |
| `S`               | disable shading                |
| `z`               | enable z-buffer                |
| `Z`               | disable z-buffer               |
| `alt-a`           | toggle line aliasing on/off    |
| `alt-b`           | draw BBox-es                   |
|                   |                                |
| `alt-0`           | take snapshot                  |
| `alt-i`           | print registered images        |
| `alt-l`           | print registered lights        |
| `alt-m`           | print registered materials     |
| `alt-p`           | print projection trfm          |
| `alt-S`           | print shaders                  |
| `alt-s`           | print renderState              |
| `alt-t`           | print registered textures      |
| `alt-v`           | print modelview trfm           |
