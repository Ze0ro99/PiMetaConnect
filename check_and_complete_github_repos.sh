#!/bin/bash

GITHUB_USER="Ze0ro99"
GITHUB_API="https://api.github.com"
WORKDIR="github_repos_check"
STANDARD_FILES=("README.md" "LICENSE" ".gitignore" "CONTRIBUTING.md" "CODE_OF_CONDUCT.md" "SECURITY.md" "CHANGELOG.md")
AUTO_GENERATE=1  # Set to 0 if you don't want to auto-create missing files

mkdir -p "$WORKDIR"
cd "$WORKDIR" || exit 1

echo "Fetching repositories for user: $GITHUB_USER..."

REPOS=$(curl -s "$GITHUB_API/users/$GITHUB_USER/repos?per_page=100" | grep -oP '"clone_url": "\K(.*)(?=")')

for REPO_URL in $REPOS; do
    REPO_NAME=$(basename -s .git "$REPO_URL")
    echo -e "\n========================"
    echo "Checking $REPO_NAME ..."
    if [ ! -d "$REPO_NAME" ]; then
        git clone --depth=1 "$REPO_URL"
    fi
    cd "$REPO_NAME" || continue

    # Check for standard files
    echo "Standard open-source files:"
    for FILE in "${STANDARD_FILES[@]}"; do
        if [ -f "$FILE" ]; then
            echo "  ✔ $FILE exists"
        else
            echo "  ✘ $FILE missing"
            if [ "$AUTO_GENERATE" -eq 1 ]; then
                case $FILE in
                    "README.md")
                        echo -e "# $REPO_NAME\n\nProject description.\n" > README.md;;
                    "LICENSE")
                        curl -s https://choosealicense.com/licenses/mit/ | grep -A 30 "MIT License" | head -n 30 > LICENSE;;
                    ".gitignore")
                        echo -e "*.pyc\n__pycache__/\nnode_modules/\ndist/\n.env\n" > .gitignore;;
                    "CONTRIBUTING.md")
                        echo -e "# Contributing\n\nPull requests are welcome. For major changes, please open an issue first.\n" > CONTRIBUTING.md;;
                    "CODE_OF_CONDUCT.md")
                        echo -e "# Code of Conduct\n\nBe kind and respectful to others.\n" > CODE_OF_CONDUCT.md;;
                    "SECURITY.md")
                        echo -e "# Security Policy\n\nPlease report vulnerabilities as issues or contact the maintainer.\n" > SECURITY.md;;
                    "CHANGELOG.md")
                        echo -e "# Changelog\n\nAll notable changes to this project will be documented here.\n" > CHANGELOG.md;;
                esac
                echo "    → $FILE has been auto-generated."
                git add "$FILE"
            fi
        fi
    done

    # Check for GitHub Actions workflows
    if [ -d ".github/workflows" ]; then
        echo "  ✔ GitHub Actions workflows found"
    else
        echo "  ✘ No GitHub Actions workflows"
    fi

    # Suggest free automation tools if not already present
    if grep -q python .gitignore 2>/dev/null || find . -name "*.py" | grep -q .; then
        if [ ! -f ".pre-commit-config.yaml" ]; then
            echo "  ℹ Suggest installing pre-commit for Python: https://pre-commit.com/"
            if [ "$AUTO_GENERATE" -eq 1 ]; then
                echo -e "repos:\n- repo: https://github.com/pre-commit/pre-commit-hooks\n  rev: v4.4.0\n  hooks:\n    - id: trailing-whitespace\n    - id: end-of-file-fixer\n    - id: check-yaml\n" > .pre-commit-config.yaml
                echo "    → .pre-commit-config.yaml has been created."
                git add .pre-commit-config.yaml
            fi
        fi
    fi

    # Commit and push changes if any file was auto-generated
    if [ "$AUTO_GENERATE" -eq 1 ] && git status --porcelain | grep -q '^[AM] '; then
        git config user.name "auto-script"
        git config user.email "auto-script@noreply"
        git commit -m "Auto-add: open source standard files"
        git push origin HEAD
    fi

    cd ..
done

echo -e "\n=== All repositories checked. Summary above. ==="
echo "If you want to run this script for another user, change GITHUB_USER variable."