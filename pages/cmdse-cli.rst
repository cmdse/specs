#########
Cmdse CLI
#########

Synopsis
########

.. container:: synopsis big

   cmdse [-i|-c|-e] QUERY...

The default behaviour of |app-name| is to process ``QUERY…`` operands and print the best-matched :term:`command snippets <command snippet>`.

A ``QUERY`` operand is a :term:`word` witch is evaluated either as a :term:`query selectors <query selector>` or a :term:`query literals <query literal>`.

.. code-block:: bash
   :caption: Example with a :term:`program query selector` and two :term:`query literals <query literal>`

   $ cmdse :tar extract files

Options
#######

.. program:: cmdse

.. option:: -i, --interactive

   Launch **i**\ nteractive shell mode.

.. option:: -c, --copy-first

  **C**\ opy the first result command snippet in the clipboard.

.. option:: -e, --execute-first

  Launch interactive mode and prompt the user if he wants to **e**\ xecute the first :term:`command snippet` found with the joint query.
  For any :term:`command parameter`, the user will be prompt to provide an input.

Examples
########

.. code-block:: bash
  :caption: Query matching literal sequence "tar unpack"

  $ cmdse tar unpack
  tar -xvf [resource-path.tar.gz]
  V3: Unpack and extract the content of the compressed archive located in
  [resource-path.tar.gz] to the current working directory.

  tar -C [target-path] -xzf [resource-path.tar.gz]
  V3: Unpack and extract the content of the compressed archive located in
  [resource-path.tar.gz] to [target-path] directory.

.. code-block:: bash
  :caption: Query matching all snippets using "docker" utility executable

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
  :caption: Query restricted to "docker" utility executable matching literal sequence "remove all containers"

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
