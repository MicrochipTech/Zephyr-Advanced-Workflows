# Zephyr Advanced Workflows
Welcome to Zephyr Advanced Workflows, a class delivered by Microchip, Inc.

## Pre-work
This class is built to be run in a group setting, potentially at a hotel or conference center.  Because internet and dowload speeds can be spotty in these locations, 
the class is designed to make use of pre-cached large chunks of data including git repositories and docker containers.  The install process is scripted to place these
blobs in C:\Developers\F2FZephyr, which will become our Zephyr workspace.  The following high-level step are run with the included script:
  1. Install podman, uv, and git
  2. Using podman, initialize a machine and pre-cache the Zephyr SDK container [Zephyr Containers](https://github.com/zephyrproject-rtos/docker-image)
  3. Using git, pre-download the Zephyr, hal_microchip, cmsis, and cmsis_6 repositiories from [Zephyr Github](https://github.com/zephyrproject-rtos/)
  4. Using uv, download and install Python 3.12, then create a Python VENV with this specific Python version
  5. Using pip in the VENV, install west and pyocd, with a DFP for our target (pic32CM PL10 CNANO)

Using this collateral, all labs can be completed without further software install, but internet connection is still required for browsing github repositories, Zephyr
documentation, and other similar activites.

## Lab 1 - Customize a west.yml and Zephyr Workspace
In this lab, the student will learn to customize a west.yml manifest file, locking zephyr and all module content into specific versions.  The student will observe
the defualt west.yml on the zephyrproject-rtos github, consider what maodules are needed for their Application, and populate a Zephyr Workspace with this manifest.

### Proceedure
#### Step 1. Find the default Zephyr Project west.yml
Navigate to the [Zephyr Project Github](https://github.com/zephyrproject-rtos/zephyr).  Note that the current branch is "main".

<img width="537" height="240" alt="image" src="https://github.com/user-attachments/assets/08ae2da6-160d-474f-be93-65b911e81eba" />

Use the dropdown and choose "Tags" to display a list of version tags available in the project.  Scroll down to v4.4.0 to select it.

<img width="568" height="457" alt="image" src="https://github.com/user-attachments/assets/9fe2f491-b11c-4763-bb56-f15b4814dc4d" />

In the main code list, find "west.yml" and click to open and view contents

<img width="558" height="223" alt="image" src="https://github.com/user-attachments/assets/f3b6402a-d605-46e7-b746-ad96886204d8" />

Observe the contents of west.yml, noting the `manifest:` header with nested sections for `remotes:` and `projects:`.  There are many modules listed in `projects:` that are not
needed for every application, including full driver sets for other vendors and middleware that may not be necessary in every case.  Best practice is to only include modules
that you know you need for your application.  Though you may not need all of these modules at the moment, take a few minutes to familiarize yourself with all of the modules that are
downloaded with a default install.  

#### Step 2. Navigate to our pre-configured west.ynml for this class
Follow the link to the rpository for the [Zephyr Advnaces Workflows](https://github.com/microchiptech/zephyr-advanced-workflows) class, and similarly open the west.yml in this repository.
Note that the 


#### Step 3.  Open a command terminal and naviagate to the workspace create in the pre-work.
   - `c:\> cd c:\Developers\F2FZephyr`


## Lab 2
Coming Soon!

## Lab 3
Coming Soon!
