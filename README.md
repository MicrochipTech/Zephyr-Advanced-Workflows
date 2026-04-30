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

#### Step 2. Navigate to our pre-configured west.yml for this class
Follow the link to the rpository for the [Zephyr Advanced Workflows](https://github.com/microchiptech/zephyr-advanced-workflows) class, and similarly open the west.yml in this repository.
Note that several ,`project:` modules have been removed leaving only the bare essemntials for our project.  In `remotes:`, there are two remotes listed, one for the internet connected upstram github repo, and the other points to the pre-cached bare repositopries we store in \Developers\F2FZephyr.  If you stored your repos elsewhere, please edit this location.  The location must be a direct path, as relative paths will not work for this west.yml file.  To switch remotes, either specify the `remote:` paramter for each project module, or use the `defaults:` node to set the remote for anything that isn't manually defined.

Also notice that this west.yml is stored alongside some source code, a CMalkeLists.txt, and a prj.conf.  We'll use this repo as the basis for the work in the rest of this class


#### Step 3.  Open a command terminal and navigate to the workspace created in the pre-work.
   - `c:\> cd c:\Developers\F2FZephyr`

When in this directory, open VSCode and accept any requests to trust the authors of the code.
   - `c:\Developers\F2FZephyr\> code .`

With VSCode open, re-open a terminal window and be certain your virtual environment it loaded.  It may happen automatically, or you may need to activate it:
   - `c:\Developers\F2FZephyr\> .venv\Scripts\activate.bat`

#### Step 4. Initialize a Zephyr workspace and 
Initialize your zephyr workspace using the slimmed down manifest file (west.yml) in the MicrochipTech/Zephyr-Advanced-Workflows repository.  You'll see that when we initialize with this repo, west will also pull the project source code and automatically add it to our Zephyr Workspace.
   - `(F2FZephyr) c:\Developers\F2FZephyr\> west init -m http://github.com/MicrochipTech/zephyr-advanced-workflows`
   - If you need to specify a branch, add it's branch name, tag, or commit hash after the -mr flag

From within your zephyr worksace, run `west update` to pull all of your code together into the workspace.  

Congratulations!  You've explored methods for choosing a specific version of Zephyr and locking your project code to that version (all mathing module versions).  If a new developer joins your team, they can be up
and running quickly with this project code code and be assured that their zephyr code matches your code!  In the following labs, we'll learn implement the same principles to the Zephyr SDK versions to be certain that compiled code remains consistent across developer computers.


## Lab 2
Coming Soon!

## Lab 3
Coming Soon!
