######################
Command Line Interface
######################

Usage
######################

Synopsis
**********************

.. code-block:: bash

   $ cmdse [OPTIONS]... [QUERY]...

The default behaviour of :program:`cmdse` is to process ``[QUERY]`` operand and print the best-matched :term:`command snippets <command snippet>`.


QUERY operand
**********************

The QUERY operand is a string composed of one to many words, amongst which :term:`query selectors <query selector>` and :term:`query litterals <query litteral>`.

.. code-block:: bash
   :caption: Example with :term:`program query selector` and two :term:`query litterals <query litteral>`

   :tar extract files

OPTIONS
**********************

.. program:: cmdse

.. option:: -i, --interactive

   Launch **i**\ nteractive shell mode.

.. option:: -c, --copy-first

  **C**\ opy the first result command snippet in the clipboard.

.. option:: -x, --execute-first

  Launch interactive mode and prompt the user if he wants to e\ **x**\ ecute the first :term:`command snippet` found with the joint query.
  For any :term:`command parameter`, the user will be prompt to provide an input.

Examples
**********************

.. code-block:: bash
  :caption: Query matching litteral sequence "tar unpack"

  $ cmdse tar unpack
  tar -xvf [resource-path.tar.gz]
  V3: Unpack and extract the content of the compressed archive located in
  [resource-path.tar.gz] to the current working directory.

  tar -C [target-path] -xzf [resource-path.tar.gz]
  V3: Unpack and extract the content of the compressed archive located in
  [resource-path.tar.gz] to [target-path] directory.

.. code-block:: bash
  :caption: Query matching all snippets using "docker" program executable

  > cmdse :docker
  docker run -it [container] sh
  (V10>) Run shell in the [container] in interactive mode.

  docker rm $(docker ps -a -q -f status=exited)
  (V10>) Remove all containers which status is exited.

  docker ps -a
  (V10>) List all existing containers.

  docker stop $(docker ps -a -q)
  (V10>) Stop all running containers.

  docker rmi $(docker images -q -a)
  (V10>) Remove all existing images.

.. code-block:: bash
  :caption: Query restricted to "docker" program executable matching litteral sequence "remove all containers"

  $ cmdse :docker remove all containers
  docker rm $(docker ps -a -q)
  (V10>) Remove all containers.


Target platform requirements
############################

.. requirement:: target-platform-posix

  The |app-name| command line tool targets modern Linux-GNU distributions with 3.X and 4.X kernels.

.. requirement:: target-terminal

  The |app-name| command line tool should be compatible with the following terminals:

  - Any modern terminal emulator, such as ``xterm``, ``konsole``, ``GNOME terminal`` ...
  - Linux virtual console
