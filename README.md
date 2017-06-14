# download-terraform-binaries

[![Build Status](https://travis-ci.org/patrickdappollonio/download-terraform-binaries.svg?branch=master)](https://travis-ci.org/patrickdappollonio/download-terraform-binaries)

A bash script to download Terraform binaries per platform. This script, when ran, will download
the terraform compiled binary from the [terraform.io website](https://www.terraform.io/) based on
the Git tags available on Github -- as a way to find the latest version available.

The script by default will save the binaries into the current directory in a `bin/` folder. Inside
that folder, there will be a folder for each platform you requested the download for. For example,
if you request the plarforms `windows`, `darwin` and `linux`, then you'll get a bin folder with the
following structure:

```
$ tree bins/
bins/
├── darwin
├── linux
└── windows

3 directories
```

By default, *only the `terraform` binary for Linux* is downloaded. Also, *this tool can only download
64-bit binaries* (but it's not difficult to modify the script to allow 32-bit too).

To execute it, simply run the following command:

```bash
bash <(curl -s https://raw.githubusercontent.com/patrickdappollonio/download-terraform-binaries/master/download_terraform_binaries.sh)
```

You can configure certain things such as the download directory (which, when set, it will avoid creating
the `bin/` folder in the current directory) where the folder per-platform will be created or what platforms
you want to download, separated by comma.

To change the download location, set the`$TF_DOWNLOAD_PATH` environment variable to an existent folder. To
change what platform binaries are downloaded, set the `$TF_PLATFORMS` to the string you need, separating multiple
platforms with a space, like `export TF_PLATFORMS="windows darwin linux"`.
