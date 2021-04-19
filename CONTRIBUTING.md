# Contributors Guidelines

A quick overview of how we organize project files, scenes and code.

In short:

* All code is GDScript
* GDScript is similar to python - as such, we observe PEP8 standards where possible
* The project should be organized in Component units - a grouping scene and script

## All code is in GDScript

GDScript is great. Porting to C# would limit portability, while making code more verbose for minimal performance increase.

## GDScript is similar to python - as such, we observe PEP8 standards where possible

PEP8 is a standard for writing readable, consistent Python code. Most of its rules apply equally to GDScript.
Some of the highlights:

* Class names should normally use the CapWords convention.
* Function names should be lowercase, with words separated by underscores as necessary to improve readability.
* Constants are usually defined on a module level and written in all capital letters with underscores separating words. Examples include MAX_OVERFLOW and TOTAL.

Additional Godot-specific naming convention:

* Functions that are meant to be connected to signal emitters should start with an underscore, for example "_on_game_over"

## The project should be organized in Component units - a grouping scene and script

Components are a class-like unit consisting of a scene and a script file. These should be named for the class, and grouped in a directory of the same name. See also naming convention above.
Scripts not loaded as part of a scene (autoload) should be in a directory named Main. There should be as few as possible of these. 
Components that use a *State Machine* to operate, such as the GUI, should have each state as child component. In other words, the GUI component will have subdirectories containing State components.

### Organization of assets
Assets that are not scenes or code should be kept separately, and organized by type first, then optionally divided by use.
For example, music goes in Music, images go in Images, but cut scene music might go in Music/CutScenes.
The reason to not include these in the Component-units with scene and script are twofold:

1. We may be sharing assets among multiple components, and want to avoid needless duplication here
2. We may want to swap out the entire set of assets for another to change "skins" or "themes". 

## Architecture

In general, it is preferred to use engine features rather than custom implementations for common operations. For example:

* Prefer animation nodes over moving gui elements in process() function
* Prefer using a Timer node over measuring time in script, or yielding from create_timer

### Separation of Concerns

Logic and presentation should be separated where possible, and connected by signals where necessary. Subsystems like cutscenes, gui, should be separated to the point where they could be lifted out of the game and placed in another with minimal modification.

