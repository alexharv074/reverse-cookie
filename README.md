# reverse-cookie.sh

`reverse-cookie.sh` is a tool that helps you create new Cookiecutter templates from existing projects. It is inspired by [`retrocookie`](https://retrocookie.readthedocs.io/en/latest/) and written in Bash. It reverse engineers the project structure by extracting the template variables from the source project and generating the corresponding Cookiecutter template.

## Prerequisites

- On macOS, ensure you have `gnu-sed` installed:
    ```
    brew install gnu-sed
    ```

## Installation

Clone this project and run the installer:

```
bash install.sh
```

It will copy the executable script to `/usr/local/bin`.

## Usage

To use this script:

```
Usage: reverse-cookie.sh [-h] -i INPUT -o OUTPUT [-E EXCLUDE1 -E ...]
```

- `-i INPUT`: The path to the source project you want to create a Cookiecutter template from.
- `-o OUTPUT`: The path where the generated Cookiecutter template will be saved.
- `-E EXCLUDE`: (Optional) One or more paths to exclude from the generated template. You can specify multiple exclude paths by repeating the `-E` flag followed by the path to exclude. By default, the script excludes `.git`, and `.cookiecutter.json`.

The script will create the specified output directory, copy the source project files (excluding the specified paths), and generate a new `README.md` and `cookiecutter.json` file for the template. It will also replace the project-specific values with their corresponding Cookiecutter variables.

After the script has completed, the generated Cookiecutter template will be initialized as a new Git repository with an initial commit.

## Example

To create a Cookiecutter template from an existing project located at `./myproject` and save the generated template in a directory named `./cookiecutter-myproject`, run:

```
reverse-cookie.sh -i ./myproject -o ./cookiecutter-myproject
```

If you want to exclude additional directories or files, use the -E flag followed by the path to exclude. For example, to exclude a node_modules directory:

```
reverse-cookie.sh -i ./myproject -o ./cookiecutter-myproject -E node_modules
```

## License

This script is licensed under the MIT License. For more details, refer to the [LICENSE](LICENSE) file included in the repository.
