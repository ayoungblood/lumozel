Lumozel
=======

Lumozel is intended to be a controller for live instrumentation, based primarily upon a variety of non-contact sensing methods. Lumozel is designed to be modular, and easily adaptable to other, perhaps non-musical, applications. It is also designed with the goal that it will be able to be played in such a way that someone with relatively little knowledge of musical theory can easily improvise.

Lumozel is a project which has both a hardware component and a software component. This repository contains the development of the software component, which can also be used with other Arduino-based controller hardware setups. Currently, information on the hardware is unavailable, but will be made available as soon as possible.

For more information, see the [wiki](http://github.com/ayoungblood/lumozel/wiki)

Project Status
------

LMMain.pde is currently only barely functional, and should not be used.
LMDebug.pde can be used to a limited extent, although it is under heavy development and a great number of features are transitory, missing, or broken.
The hardware component of the project is in a prototype phase.

Goals
-----

* To create an intuitive controller for live instrumentation.
* To design a method of "hinting" toward the rudiments of musical scale theory.
* To create a codebase that can be adapted toward other applications.
* To use reusable classes in the code, allowing for their use in other contexts.
* To create a software backend that will communicate with a variety of protocols, including OSC and MIDI.
* To eventually create a standalone hardware component that requires no connection to a host computer.
* To keep the entire codebase and schematics of the hardware publicly available.
* To structure the hardware such that it is modular and easily extendable. 
