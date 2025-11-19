# Contributing to ApexToon

Thank you for your interest in contributing to ApexToon! We welcome contributions from the community and appreciate your help in making this project better.

## Table of Contents

- [Contributing to ApexToon](#contributing-to-apextoon)
  - [Table of Contents](#table-of-contents)
  - [Code of Conduct](#code-of-conduct)
  - [Getting Started](#getting-started)
  - [How to Contribute](#how-to-contribute)
  - [Development Guidelines](#development-guidelines)
    - [Setting Up Your Development Environment](#setting-up-your-development-environment)
    - [Project Structure](#project-structure)
  - [Pull Request Process](#pull-request-process)
    - [Pull Request Guidelines](#pull-request-guidelines)
  - [Reporting Bugs](#reporting-bugs)
  - [Suggesting Enhancements](#suggesting-enhancements)
  - [Code Style](#code-style)
    - [Apex Coding Standards](#apex-coding-standards)
    - [Example:](#example)
  - [Testing](#testing)
    - [Test Naming Convention](#test-naming-convention)
    - [Running Tests](#running-tests)
  - [Commit Messages](#commit-messages)
    - [Example:](#example-1)
  - [Questions?](#questions)
  - [License](#license)

## Code of Conduct

By participating in this project, you agree to maintain a respectful and inclusive environment for all contributors. Please be considerate and professional in all interactions.

## Getting Started

1. **Fork the repository** to your own GitHub account
2. **Clone your fork** locally:
   ```bash
   git clone https://github.com/YOUR-USERNAME/ApexToon.git
   cd ApexToon
   ```
3. **Create a branch** for your changes:
   ```bash
   git checkout -b feature/your-feature-name
   ```

## How to Contribute

There are many ways to contribute to ApexToon:

- **Report bugs** and issues
- **Suggest new features** or enhancements
- **Improve documentation**
- **Submit bug fixes** or feature implementations
- **Review pull requests**
- **Write or improve tests**

## Development Guidelines

### Setting Up Your Development Environment

ApexToon is an Apex library for Salesforce. To work on this project, you'll need:

- A Salesforce org (Developer Edition, Sandbox, or Scratch Org)
- Salesforce CLI (sf) installed
- Your preferred IDE (VS Code with Salesforce Extension Pack recommended)

### Project Structure

- `core/` - Core library classes
- `encoder/` - Encoding functionality
- `decoder/` - Decoding functionality
- `util/` - Utility classes and helpers
- `test/` - Test classes

## Pull Request Process

1. **Ensure your code follows the project's coding standards**
2. **Add or update tests** to cover your changes
3. **Update documentation** if necessary
4. **Ensure all tests pass** before submitting
5. **Write a clear commit message** describing your changes
6. **Submit a pull request** with a detailed description of:
   - What changes were made
   - Why the changes were necessary
   - Any related issues (use "Fixes #123" to auto-close issues)

### Pull Request Guidelines

- Keep pull requests focused on a single feature or bug fix
- Reference any related issues in the PR description
- Provide context and motivation for the changes
- Be responsive to feedback and questions
- Ensure your branch is up to date with the main branch

## Reporting Bugs

Before submitting a bug report:

1. **Check existing issues** to see if the bug has already been reported
2. **Verify the bug** in the latest version of the code

When creating a bug report, please include:

- **Clear title** and description
- **Steps to reproduce** the issue
- **Expected behavior** vs actual behavior
- **Salesforce API version** you're using
- **Code samples** or test cases if applicable
- **Error messages** or stack traces

## Suggesting Enhancements

We welcome suggestions for new features! When proposing an enhancement:

- **Check existing issues** to avoid duplicates
- **Clearly describe the feature** and its use case
- **Explain why this enhancement** would be useful to most users
- **Provide examples** of how the feature would work

## Code Style

### Apex Coding Standards

- **Use meaningful names** for classes, methods, and variables
- **Follow Apex naming conventions**:
  - Classes: PascalCase
  - Methods: camelCase
  - Constants: UPPER_SNAKE_CASE
  - Variables: camelCase
- **Add Javadoc comments** for public methods and classes
- **Keep methods focused** and reasonably sized
- **Use proper exception handling**
- **Avoid hard-coded values** - use constants instead

### Example:

```apex
/**
 * Encodes a value into TOON format
 * @param value The value to encode
 * @param options The encoding options
 * @return The encoded string
 */
public static String encode(Object value, EncodeOptions options) {
    // Implementation
}
```

## Testing

All contributions must include appropriate test coverage:

- **Write test classes** for new functionality
- **Update existing tests** if modifying behavior
- **Aim for high code coverage** (minimum 75%, ideally 85%+)
- **Test edge cases** and error conditions
- **Use descriptive test method names** that explain what is being tested

### Test Naming Convention

```apex
@isTest
static void testMethodName_Scenario_ExpectedResult() {
    // Test implementation
}
```

### Running Tests

Deploy your changes to a Salesforce org and run all test classes to ensure nothing is broken.

## Commit Messages

Write clear, concise commit messages:

- Use the present tense ("Add feature" not "Added feature")
- Use the imperative mood ("Move cursor to..." not "Moves cursor to...")
- Limit the first line to 72 characters or less
- Reference issues and pull requests when relevant

### Example:

```
Add support for nested object encoding

- Implement recursive encoding for nested structures
- Add tests for deeply nested objects
- Update documentation

Fixes #123
```

## Questions?

If you have questions about contributing, feel free to:

- Open an issue with the "question" label
- Check existing documentation and issues
- Reach out to the maintainers

## License

By contributing to ApexToon, you agree that your contributions will be licensed under the same license as the project.

---

Thank you for contributing to ApexToon! 🎉
