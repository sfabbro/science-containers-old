## Containers

Curently the repository contains basic build system to build these containers:

```
	    BASE_CONTAINER
		     |
	        / \
		base   base-gpu -------
	     |       |             | 
	  astroml  astroml-gpu   astrapids-gpu
```

- The `BASE_CONTAINER` is currently set to be the latest Ubuntu LTS container.
- The `base` and `base-gpu` containers inherit from the `BASE_CONTAINER` with extra operating system installed (compilers, development libraries), specific  and a minimal conda install.
- The `astroml-*` ones contain a large set of astronomy, machine learning, visualisations and data science libraries.
- The `astrapids-gpu`is a GPU-only container, with all the `astroml` goodies, and complemented with the large cuda accelerated NVIDIA RAPIDS modules.

The CUDA toolkit and CUDA-powered libraries are with the `-gpu` versions.

The build script can produce three variant of containers
- a headless version (no suffix), with no extra packages installed
- a notebook (`-notebook`) variant, based on the headless one, but includes jupyterlab and many useful extensions
- a web-based Visual Studio (`-vscode`) server

Basically the build script will produce various stacks of packages, installed via `apt-get` or with `conda`.
