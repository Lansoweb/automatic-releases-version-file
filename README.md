## Bump a release file for lamina's automatic releases

### Usage

Add this action after the action/checkout but before laminas/automatic-releases.

You need to define 2 envs:

* ```VERSION_FILE```: the version file to be created/updated. Eg. src/App/Version.php
* ```VERSION_CONTENT```: the version file content. this action will replace the token ||version|| with the version number from the milestone.

### Example

Check [laminas/automatic-releases](https://github.com/laminas/automatic-releases) for details about this file

```yaml
# https://help.github.com/en/categories/automating-your-workflow-with-github-actions

name: "Automatic Releases"

on:
  milestone:
    types:
      - "closed"

jobs:
  release:
    name: "GIT tag, release & create merge-up PR"
    runs-on: ubuntu-latest

    steps:
      - name: "Checkout"
        uses: "actions/checkout@v2"
        with:
          persist-credentials: false

      - name: "Bump version file"
        uses: "lansoweb/automatic-releases-version-file@v1"
        env:
          GITHUB_TOKEN: ${{ secrets.ORGANIZATION_ADMIN_TOKEN }}
          SIGNING_SECRET_KEY: ${{ secrets.SIGNING_SECRET_KEY }}
          GIT_AUTHOR_NAME: ${{ secrets.GIT_AUTHOR_NAME }}
          GIT_AUTHOR_EMAIL: ${{ secrets.GIT_AUTHOR_EMAIL }}
          VERSION_FILE: src/App/Version.php
          VERSION_CONTENT: |
            <?php

            declare(strict_types=1);

            namespace App;

            class Version
            {
                public const VERSION = '||version||';
            }

      - name: "Release"
        uses: "laminas/automatic-releases@v1"
        with:
          command-name: "laminas:automatic-releases:release"
        env:
          GITHUB_TOKEN: ${{ secrets.ORGANIZATION_ADMIN_TOKEN }}
          SIGNING_SECRET_KEY: ${{ secrets.SIGNING_SECRET_KEY }}
          GIT_AUTHOR_NAME: ${{ secrets.GIT_AUTHOR_NAME }}
          GIT_AUTHOR_EMAIL: ${{ secrets.GIT_AUTHOR_EMAIL }}

      - name: "Create Merge-Up Pull Request"
        uses: "laminas/automatic-releases@v1"
        with:
          command-name: "laminas:automatic-releases:create-merge-up-pull-request"
        env:
          GITHUB_TOKEN: ${{ secrets.ORGANIZATION_ADMIN_TOKEN }}
          SIGNING_SECRET_KEY: ${{ secrets.SIGNING_SECRET_KEY }}
          GIT_AUTHOR_NAME: ${{ secrets.GIT_AUTHOR_NAME }}
          GIT_AUTHOR_EMAIL: ${{ secrets.GIT_AUTHOR_EMAIL }}

      - name: "Create and/or Switch to new Release Branch"
        uses: "laminas/automatic-releases@v1"
        with:
          command-name: "laminas:automatic-releases:switch-default-branch-to-next-minor"
        env:
          GITHUB_TOKEN: ${{ secrets.ORGANIZATION_ADMIN_TOKEN }}
          SIGNING_SECRET_KEY: ${{ secrets.SIGNING_SECRET_KEY }}
          GIT_AUTHOR_NAME: ${{ secrets.GIT_AUTHOR_NAME }}
          GIT_AUTHOR_EMAIL: ${{ secrets.GIT_AUTHOR_EMAIL }}

      - name: "Bump Changelog Version On Originating Release Branch"
        uses: "laminas/automatic-releases@v1"
        with:
          command-name: "laminas:automatic-releases:bump-changelog"
        env:
          GITHUB_TOKEN: ${{ secrets.ORGANIZATION_ADMIN_TOKEN }}
          SIGNING_SECRET_KEY: ${{ secrets.SIGNING_SECRET_KEY }}
          GIT_AUTHOR_NAME: ${{ secrets.GIT_AUTHOR_NAME }}
          GIT_AUTHOR_EMAIL: ${{ secrets.GIT_AUTHOR_EMAIL }}

      - name: "Create new milestones"
        uses: "laminas/automatic-releases@v1"
        with:
          command-name: "laminas:automatic-releases:create-milestones"
        env:
          GITHUB_TOKEN: ${{ secrets.ORGANIZATION_ADMIN_TOKEN }}
          SIGNING_SECRET_KEY: ${{ secrets.SIGNING_SECRET_KEY }}
          GIT_AUTHOR_NAME: ${{ secrets.GIT_AUTHOR_NAME }}
          GIT_AUTHOR_EMAIL: ${{ secrets.GIT_AUTHOR_EMAIL }}
```
