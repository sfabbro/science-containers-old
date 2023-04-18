## Containers

Curently the repository contains basic build system to build these containers:

```
	BASE_CONTAINER=ubuntu:22.04
		 |
	 base  base-gpu
	   |      |
	astroml astroml-gpu astrapids-gpu
```

The `base` container are basic ubuntu containers with extra operating system installed (compilers, development libraries) and a super-minimal conda install.

The `astroml` container has many astronomy, machine learning, visualisations and data science libraries.
The `astrapids-gpu` is GPU-only all the astroml and NVIDIA rapids library. 

The CUDA toolkit and CUDA-powered libraries are with the `-gpu` versions.
All the bottom layer containers are given with three versions: 
- a notebook (`-notebook`)
- a web-based Visual Studio (`-vscode`)
- a headless container (no suffix).
