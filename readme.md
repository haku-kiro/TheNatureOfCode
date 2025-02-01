# The Nature of Code

This repository follows the "The Nature of Code" book by Daniel Shiffman, implemented in Zig with Raylib.

## Overview

This project contains implementations of the examples and exercises from the book "The Nature of Code". It uses the Zig programming language and Raylib for graphics.

## Build Instructions

### Prerequisites

- Zig (greater than 0.13.0 - the version tested on)

### Building the Project

To build the main executable:

```sh
zig build
```

### Examples

This project includes several example implementations. Each example can be built and run individually.

Here are the examples included so far:

- `RandomWalk`: `./src/00_randomness/RandomWalk.zig`
- `UniformDistribution`: `./src/00_randomness/UniformDistribution.zig`
- `RightWalker`: `./src/00_randomness/RightWalker.zig`
- `NormalDistribution`: `./src/00_randomness/NormalDistribution.zig`
- `AcceptRejectDistribution`: `./src/00_randomness/AcceptRejectDistribution.zig`
- `WalkerRandomSteps`: `./src/00_randomness/WalkerRandomSteps.zig`
- `PerlinGraphs`: `./src/00_randomness/PerlinGraphs.zig`

To build an example:

```sh
zig build <ExampleName>
```

To run an example:

```sh
zig build run-<ExampleName>
```

Replace `<ExampleName>` with the name of the example you want to run, e.g., `RandomWalk`.
