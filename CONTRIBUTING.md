# Contributing to Wazuh SIEM Enhancement

Thank you for your interest in contributing! This project aims to democratize advanced cybersecurity capabilities through open-source collaboration.

## 🌟 How You Can Contribute

### 1. Detection Rule Development
- Create new rules for emerging threats
- Improve existing rule accuracy
- Add Linux/macOS detection coverage
- Reduce false positive rates

### 2. Dashboard Enhancements
- Design new visualization panels
- Optimize query performance
- Add filtering capabilities
- Improve user experience

### 3. Documentation
- Write installation guides
- Create video tutorials
- Translate documentation
- Document use cases

### 4. Testing & Validation
- Conduct adversary simulation testing
- Report bugs and issues
- Validate detection accuracy
- Performance benchmarking

### 5. Research & Analysis
- Threat intelligence integration
- Detection methodology improvements
- Academic research collaboration

## 📋 Contribution Guidelines

### Code Standards

**Detection Rules (XML)**
```xml






  PARENT_RULE
  
  pattern
  
  Clear description of what is detected and why it matters
  
  
    T1XXX.XXX
  
  
  attack.tactic_name,custom_category,

```

**Documentation (Markdown)**
- Use clear headings and structure
- Include code examples where relevant
- Add screenshots for dashboard/UI changes
- Keep language accessible (avoid excessive jargon)

**Commit Messages**
```
Type: Brief description (50 chars max)

Detailed explanation of changes made, why they were needed,
and any relevant context. Reference issues with #123.

- Bullet points for multiple changes
- Keep line length under 72 characters

Fixes #123
```

Types: `feat`, `fix`, `docs`, `style`, `refactor`, `test`, `chore`

### Pull Request Process

1. **Fork & Branch**
   ```bash
   git clone https://github.com/yourusername/wazuh-siem-enhancement.git
   git checkout -b feature/your-feature-name
   ```

2. **Develop & Test**
   - Write your code/documentation
   - Test thoroughly in local environment
   - Validate rule syntax: `python scripts/validate_rules.py`
   - Update relevant documentation

3. **Commit Changes**
   ```bash
   git add .
   git commit -m "feat: Add detection for technique T1234"
   ```

4. **Push & Create PR**
   ```bash
   git push origin feature/your-feature-name
   ```
   - Open Pull Request on GitHub
   - Use PR template (auto-populated)
   - Link related issues

5. **Review Process**
   - Maintainers will review within 5-7 days
   - Address feedback and requested changes
   - Squash commits if requested
   - PR will be merged once approved

## 🧪 Testing Requirements

### Detection Rule Testing

