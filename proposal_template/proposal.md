---
title: Sea's 341, Captain Hook's Black Pearl
---

![Image of the game sea of thieves](images/sea_of_thieves.jpg){width="900px"}

# Summary

The goal of the project is to create an interactive scene of a boat floating in the ocean. More specifically, we want to be able to have an infinite ocean, dynamically change the weather conditions (calm sea vs storm), steer the boat and ideally have realistic water-boat interactions, such as wave generation and water spashes.


# Goals and Deliverables

Describe the goals of your project here, following the
[project instructions](https://courses-gcm.epfl.ch/icg2023/project/instructions/).

Core project:

 * Wave generation: height and frequency of waves, simulating different waves under various weather conditions (make interactive).
 * Boat that you can steer.

The final scene will be something similar to the above picture and will be interactive boat movement and different wave generation.

Extras:

 * Sun reflections on waves.
 * White water foam on waves, that depend on the weather condition (research on formulas)
 * Boids (old technique for bird simulations)
 * The realistic boat-water interaction.
 * Weather simulation: rains, cloudy, lighting

 ![Boat-water interaction](images/boat_with_waves.jpg){width="500px"}


# Schedule

All members will work on different parts of the project, the allocation is just primary member that may take the heavy lift of certain goal.

## Week 1: 24-30 April

 * Project proposal review, change project deliverables if needed after feedback, read on related papers and new framework.

Work allocation: The whole team.

## Week 2: 1-7 May

 * Familliarise with godot
 * Try out different wave generation techniques
 * A boat with simple steering
 * Have a first result

Work allocation:<br>
  All members collaborate to get a nice result.<br>
  Jonas works on the boat.<br>
  The rest work on the wave generation.

## Week 3: 8-14 May

 * Finalising the wave generation functionality.
 * UI to dynamically change wave generation variables
 * Boat physics (realistic buyancy)

Work allocation:<br>
  Core part: all members<br>
  Boat: Jonas<br>
  UI: Jonas<br>
  Weather Simulation: Toni<br>
  Water Foam: Nephele

## Week 4: 15-21 May

 * Work on extras, solve any problems.

## Week 5: 22-28 May

 * Work on extras, solve any problems.

## Week 6: 29 May - 4 June

 * Make video, everyobody works to finalize report.

# Resources

We consider making the demo in Godot, an open-source game engine.<br>
We believe that in order to make our project look really realistic and interactive, we need a solid framework.

# Milestone Report 12/05/2023

## Current state of project

We have accomplished an infinite sea of waves, as the boat can move forever. The method used to have this type of infinity is to move the water underneath the boat instead of moving the boat. There is a very detailed mesh of the water in the centre, and the further away the mesh the less detail. This way, we give an impression of infinity.

The waves are currently generated in the shader using noise. They are generated in the vertex shader where we change the height for every vertex according to its position and time. As we get further away from the boat we scale the height of waves to be smaller so that the seams between the meshes are less noticeable.

We have placed a boat that floats according to the current waves. We also decided that we are going to have an interactive part that will change some of the variables for the wave generation.

Currently working on:

* Looking to change the strategy of the infinite sea by having one big mesh whith a very dense centre with vetrices and further away less vertices. This would eliminated the need to minimize the seams between the mutliple meshes.

* Reading about the Fast Fourier Transform for wave generation, according to the paper by Tessendorf. The issue we are currently facing is that Fourier transforms use imaginary numbers while in Godot shader language there aren't.

* Sky

![Boat-water interaction](images/boat_with_waves.jpg){width="500px"}

## Updated Schedule

## Week 3: 8-14 May

 * Work on FFT wave generation functionality.
 * UI to dynamically change wave generation variables -- completed, waiting to complete FFT
 * Boat physics (realistic buyancy)  -- completed

Work allocation:<br>
  Core part: all members<br>
  Boat: Jonas<br>
  UI: Nephele<br>
  Sky Simulation: Toni<br>
  Water Foam: Nephele

## Week 4: 15-21 May

 * Finish FFT
 * Jonas works on birds
 * Work on extras, solve any problems.

## Week 5: 22-28 May

 * White water trail behind boat
 * Design a cooler boat in Blender!
 * Foam research
 * Work on extras, solve any problems.

## Week 6: 29 May - 4 June

 * Camera curve (Bezier) tryout
 * Make video, everyobody works to finalize report.



## Research

 * https://www.cg.tuwien.ac.at/research/publications/2018/GAMPER-2018-OSG/
 * https://www.cse.chalmers.se/edu/course/TDA362/tutorials/heightfield.html
 * https://arm-software.github.io/opengl-es-sdk-for-android/ocean_f_f_t.html
 * https://www.youtube.com/watch?v=VSwVwIYEypY
 * https://www.youtube.com/watch?v=kGEqaX4Y4bQ
 * https://www.youtube.com/watch?v=lo8YwUkO9zQ
 * https://en.wikipedia.org/wiki/Boids
 * https://www.youtube.com/watch?v=7KGQ9NC4uGk
 * https://www.youtube.com/watch?v=oosFrxF30Pk

 New Resources

 * https://www.keithlantz.net/2011/10/ocean-simulation-part-one-using-the-discrete-fourier-transform/
 * https://www.keithlantz.net/2011/11/ocean-simulation-part-two-using-the-fast-fourier-transform/
 * https://docs.godotengine.org/en/stable/tutorials/shaders/index.html
 * https://stayathomedev.com/tutorials/making-an-infinite-ocean-in-godot-4/


