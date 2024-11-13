# Contributing

- [Contributing](#contributing)
  - [Why](#why)
  - [Style](#style)
  - [Coding Structure](#coding-structure)
  - [Helpful Tools](#helpful-tools)
  - [git Commit Formatting](#git-commit-formatting)
    - [Git Commit Message Template](#git-commit-message-template)
    - [Template Breakdown with Examples](#template-breakdown-with-examples)
      - [1. Type](#1-type)
      - [2. Scope](#2-scope)
      - [3. Short Description](#3-short-description)
      - [4. Long Description (Optional)](#4-long-description-optional)
      - [5. BREAKING CHANGE (If Applicable)](#5-breaking-change-if-applicable)
      - [6. References](#6-references)
    - [Example Commit Messages](#example-commit-messages)
      - [Example 1: Feature Addition](#example-1-feature-addition)
      - [Example 2: Bug Fix](#example-2-bug-fix)
      - [Example 3: Documentation Update](#example-3-documentation-update)
      - [Example 4: Performance Improvement](#example-4-performance-improvement)
  - [Submitting Commits](#submitting-commits)

## Why

Ansible is one of those things that often becomes very messy. The reason we strictly enforce coding standards from the outset is twofold:

1. To make sure the project is extensible over time
2. To ensure that people other than the original author can maintain, update, or extend the codebase

## Style

See [Coding Style Good Practices for Ansible](https://github.com/grantcurell/automation-good-practices/blob/main/coding_style/README.adoc)

For writing Python modules:

See [PEP 8 - Style Guide for Python Code](https://peps.python.org/pep-0008/)

## Coding Structure

See [Good Practices for Ansible](https://github.com/grantcurell/automation-good-practices/tree/main)

## Helpful Tools

For Ansible, use [Ansible Lint](https://ansible.readthedocs.io/projects/lint/)

There is an [Ansible linter extension for vscode](https://developers.redhat.com/learning/learn:ansible:get-started-ansible-visual-studio-code-extension/resource/resources:ansible-lint-integration-ansible-vs-code-extension)

For Python, use [Python Linter](https://code.visualstudio.com/docs/python/linting)

## git Commit Formatting

### Git Commit Message Template

```
<type>(<scope>): <short description>

<long description>

BREAKING CHANGE: <explanation of breaking change>

References: <issue/ticket numbers, links, or additional resources>.
```

**When referencing issues make sure to use #<github #> because this will autolink in GitHub**

### Template Breakdown with Examples

#### 1. Type  
   - **Types** describe the purpose of the commit. Commonly used types include:
     - **feat**: a new feature
     - **fix**: a bug fix
     - **chore**: general tasks or maintenance (e.g., updating dependencies)
     - **docs**: documentation changes
     - **refactor**: code refactoring without changing functionality
     - **test**: adding or updating tests
     - **style**: formatting, whitespace, etc. (no functional code changes)
     - **perf**: performance improvements
     - **build**: changes that affect the build system or dependencies

#### 2. Scope
   - **Scope** is optional but helps with clarity if you’re working in a large project.
   - It could refer to the affected module, component, or feature, such as `auth`, `api`, `database`, etc.

#### 3. Short Description
   - A concise, one-line summary of what was done (use the imperative mood, e.g., “add,” “fix”).

#### 4. Long Description (Optional)
   - Expand on what you did and why if it’s not obvious from the short description. Mention key details that may help other contributors.

#### 5. BREAKING CHANGE (If Applicable)
   - Use this section to explain changes that are incompatible with previous versions.

#### 6. References
   - Include links to relevant issues, tickets, or documentation.

### Example Commit Messages

#### Example 1: Feature Addition

```
feat(auth): add token-based authentication

Introduced JWT for authentication, replacing the previous session-based method.
Updated user model to support token generation and added necessary middleware.

BREAKING CHANGE: Removed session-based authentication methods, requiring clients to use JWT.

References: #123
```

#### Example 2: Bug Fix

```
fix(api): correct null pointer issue in user endpoint

Fixed a null pointer exception that occurred when querying a non-existent user.
Added input validation to return a 404 for missing users, improving API stability.

References: #456
```

#### Example 3: Documentation Update

```
docs(database): update setup instructions for PostgreSQL 13

Added instructions for PostgreSQL 13 configuration, reflecting recent dependency updates.
Clarified environment variable setup for newcomers.

References: internal Confluence link or any relevant resources
```

#### Example 4: Performance Improvement

```
perf(api): optimize query performance for large datasets

Improved the data retrieval logic, reducing query time by an average of 30%.
Applied batch processing to handle larger sets more efficiently.

References: #789
```

## Submitting Commits

We follow the [Forking Workflow](https://www.atlassian.com/git/tutorials/comparing-workflows/forking-workflow)

We always rebase rather than merge commit. See [Rebase vs Merge](https://www.atlassian.com/git/tutorials/merging-vs-rebasing)

Multiple commits must be squashed to logical chunks following the formatting outlined in [git Commit Formatting](#git-commit-formatting)
