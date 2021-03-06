Lumozel
=======

The Lumozel is a musical controller for live instrumentation based on non-contact sensing. It is played with the hands, and notes are triggered by passing the hands through a laser-phototransistor detector. Pitch is determined by the position of the hands along the horizontal axis. The Lumozel hardware is made to be highly modular and expandable, and the software allows for a variety of configurations. The software lets the user control a number of parameters, and handles communication with other devices (via MIDI, OSC, etc).

Lumozel is a project which has both a hardware component and a software component. This repository contains the development of the software component, which can also be used with other [Arduino](http://www.arduino.cc/)-based controller hardware setups. Currently, plans and schematics for the hardware are unavailable, but will be made available as soon as possible.

Additionally, plans are underway for a new client-device communication design that is both easier to adapt to a number of other sensors and easier to get working. Currently, setting up communication between the hardware and a computer  is not ideal, as it requires installation of a few drivers and some command-line directory whacking.

The main software client (there are in fact several different flavors) is written in [Processing](http://processing.org/).

#### **Please visit the [wiki](http://github.com/ayoungblood/lumozel/wiki) for more information including all the hardware designs.**

A SketchUp mockup of the controller prototype chassis:
![lumozel_chassis.png](https://raw.github.com/wiki/ayoungblood/lumozel/lumozel_chassis.png)

Picture of the initial build of the hardware, with temporary wooden end covers (later replaced by plexiglas):
![lumozel_unfinished.jpg](https://raw.github.com/wiki/ayoungblood/lumozel/lumozel_unfinished.jpg)

Project Status
------

LMDebug.pde is working! It is a basic interface, and only offers MIDI output, but it is stable and seems to work excellently.
LMMain.pde is still under development, and is very unstable. It may prove to be impossible to achieve proper operating speed with all the code running computer-side in Java. It may prove much more feasible to do the detection math on the Arduino itself, and then communicate with a native application on the computer to provide UI.
The hardware component of the project is finished.
The entire codebase of the project should not be considered as a release, as it still has many bugs. However, many of the utilities are fully functional and quite handy.


Goals
-----

* To create an intuitive controller for live instrumentation.
* To design a controller that enables users with little knowledge of music theory to improvise easily.
* To create a codebase that can be adapted toward other applications.
* To use reusable classes in the code, allowing for their use in other contexts.
* To create a software backend that will communicate with a variety of protocols, including OSC and MIDI.
* To eventually create a standalone hardware component that requires no connection to a host computer.
* To keep the entire codebase and schematics of the hardware publicly available.
* To structure the hardware such that it is modular and easily extendable.

See Also
--------

[Dropsway](http://dropsway.com) - Dropsway seeks to make music and improvisation easily graspable by those unfamiliar with music theory. Dropsway was founded by my good friend and colleague Joseph Johnston. In the future, I hope that the Lumozel can be used as a "Dropsway-compatible" music interface.

