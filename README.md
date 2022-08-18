# Github NPM Registry

## About this article

GitHub with GitHubActions and GHAS offer an incredible experience for developers around the planet. Just with a few considerations and good ideas we can build a wonderful experience for our development teams, and they just literally "work only on their code"

## Using Github NPM Registry - Local Environment

### Authenticating to the NPM Registry

1. Setting your [access token](https://docs.github.com/en/packages/learn-github-packages/about-permissions-for-github-packages#about-scopes-and-permissions-for-package-registries), to enable GitHub functions like an OAuth access token and authenticates the access to the GitHub API.

    Select the ```read:packages``` scope to download container images and read their metadata.

    Select the ```write:packages``` scope to download and upload container images and read and write their metadata.

    Select the ```delete:packages``` scope to delete container images.

2. To authenticate by adding your personal access token to your ~/.npmrc file, edit the ~/.npmrc file for your project to include the following line, replacing TOKEN with your personal access token. Create a new ~/.npmrc file if one doesn't exist.

    ```
    //npm.pkg.github.com/:_authToken=TOKEN
    ```
3. To authenticate by logging in to npm, use the ```npm login``` command, replacing USERNAME with your GitHub username, TOKEN with your personal access token, and PUBLIC-EMAIL-ADDRESS with your email address.

If GitHub Packages is not your default package registry for using npm and you want to use the ```npm audit``` command, we recommend you use the ```--scope``` flag with the owner of the package when you authenticate to GitHub Packages.

```
  $ npm login --scope=@OWNER --registry=https://npm.pkg.github.com
  > Username: USERNAME
  > Password: TOKEN
  > Email: PUBLIC-EMAIL-ADDRESS
```

### Pushing packages

#### Publishing a package using a local .npmrc file

You can use an .npmrc file to configure the scope mapping for your project. In the .npmrc file, use the GitHub Packages URL and account owner so GitHub Packages knows where to route package requests. Using an .npmrc file prevents other developers from accidentally publishing the package to npmjs.org instead of GitHub Packages.

1. Authenticate to GitHub Packages. For more information, see "[Authenticating to GitHub Packages](https://docs.github.com/en/packages/working-with-a-github-packages-registry/working-with-the-npm-registry#authenticating-to-github-packages)."
2. In the same directory as your ```package.json``` file, create or edit an ```.npmrc``` file to include a line specifying GitHub Packages URL and the account owner. Replace ```OWNER``` with the name of the user or organization account that owns the repository containing your project.

    ```
    @OWNER:registry=https://npm.pkg.github.com
    ```

3. Add the .npmrc file to the repository where GitHub Packages can find your project. For more information, see "[Adding a file to a repository](https://docs.github.com/en/repositories/working-with-files/managing-files/adding-a-file-to-a-repository)."

    **NOTE**: Include on [```.gitignore```](https://docs.github.com/en/get-started/getting-started-with-git/ignoring-files) the exclusion of .npmrc to not compromise security.

4. Verify the name of your package in your project's package.json. The name field must contain the scope and the ```name``` of the package. For example, if your package is called "test", and you are publishing to the "My-org" GitHub organization, the ```name``` field in your package.json should be ```@my-org/test```.

5. Verify the repository field in your project's package.json. The ```repository``` field must match the URL for your GitHub ```repository```. For example, if your repository URL is ```github.com/my-org/test``` then the repository field should be ```https://github.com/my-org/test.git```.

6. Publish the package:

    ```
    $ npm publish
    ```

#### Publishing a package using publishConfig in the package.json file

You can use ```publishConfig``` element in the package.json file to specify the registry where you want the package published. For more information, see "[publishConfig](https://docs.npmjs.com/files/package.json#publishconfig)" in the npm documentation.

1. Edit the package.json file for your package and include a ```publishConfig``` entry.

```
"publishConfig": {
  "registry":"https://npm.pkg.github.com"
},
```

2. Verify the ```repository``` field in your project's package.json. The ```repository``` field must match the URL for your GitHub repository. For example, if your repository URL is ```github.com/my-org/test``` then the repository field should be ```https://github.com/my-org/test.git```

3. Publish the package:

      ```
      $ npm publish
      ```
To discover every way to working with [NPM Registry](https://docs.github.com/en/packages/working-with-a-github-packages-registry/working-with-the-npm-registry) please generete and **ISSUE**.

<br>

## Using Github Container Registry - Github Action
<br>

```
name: Create and publish NPM Package
on:
  release:
    types: [published]

jobs:
  Publish-NPM-Package:
    runs-on: ubuntu-latest
    permissions:
      packages: write
      contents: read
    steps:
      - uses: actions/checkout@v3
      - uses: actions/setup-node@v3
        with:
          node-version: 18
          cache-dependency-path: package-lock.json
          registry-url: https://npm.pkg.github.com
      - run: npm install
      - run: npm ci
      - run: npm publish
        env:
          NODE_AUTH_TOKEN: ${{secrets.PAT_GITHUB_TOKEN}}
```
```
name: NPM Audit
on:
  pull_request: 
    branches: [develop, staging, master]
    types: [opened, synchronize]

jobs:
  npm-audit:
    name: npm audit
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: install dependencies
        run: npm ci
      - uses: oke-py/npm-audit-action@v2
        with:
          audit_level: moderate
          github_token: ${{ secrets.PAT_GITHUB_TOKEN }}
          issue_assignees: oke-py
          issue_labels: vulnerability,test
          dedupe_issues: true
```

To enable more capabilities and demostrate the strongest of Github and Github Actions we complement this example with [Github Reusable Workflows](https://docs.github.com/en/actions/using-workflows/reusing-workflows) using Open Source Tools and Enterprise Tools on Actions.

Reusing workflows avoids duplication. This makes workflows easier to maintain and allows you to create new workflows more quickly by building on the work of others, just as you do with actions. Workflow reuse also promotes best practice by helping you to use workflows that are well designed, have already been tested, and have been proved to be effective. Your organization can build up a library of reusable workflows that can be centrally maintained.

**Note:** To enable your actions, in some cases you must configurate [encrypted secrets](https://docs.github.com/en/enterprise-cloud@latest/actions/security-guides/encrypted-secrets)

<br>

```
name: Github Reusable Workflow
on:
  pull_request: 
    branches: [develop, staging, master]
    types: [opened, synchronize]
  release:
    types: [published]

jobs:
  NPM-Audit:
    if: github.event_name != 'opened'
    uses: ./.github/workflows/npm-audit.yml
    secrets:
      PAT_GITHUB_TOKEN: ${{ secrets.PAT_GITHUB_TOKEN }}
  
  NPM-Publish:
    if: ${{ (github.event.release.action == 'released') && always() }}
    uses: ./.github/workflows/npm-registry.yml
    needs: [NPM-Audit]
    secrets:
      PAT_GITHUB_TOKEN: ${{ secrets.PAT_GITHUB_TOKEN }}
```
<br>

## Licence

The scripts and documentation in this project are released under the [MIT License](./LICENSE)
## Contributions

Contributions are welcome! See [Contributor's Guide](./docs/contributors.md)

## Code of Conduct

👋 Be nice. See our [code of conduct](./docs/code_of_conduct.md)

## References

+ **NPM Publish:** https://github.com/actions/setup-node
+ **NPM Audit Signatures:** https://github.blog/changelog/2022-07-26-a-new-npm-audit-signatures-command-to-verify-npm-package-integrity/
+ **NPM Audit:** https://github.com/marketplace/actions/npm-audit-action
