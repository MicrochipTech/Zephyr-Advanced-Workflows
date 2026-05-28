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



https://github.com/user-attachments/assets/49965edc-7eb2-454e-ab9a-540bb655fe17



Congratulations!  You've explored methods for choosing a specific version of Zephyr and locking your project code to that version (all mathing module versions).  If a new developer joins your team, they can be up
and running quickly with this project code code and be assured that their zephyr code matches your code!  In the following labs, we'll learn implement the same principles to the Zephyr SDK versions to be certain that compiled code remains consistent across developer computers.


## Lab 2 - Compiling with Containers (Podman)
In Lab 1, we guaranteed that our source code is identical across all developer machines by utilizing a custom west.yml manifest. However, modern embedded development requires a specific triad to successfully compile: Source Code + Python Virtual Environment + Compiler Toolchain (Zephyr SDK). If you update your code to a newer Zephyr version, but leave your local SDK at an older version, your build will instantly break. Managing these dependencies natively on Windows is a well-known nightmare.

In this lab, we will solve the "Works on My Machine" problem forever. Instead of installing the Zephyr SDK natively, we will use a pre-built Podman container that houses a mathematically perfect, guaranteed-to-compile environment. We will evolve a basic container command into a robust build pipeline, resulting in a compiled .elf file ready to flash to the PIC32CM PL10 CNANO.

### Proceedure
#### Step 1. Verify the Pre-Cached Container Environment
First, let's ensure that the Podman virtual machine is running and that the Zephyr build image we downloaded during the pre-work is available. Ensure you are in your active VSCode terminal.

  - `(F2FZephyr) c:\Developers\F2FZephyr\> podman machine start`
  - `(F2FZephyr) c:\Developers\F2FZephyr\> podman images`

You should see ghcr.io/zephyrproject-rtos/zephyr-build listed in your local image repository with the v0.29.2 tag. This ~5GB image contains the exact CMake versions, Devicetree compilers, and SDKs required by the Zephyr project.

#### Step 2. The Naive Build Attempt
Let's try to run the standard west build command using the container. We will pass the board name for our target hardware (pic32cm_pl10_cnano) and tell it to build our application folder (.\app\).

  - `(F2FZephyr) c:\Developers\F2FZephyr\> podman run --rm ghcr.io/zephyrproject-rtos/zephyr-build:v0.29.2 west build -b pic32cm_pl10_cnano .\app`

This command will fail rapidly with an error similar to FATAL ERROR: neither a Zephyr workspace nor a west installation could be located.

Containers are completely isolated environments. While the container has the compiler installed, it has absolutely no idea what is on your Windows hard drive. It is empty. We need to bridge the gap between your Windows filesystem and the isolated Linux container.

#### Step 3. The Volume Mount Attempt
To fix the isolation issue, we use a "Volume Mount" (the -v flag) to map our current working directory (${PWD}) directly into a folder inside the container called /workdir. We also set /workdir as the active working directory (the -w flag).

  -`(F2FZephyr) c:\Developers\F2FZephyr\> podman run --rm  -u root --entrypoint bash -v ${PWD}:/workdir:z  -w /workdir  ghcr.io/zephyrproject-rtos/zephyr-build:v0.29.2  -c "west build -p always -b pic32cm_pl10_cnano app"`
  
Note: If you are using the standard Command Prompt instead of PowerShell, replace ${PWD} with %cd%.  However, Powershell is recommended for script compatibility with linux or Mac development envirnoments, which also make use of ${PWD}.  In Lab 3, you'll get a sense of why this is important!

#### Step 4. Verify the Build Artifacts
Once the container finishes compiling, it will cleanly exit and disappear. Because we used a volume mount, all of the compiled binaries were dropped directly onto your host machine.

Using the VSCode file explorer on the left, navigate to `F2FZephyr/build/zephyr/`. You should now see the `zephyr.elf`, `zephyr.hex`, and `zephyr.bin` files, along with all of the artifacts you'd expect to see if the compile took place on your own machine!

#### Step 5. Attempt to flash your board
Now that we have our compiled binary, let's flash it to the board using our native Windows terminal. Plug in your PIC32CM PL10 CNANO board and ensure it is recognized by your machine.

Try running the standard flash command natively (NOT in the container):

  - `(F2FZephyr) c:\Developers\F2FZephyr\> west flash`

The command will likely fail, citing a CMake Error: The current CMakeCache.txt directory... is different than the directory /workdir/build where CMakeCache.txt was created.