**Minimum Requirements:**
- [ ] Rule syntax validated (no Wazuh errors)
- [ ] Positive test case provided (rule fires correctly)
- [ ] Negative test case provided (rule doesn't fire incorrectly)
- [ ] MITRE ATT&CK technique correctly mapped
- [ ] Description is clear and actionable
- [ ] Appropriate severity level set

**Testing Procedure:**
```bash
# 1. Deploy rule to test environment
sudo cp your_rule.xml /var/ossec/etc/rules/
sudo systemctl restart wazuh-manager

# 2. Test with wazuh-logtest
sudo /var/ossec/bin/wazuh-logtest
# Paste test log entry, verify rule triggers

# 3. Generate real event (if possible)
# Execute technique on test system
# Verify alert appears in Wazuh dashboard

# 4. Document in test_cases/
echo "Test case details" >> test_cases/your_technique_test.txt
```

### Dashboard Testing

- [ ] All queries execute without errors
- [ ] Query performance <5 seconds for 10K alerts
- [ ] Visualizations render correctly
- [ ] No console errors in browser
- [ ] Mobile responsive (if applicable)

## 📝 Pull Request Template

```markdown
## Description
Brief description of changes and motivation

## Type of Change
- [ ] New detection rule
- [ ] Bug fix
- [ ] Dashboard enhancement
- [ ] Documentation update
- [ ] Performance improvement
- [ ] Other (specify):

## Related Issues
Fixes #123
Related to #456

## Testing Performed
- [ ] Manual functional testing
- [ ] Rule syntax validation
- [ ] Dashboard query testing
- [ ] Documentation review

## Test Cases
Describe test scenarios and results:
1. Test case 1: ...
2. Test case 2: ...

## Screenshots (if applicable)
Add screenshots for visual changes

## Checklist
- [ ] Code follows project style guidelines
- [ ] Documentation updated (if needed)
- [ ] Test cases added/updated
- [ ] CHANGELOG.md updated
- [ ] All tests pass locally
- [ ] No new warnings or errors

## Additional Context
Any other relevant information
```

## 🐛 Bug Report Template

```markdown
## Bug Description
Clear description of the issue

## Expected Behavior
What should happen

## Actual Behavior
What actually happens

## Steps to Reproduce
1. Step 1
2. Step 2
3. Step 3

## Environment
- Wazuh Version: X.X.X
- OS: Ubuntu 20.04 / Windows Server 2019
- Elasticsearch Version: X.X.X
- Grafana Version: X.X.X

## Relevant Logs
```
Paste relevant error messages or logs
```

## Screenshots
Add screenshots if helpful

## Possible Solution
(Optional) Suggest a fix if you have ideas
```

## 💡 Feature Request Template

```markdown
## Feature Description
Clear description of proposed feature

## Problem It Solves
What pain point does this address?

## Proposed Solution
How should it work?

## Alternative Solutions
Other approaches considered

## Use Case
Real-world scenario where this would be valuable

## Implementation Notes
Technical considerations or suggestions

## Priority
- [ ] Critical (security gap)
- [ ] High (significant improvement)
- [ ] Medium (nice to have)
- [ ] Low (future enhancement)
```

## 🔒 Security Vulnerability Reporting

**DO NOT** open public issues for security vulnerabilities.

Instead:
1. Email: security@yourproject.com
2. Include detailed description
3. Provide proof-of-concept (if applicable)
4. Allow 90 days for patch before public disclosure

We follow responsible disclosure practices and will credit researchers.

## 📜 Code of Conduct

### Our Pledge
We are committed to providing a welcoming and inclusive environment for all contributors regardless of background, identity, or experience level.

### Standards
**Positive Behaviors:**
- Using welcoming and inclusive language
- Respecting differing viewpoints
- Accepting constructive criticism gracefully
- Focusing on what's best for the community
- Showing empathy toward others

**Unacceptable Behaviors:**
- Harassment or discriminatory language
- Trolling, insulting, or derogatory comments
- Personal or political attacks
- Publishing others' private information
- Other conduct inappropriate for professional setting

### Enforcement
Violations can be reported to: conduct@yourproject.com  
All reports will be reviewed and investigated promptly and fairly.

## 🏆 Recognition

Contributors will be recognized in:
- CONTRIBUTORS.md file
- Project README acknowledgments
- Release notes for significant contributions

### Contributor Tiers

**🌟 Core Maintainer**
- 10+ merged PRs
- Active for 6+ months
- Write access to repository

**🚀 Regular Contributor**
- 5+ merged PRs
- Consistent quality contributions

**✨ Contributor**
- 1+ merged PRs
- Listed in CONTRIBUTORS.md

## 📚 Resources for Contributors

### Learning Resources
- [Wazuh Documentation](https://documentation.wazuh.com/)
- [MITRE ATT&CK Framework](https://attack.mitre.org/)
- [MITRE D3FEND](https://d3fend.mitre.org/)
- [Grafana Documentation](https://grafana.com/docs/)

### Development Setup
See [docs/development-environment-setup.md](docs/development-environment-setup.md)

### Community
- GitHub Discussions: Q&A and ideas
- Monthly contributor calls: First Friday of month
- Slack/Discord: [Join link]

## 🎯 Current Priority Areas

### High Priority
1. Linux detection rule coverage
2. Atomic Red Team validation suite
3. Dashboard performance optimization
4. D3FEND integration implementation

### Medium Priority
1. macOS detection rules
2. Additional APT technique coverage
3. Automated response playbooks
4. Multi-language documentation

### Future Enhancements
1. Machine learning integration
2. Threat hunting query library
3. SOAR platform integration
4. Mobile dashboard optimization

## ❓ Questions?

- **General Questions**: GitHub Discussions
- **Technical Issues**: GitHub Issues
- **Private Inquiries**: bajraroshan@gmail.com

---

Thank you for contributing to democratizing cybersecurity capabilities! Every contribution, no matter how small, makes a difference.

**Together, we can ensure advanced security tools aren't limited by organizational budget.**