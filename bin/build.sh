#!/usr/bin/env bash
#
# Build the documentation.
#
# This script does the following:
#
# - Updates the mkdocs.yml to add:
#   - site_url
#   - markdown extension directives
#   - theme directory
# - Builds the documentation.
# - Restores mkdocs.yml to its original state.
#
# The script should be copied to the `doc/` directory of your project,
# and run from the project root.
#
# @license   http://opensource.org/licenses/BSD-3-Clause BSD-3-Clause
# @copyright Copyright (c) 2016 Zend Technologies USA Inc. (http://www.zend.com)

SCRIPT_PATH="$(cd "$(dirname "$0")" && pwd -P)"

function help() {
    echo "Usage:"
    echo "  ${0} [options]"
    echo "Options:"
    echo "  -h           Usage help; this message."
    echo "  -m           Maintain original mkdocs.yml file."
    echo "  -u <url>     Deployment URL of documentation (to ensure search works)"
}

while getopts hmu: option;do
    case "${option}" in
        h) help && exit 0;;
        m) MAINTAIN_CONFIG_FILE=true;;
        u) SITE_URL=${OPTARG};;
    esac
done

DOC_DIR=doc
if [ -d "docs" ];then
    DOC_DIR=docs
fi

# Build assets
echo "Building assets"
${SCRIPT_PATH}/asset.sh

# Backup mkdocs.yml
if [ ${MAINTAIN_CONFIG_FILE} ]; then
    cp mkdocs.yml mkdocs.yml.orig
fi

# Update the mkdocs.yml
echo "Building documentation in ${DOC_DIR}"

if [ -n "${SITE_URL}" ]; then
    echo "site_url: ${SITE_URL}" >> mkdocs.yml
fi

echo "extra:" >> mkdocs.yml
cat zend-doc-theme-pt-br/assets.yml >> mkdocs.yml
echo "markdown_extensions:" >> mkdocs.yml
echo "    - markdown.extensions.codehilite:" >> mkdocs.yml
echo "        use_pygments: False" >> mkdocs.yml
echo "    - pymdownx.superfences" >> mkdocs.yml
echo "theme_dir: zend-doc-theme-pt-br/theme" >> mkdocs.yml

# Preserve files if necessary (as mkdocs build --clean removes all files)
if [ -e .zf-mkdoc-theme-preserve ]; then
    mkdir .preserve
    for PRESERVE in $(cat .zf-mkdoc-theme-preserve); do
        cp ${DOC_DIR}/html/${PRESERVE} .preserve/
    done
fi

mkdocs build --clean

# Restore mkdocs.yml
if [ ${MAINTAIN_CONFIG_FILE} ]; then
    mv mkdocs.yml.orig mkdocs.yml
fi

# Restore files if necessary
if [ -e .zf-mkdoc-theme-preserve ]; then
    for PRESERVE in $(cat .zf-mkdoc-theme-preserve); do
        mv .preserve/${PRESERVE} ${DOC_DIR}/html/${PRESERVE}
    done
    rm -Rf ./preserve
fi

# Make images responsive
echo "Making images responsive"
php ${SCRIPT_PATH}/img_responsive.php ${DOC_DIR}

# Make tables responsive
echo "Making tables responsive"
php ${SCRIPT_PATH}/table_responsive.php ${DOC_DIR}

# Fix pipes in tables
echo "Fixing pipes in tables"
php ${SCRIPT_PATH}/table_fix_pipes.php ${DOC_DIR}
