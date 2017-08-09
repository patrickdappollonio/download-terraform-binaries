# download-terraform-binaries

[![Build Status](https://travis-ci.org/patrickdappollonio/download-terraform-binaries.svg?branch=master)](https://travis-ci.org/patrickdappollonio/download-terraform-binaries)

A bash script to download the most up-to-date Terraform binaries per platform (or the version you want). This script, when executed,
will download the terraform compiled binary from the [terraform.io website](https://www.terraform.io/)
based on the [Hashicorp Checkpoint API](https://checkpoint.hashicorp.com/) or the 
[Hashicorp releases page](https://releases.hashicorp.com/terraform/) -- as a way to find the latest
version available.

Unfortunately, Hashicorp does not provide a way to download the latest version of their software in an easy way,
[and with a fair reason](https://github.com/hashicorp/terraform/issues/9803#issuecomment-257903082), hence the
existence of the page you're reading.

## Usage

To execute it, simply run the following command:

```bash
bash <(curl -s https://raw.githubusercontent.com/patrickdappollonio/download-terraform-binaries/master/download_terraform_binaries.sh)
```
## Details

The script by default will save the binaries into the `$HOME` directory in a `terraform/` folder. Inside
that folder, there will be a folder for each platform you requested the download for. For example,
if you request the plarforms `windows`, `darwin` and `linux`, then you'll get a bin folder with the
following structure:

```
$ tree $HOME/terraform/
terraform/
├── darwin
├── linux
└── windows

3 directories
```

By default, **only the `terraform` binary for Linux** is downloaded (although you can change that,
see "Configuration" below). Also, **this tool can only download 64-bit binaries** (but it's not
difficult to modify the script to allow 32-bit too).

## Configuration

* `$TF_DOWNLOAD_PATH`: path to a folder where to store the terraform binaries. If ran locally (without the `bash curl` trick from above) this will automatically be set to `./bins/`.
* `$TF_PLATFORMS`: one or many terraform platforms separated by space (use quotes to pass more than one). The current available platforms at terraform are "darwin", "freebsd", "openbsd", "linux", "solaris" and "windows".
* `$TF_VERSION`: the version of terraform you want to download. By default, if nothing passed, it'll check against the terraform Checkpoint API to retrieve the latest version.
