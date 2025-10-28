# DOC-TECH-004: Contributing Guidelines

**Version**: 1.0
**Last Updated**: 2025-10-28

## Welcome Contributors!

Thank you for your interest in contributing to A2D2!

## Getting Started

### Development Setup

```bash
# Clone repository
git clone https://github.com/unidel2035/a2d2.git
cd a2d2

# Install dependencies
bundle install

# Setup database
rails db:setup

# Run tests
rails test

# Start development server
./bin/dev
```

### Code Style

We use RuboCop for code formatting:

```bash
# Check code style
bundle exec rubocop

# Auto-fix issues
bundle exec rubocop -a
```

## Contribution Workflow

1. **Fork** the repository
2. **Create** a feature branch: `git checkout -b feature/my-feature`
3. **Make** changes
4. **Test** your changes: `rails test`
5. **Commit** with clear message
6. **Push** to your fork
7. **Create** Pull Request

### Commit Message Format

```
<type>(<scope>): <subject>

<body>

<footer>
```

Types: `feat`, `fix`, `docs`, `style`, `refactor`, `test`, `chore`

Example:
```
feat(agents): add DeepSeek integration

Implement DeepSeek API client for agent LLM calls.
Includes rate limiting and fallback support.

Closes #123
```

## Testing

### Running Tests

```bash
# All tests
rails test

# Specific test file
rails test test/models/document_test.rb

# With coverage
COVERAGE=true rails test
```

### Writing Tests

```ruby
require 'test_helper'

class DocumentTest < ActiveSupport::TestCase
  test "should validate presence of filename" do
    document = Document.new
    assert_not document.valid?
    assert_includes document.errors[:filename], "can't be blank"
  end
end
```

## Code Review

All contributions require code review:

- **Quality**: Clean, readable, maintainable code
- **Tests**: Adequate test coverage (>80%)
- **Documentation**: Updated docs for new features
- **Style**: Follows RuboCop guidelines
- **Security**: No vulnerabilities introduced

## Feature Requests

Submit feature requests via [GitHub Issues](https://github.com/unidel2035/a2d2/issues):

1. Check if issue already exists
2. Describe the feature
3. Explain the use case
4. Add mockups if applicable

## Bug Reports

Report bugs via [GitHub Issues](https://github.com/unidel2035/a2d2/issues):

1. Search existing issues
2. Provide clear title
3. Describe steps to reproduce
4. Include error messages
5. Specify environment (OS, Ruby version, etc.)

## Documentation

Help improve documentation:

- **User guides**: docs/phase-8-deployment/user/
- **Technical docs**: docs/phase-8-deployment/technical/
- **API docs**: Update alongside code changes

## Community

- **Discussions**: [GitHub Discussions](https://github.com/unidel2035/a2d2/discussions)
- **Chat**: Coming soon
- **Email**: dev@example.com

## License

By contributing, you agree that your contributions will be licensed under the MIT License.

---

**Thank you for contributing to A2D2!**

**Document Version**: 1.0
**Last Updated**: 2025-10-28
