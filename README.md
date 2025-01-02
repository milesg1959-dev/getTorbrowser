# getTorbrowser

As the name suggests, **getTorbrowser** is a shell script specifically designed to obtain the **Torbrowser** (including the **Tor Expert Bundle** toolkit developed in conjunction with **Torbrowser**).

For various network environments, we have meticulously gathered multiple mirror sites for you to select and download from.

## Features

> * Retrieve the list of current available **Torbrowser** (**Tor Expert Bundle**);
> * Download the latest recommended (or specific version) of **Torbrowser** (**Tor Expert Bundle**);
> * Create a download item list file for the latest recommended (or specific version) of **Torbrowser** (**Tor Expert Bundle**) (for use by [**FDM**](https://www.freedownloadmanager.org/) and other download software);
> * Install / Update the latest recommended (or specific version) of the **Tor Expert Bundle**.

## Other scripts

### tor

> A shell script for **tor**, which can be used separately.
> Can simultaneously open and control 1-8 **tor** processes.
> Requires **Tor Expert Bundle**, already included.

### privoxy

> A shell script for [**Privoxy**](https://www.privoxy.org/), which can be used separately.
> Used in conjunction with **tor**.
> [**Privoxy**](https://www.privoxy.org/) needs to be installed.
> macOS recommends using [**Homebrew**](https://brew.sh/) Installation.
> ```brew install --cask privoxy```

### haproxy

> A shell script for [**HAproxy**](https://www.haproxy.org/) (multi proxy, load balancing), which can be used separately.
> Used in conjunction with **tor** and **privoxy**.
> [**HAproxy**](https://www.haproxy.org/) needs to be installed.
> macOS recommends using [**Homebrew**](https://brew.sh/) Installation.
> ```brew install --cask haproxy```

## Script libraries

> * **rc.common** - Common function libraries.
> * **rc.onion** - **Tor** control function libraries.
> * **rc.privoxy** - **Privoxy** control function libraries.
> * **rc.haproxy** - **HAproxy** control function libraries.

## Other software needed

### wget

> **getTorbrowser** requires **wget** to download **Torbrowser** (**Tor Expert Bundle**).
> macOS recommends using [**Homebrew**](https://brew.sh/) Installation.
> ```brew install --cask wget```

## Other

Please refer to: <https://www.torproject.org>
