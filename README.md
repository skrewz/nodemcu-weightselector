# nodemcu-weightselector
A (very) simple (yet somehow overcomplicated) button to select who stepped on a scale.

# Submodules beware

This repo has submodules, notably [nodemcu-scaffold](https://github.com/skrewz/nodemcu-scaffold), and chained therefrom, [nodemcu-libs](https://github.com/skrewz/nodemcu-libs).

You should thus **clone with git's `--recursive` flag**.

# Getting started

This example is fairly self-contained. It ought to be possible to simply run `make upload` and issue a `node.flashreload("lfs.img")` from within the serial console, referring to [nodemcu-scaffold's README](https://github.com/skrewz/nodemcu-scaffold/blob/master/README.md). Of course, it'll fail horribly at connecting to my MQTT setup, etc.


# Usage

This is pretty specific to my use case. Two people (`user1` and `user2`) have each their side of a flipbutton, and an independent system publishes a raw float value onto `datainput/bathroom/scale/raw`.

This software's only goal in life is to interpret this relative to the state of the button, and re-publish accordingly. That's a fair bit of work for something so trivial.