By default, west flash tries to be helpful. Before flashing, it invokes CMake to check if any C files have changed and rebuild them if necessary. However, because our code was compiled inside the Linux container, the CMakeCache.txt file is filled with absolute Linux paths (like /workdir/build). When your Windows native CMake reads those Linux paths, it panics and shuts down to prevent corrupting the build.

#### Step 6. The Correct Flash Command
Since we know the container just generated a perfectly valid .elf file, we need to instruct West to bypass the CMake verification check completely and hand the file directly to the flash runner (pyOCD).

Run this command to successfully flash the board:

  - `(F2FZephyr) c:\Developers\F2FZephyr\> west flash --no-rebuild`

You should see the runner connect to the board, erase the memory, and program the new firmware. Your LED should now be blinking!

#### Step 7. Verify the Application Flash
In VSCode, change to your "Serial Monitor" tab and connect to your intended device from the dropdown list of available seriel endpoints.
<img width="1092" height="517" alt="image" src="https://github.com/user-attachments/assets/6adf2a9e-dca3-4c41-add6-e5dd44b0e8cb" />

Using the supplied UART commands ('look', 'go', 'take', 'help'), nagivate the Theater, collecting items until you are able to start the show!  When you've succeeded, the yellow LED on your PL10 CNANO board will rapidly flash indicating success!

Beyond Compiling: The Container Ecosystem
We just used the Zephyr Docker image to compile code, but that is only a fraction of its utility. Because this container represents a frozen, perfectly configured environment, it unlocks several advanced team workflows:

Continuous Integration (CI/CD): Instead of running that massive podman command on your laptop, you can drop that exact same command into a GitHub Actions or GitLab CI pipeline. Your cloud server will now compile the code using the exact same toolchain the developers use.

Automated Testing: You can use this container to run Zephyr's twister test framework in the cloud, spinning up QEMU (hardware emulators) or native_posix builds to run unit tests on your C code before a pull request is approved.

Static Analysis: The container has tools like clang-tidy built-in, allowing you to run deep memory and syntax analysis on your codebase without installing LLVM on your Windows machine.


## Lab 3 - Extending West with Custom Commands
In Lab 2, we successfully built and flashed our firmware using a perfectly isolated container environment. However, the resulting command was massive:
podman run --rm -u root --entrypoint bash -v %cd%:/workdir:z -w /workdir ghcr.io/zephyrproject-rtos/zephyr-build:v0.28-branch -c "pip install jsonschema && west build -b pic32cm_pl10_cnano zephyr-advanced-workflows"

Nobody wants to type that. While you could write a Windows .bat file or a Linux .sh script to wrap it, shell scripts are brittle. They break if you run them from the wrong folder, and they don't easily share across different operating systems.

Because west is written entirely in Python, it includes a powerful extension API. In this lab, we will build a custom West extension inside our application repository. We will abstract our massive container command into a simple west cbuild (Container Build) command, and create a west cflash (Custom Flash) command to handle the split-brain CMake pathing.

### Procedure
#### Step 1. Link the Manifest to a Command Router
West is designed with a strict security model. It will not execute random Python scripts you drop into a folder. You must explicitly authorize custom commands by linking them in your top-level west.yml manifest.

Open your application's west.yml file (c:\Developers\F2FZephyr\app\west.yml). Find the `self:` section at the bottom and add the west-commands key:

```
  self:
    path: zephyr-advanced-workflows
    # Add this line to authorize custom commands:
    west-commands: scripts/custom-commands.yml
```

#### Step 2. Create the YAML Command Router
Next, we need to create the custom-commands.yml file we just referenced. This acts as a routing table, mapping the command word the user types to the specific Python file that will execute it.

Create a new folder named `scripts` inside .\app\.

Inside the `scripts` folder, create a file named `custom-commands.yml`.

Add the following YAML configuration:

```
version: "0.1"
commands:
  - name: cbuild
    class: ContainerBuild
    help: Run west build inside the classroom Podman container
    file: cbuild.py
  - name: cflash
    class: CustomFlash
    help: Flash the board bypassing the container paths
    file: cflash.py
```

#### Step 3. Write the Python Hooks (`cbuild.py`)
Now we build the actual Python logic. Every custom West command is a subclass of WestCommand and requires three hooks: an initializer (`__init__`), an argument parser (`do_add_parser`), and the execution logic (`do_run`).

Create a file named `cbuild.py` in your `scripts` folder and paste the following code:

```
import subprocess
import sys
from west.commands import WestCommand
from west import log

class ContainerBuild(WestCommand):
    def __init__(self):
        super().__init__(
            'cbuild',
            'run west build inside the classroom container',
            'Wraps the podman run command to execute west build in an isolated environment.',
            # This flag allows us to pass unknown arguments (like -b pic32cm...) straight to CMake
            accepts_unknown_args=True 
        )

    def do_add_parser(self, parser_adder):
        # Hooks the command into the standard 'west help' menu
        parser = parser_adder.add_parser(self.name, help=self.help, description=self.description)
        return parser

    def do_run(self, args, unknown_args):
        # 1. Reconstruct the user's intended build command using 'unknown_args'
        inner_cmd = "pip install jsonschema && west build " + " ".join(unknown_args)
        log.inf(f"Executing in container: {inner_cmd}")

        # 2. Construct the Podman command using self.topdir (the absolute path to your workspace)
        # This makes the command completely immune to what subfolder you are currently in!
        podman_cmd = [
            "podman", "run", "--rm",
            "-u", "root",
            "--entrypoint", "bash",
            "-v", f"{self.topdir}:/workdir:z",
            "-w", "/workdir",
            "ghcr.io/zephyrproject-rtos/zephyr-build:v0.28-branch",
            "-c", inner_cmd
        ]

        try:
            # 3. Execute the command and stream the output to the terminal
            subprocess.run(podman_cmd, check=True)
            log.inf("Container build completed successfully.")
        except subprocess.CalledProcessError as e:
            log.err(f"Container build failed with exit code {e.returncode}")
            sys.exit(e.returncode)
```

#### Step 4. Write the Flash Wrapper (`cflash.py`)
We also need our `cflash` command to automatically append the `--no-rebuild` flag so that native Windows CMake doesn't panic over the Linux container paths.

Create a file named `cflash.py` in your `scripts` folder.

[!TIP] This is a perfect job to dip your toes into AI assisted coding.  Using Microchip's AI Coding Assistant (or the LLM oif your choice, creste the script.  Here's a prompt that could work:
"I am working on a Zephyr project using west custom commands to build my application in a docker container using a workspace outside of the container.  I need to write a custom-commands python script called cflash.py that implements all of the necessary west hooks for a custom command and simply runs 'west flash' with the '--no-rebuild' flag afterwards.  please create this script"

Place the output into your `cflash.py` and give it a try!  A working sample is provided below and in the `setup` folder

```
import subprocess
import sys
from west.commands import WestCommand
from west import log

class CustomFlash(WestCommand):
    def __init__(self):
        super().__init__(
            'cflash',
            'Flash the board bypassing the container paths',
            'Wraps the native west flash command with the --no-rebuild flag automatically.',
            accepts_unknown_args=True
        )

    def do_add_parser(self, parser_adder):
        parser = parser_adder.add_parser(self.name, help=self.help, description=self.description)
        return parser

    def do_run(self, args, unknown_args):
        # Automatically inject --no-rebuild before appending the user's custom arguments
        flash_cmd = ["west", "flash", "--no-rebuild"] + unknown_args
        log.inf(f"Executing native flash: {' '.join(flash_cmd)}")

        try:
            subprocess.run(flash_cmd, check=True)
            log.inf("Flash completed successfully.")
        except subprocess.CalledProcessError as e:
            log.err(f"Flash failed with exit code {e.returncode}")
            sys.exit(e.returncode)
```

#### Step 5. Test the Automation
Your new commands are now fully integrated into the West ecosystem! Because they are stored in your application repository, anyone who clones your code and runs west update instantly gets access to this custom team tooling.

Let's test it out. In your terminal, run:

  -`(F2FZephyr) c:\Developers\F2FZephyr\> west help`

Scroll to the very bottom of the help menu. Under "Extension Commands," you will now see `cbuild` and `cflash` proudly listed with their help text, automatically self-documented.

Now, compile and flash your code using the seamless workflow:

  -`(F2FZephyr) c:\Developers\F2FZephyr\> west cbuild -b pic32cm_pl10_cnano app`

  -`(F2FZephyr) c:\Developers\F2FZephyr\> west cflash`

Congratulations! You have successfully implemented a professional, enterprise-grade Zephyr workflow. You locked down your exact code dependencies (Lab 1), containerized your compiler to prevent environment rot (Lab 2), and built custom Python automation to make the entire process effortless for your engineering team (Lab 3).
