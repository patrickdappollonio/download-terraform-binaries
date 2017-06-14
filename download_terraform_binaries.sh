#!/bin/bash

set -e
set -o pipefail

# Global configuration
_HASHICORP_RELEASE_URL="https://api.github.com/repos/hashicorp/terraform/releases/latest"
_REQUIRED_APPS=("curl" "sed" "awk" "unzip")
_AVAILABLE_TF_PLARFORMS=("darwin" "freebsd" "openbsd" "linux" "solaris" "windows")

# Extra global variables for internal use
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Configurable variables
TF_DOWNLOAD_PATH=${TF_DOWNLOAD_PATH:-"${DIR}/bins"}
TF_PLATFORMS=${TF_PLATFORMS:-"linux"}

# This function checks against the Github API url to find
# the latest version of the terraform binary.
function get_latest_version() {
    # Download the contents of the JSON API from Github
    local content=$(curl -s -X GET ${_HASHICORP_RELEASE_URL})

    # Get the tag names
    local version=$(echo ${content} | get_json_value "tag_name")

    # We also need to remove the "v" at the beginning
    # and print...
    version=$(echo ${version} | cut -c 2-)
    echo -e "${version}"
}

# Download the terraform binary for 64-bits from the website. This function
# takes three parameters. "$1" is the platform, "$2" is the version tag number
# in the semver format, without "v" at the beginning, and "$3" is the output.
function download_terraform_binary() {
    local platform=$1
    local version=$2
    local destination=$3

    # Check if directory exists
    if [ ! -d "$destination" ]; then
        mkdir -p "${destination}"
    fi

    # Generate the link needed to download the binary.
    local filename="terraform_${version}_${platform}"   # the filename is usually "terraform_0.9.3_windows"
    local zipfile="${filename}_amd64.zip"               # the zipfile is the name including the architecture and the extension
    local download_url="https://releases.hashicorp.com/terraform/${version}/${zipfile}" # the path to the full download URL

    # Download the file and warn the user of the given process
    echo -e "Downloading Terraform for ${platform} v${version} into ${destination}/${zipfile}..."
    curl -sS -o "${destination}/${zipfile}" "${download_url}"
    [ $? -eq 0 ] || { echo -e " [!] Unable to download Terraform zip file. Exiting..."; exit 1; }

    # Warn that we finished the download and we're proceeding to unzip the file
    echo -e " - Download successful. Unzipping ${zipfile} into the same directory..."
    unzip -q "${destination}/${zipfile}" -d "${destination}/"
    rm -rf "${destination}/${zipfile}"

    # Create a folder with the platform name and move the binary there, and also check
    # if the platform is windows. If so, then we need to add the extension.
    local bin_filename="terraform"
    if [ "$platform" == "windows" ]; then
        bin_filename="terraform.exe"
    fi

    # Warn the user about the folder creation
    echo -e " - Creating the \"${platform}\" folder under \"${destination}\"..."
    mkdir -p "${destination}/${platform}"
    check_directory_exists "${destination}/${platform}"

    # Move the file to the new destination
    echo -e " - Moving terraform ${platform} binary into \"${destination}/${platform}\"..."
    mv "${destination}/${bin_filename}" "${destination}/${platform}"
    if [ ! -e "${destination}/${platform}/${bin_filename}" ]; then
        echo -e " [!] Unable to move the binary into the new location. File not found at \"${destination}/${platform}/${bin_filename}\"..."
        exit 1
    fi

    echo -e " - Terraform for ${platform} successfully downloaded at \"${destination}/${platform}/${bin_filename}\"!"
    echo -e "   $(file "${destination}/${platform}/${bin_filename}")"
}

# Check if directory exists. The unique parameter used is the first one
# which corresponds to the directory path being checked.
function check_directory_exists() {
    if [ ! -d "$1" ]; then
        echo -e "Directory \"$1\" does not exists... Aborting..."
        exit 1
    fi
}

# Find if value is in array. The first item is the value we're looking for
# while the second one is the array.
function in_array() {
    local item=$1
    shift

    for one in $@; do
        if [ $one = $item ]; then
            return 0
        fi
    done

    return 1
}

# Retrieve a JSON value from a JSON value name. The first
# parameter ($1) is the JSON contents, and the second parameter ($2)
# is the value name you want to retrieve.
function get_json_value() {
    awk -F"[,:}]" '{for(i=1;i<=NF;i++){if($i~/'$1'\042/){print $(i+1)}}}' | tr -d '"' | sed -n ${2}p
}

# This checks if we do have or not the required apps to run
# this bash script, like dependencies
function check_installed_apps() {
    # Define a list of apps as requirements, that we can later check, if they're
    # not installed, we can install them
    local not_installed_apps=()

    # Check if any of the given programs is not installed, as requirements
    for i in "${_REQUIRED_APPS[@]}"
    do
        # Check if the app is not installed, if not, install
        if ! [ -x "$(command -v ${i})" ]; then
            not_installed_apps=("${not_installed_apps[@]}" "${i}")
        fi
    done

    # Check if we need to install extra dependencies
    if ! [ ${#not_installed_apps[@]} -eq 0 ]; then
        echo -e "The following apps are a requirement and they aren't installed."
        echo -e "   Please install them first: ${not_installed_apps[@]}"
        exit 1
    fi
}

# Starting point
function main() {
    # Perform a check against needed apps to run this script
    check_installed_apps

    # If the user passed a download path, check that it does exists
    if [ ! "$TF_DOWNLOAD_PATH" == "$DIR/bins" ]; then
        check_directory_exists $TF_DOWNLOAD_PATH
    fi

    # Get the version and save it into a variable for later use
    local tf_version=$(get_latest_version)

    # Check if the platform we're trying to download are available
    local requested_platforms=($TF_PLATFORMS)
    for pl in "${requested_platforms[@]}"; do
        if ! in_array $pl ${_AVAILABLE_TF_PLARFORMS[@]} ; then
            echo -e "Requested platform, \"${pl}\" is not available as a terraform binary!"
        else
            download_terraform_binary ${pl} ${tf_version} ${TF_DOWNLOAD_PATH}
            echo -e ""
        fi
    done

}

main "$@"
