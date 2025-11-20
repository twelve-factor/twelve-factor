# Twelve-Factor Methodology Agent Skill

This is an Agent Skill that enables Claude to analyze, design, and improve cloud-native applications using the [twelve-factor methodology](https://12factor.net).

## What is this Skill?

This Skill provides Claude with comprehensive knowledge and workflows for applying the twelve-factor methodology to software-as-a-service applications. When you ask Claude about cloud-native architecture, application modernization, or microservices design, this Skill will automatically activate to provide expert guidance.

## Skill Structure

```
twelve-factor-skill/
├── SKILL.md          # Main skill instructions and workflows
├── EXAMPLES.md       # Code examples across languages
├── CHECKLIST.md      # Compliance verification checklist
└── README.md         # This file
```

### Progressive Loading

This Skill uses progressive disclosure to minimize context usage:

1. **Level 1 (Always loaded)**: Skill name and description from YAML frontmatter (~100 tokens)
2. **Level 2 (When triggered)**: Main instructions from SKILL.md (~4-5k tokens)
3. **Level 3+ (As needed)**: Additional resources like EXAMPLES.md and CHECKLIST.md

Only the specific files needed for your task are loaded into Claude's context.

## When Claude Uses This Skill

Claude automatically uses this Skill when you:

- Analyze application architecture for cloud readiness
- Review code for twelve-factor compliance
- Design new SaaS applications
- Modernize legacy applications
- Evaluate microservices architecture
- Troubleshoot scalability or portability issues
- Mention twelve-factor principles, cloud-native, or related concepts

## How to Use This Skill

### Installation

#### Claude.ai
1. Zip the `twelve-factor-skill` directory
2. Go to Settings > Features in Claude.ai
3. Upload the zip file under Custom Skills

#### Claude API
```python
from anthropic import Anthropic

client = Anthropic()

# Upload the skill (one time)
with open('twelve-factor-skill.zip', 'rb') as f:
    skill = client.skills.create(
        skill_file=f,
        name='twelve-factor-methodology'
    )

# Use the skill in conversations
response = client.messages.create(
    model="claude-sonnet-4-5-20250929",
    max_tokens=4096,
    container={
        "type": "code_execution",
        "skills": [skill.id]
    },
    messages=[{
        "role": "user",
        "content": "Review this codebase for twelve-factor compliance"
    }]
)
```

#### Claude Code
1. Copy the `twelve-factor-skill` directory to `~/.claude/skills/`
2. Or place it in your project's `.claude/skills/` directory
3. Claude Code will automatically discover and use it

### Example Usage

#### Quick Compliance Check
```
Analyze this application against the twelve-factor methodology
and provide a compliance scorecard.
```

#### Factor-Specific Guidance
```
How should I implement Factor III (Config) in my Python Flask application?
```

#### Architecture Review
```
Review this codebase for violations of twelve-factor principles,
focusing on scalability and cloud readiness.
```

#### Modernization Planning
```
Create a roadmap for making this legacy application twelve-factor compliant.
```

## What This Skill Provides

### Comprehensive Analysis
- Factor-by-factor assessment
- Compliance scoring
- Specific code examples of violations
- Prioritized recommendations

### Concrete Guidance
- Language-specific implementation patterns
- Anti-patterns to avoid
- Tool recommendations
- Platform-specific considerations (AWS, GCP, Azure, Heroku)

### Actionable Templates
- Quick compliance checklist
- Detailed assessment template
- Remediation roadmap
- Code review checklist

### Code Examples
- Python, Node.js, Ruby, Java, Go implementations
- Complete working examples
- Good vs. bad patterns
- Real-world scenarios

## Skill Contents

### SKILL.md
Main skill file containing:
- Factor-by-factor guidance
- Implementation workflows
- Assessment templates
- Best practices
- Troubleshooting guide
- Platform-specific advice

### EXAMPLES.md
Code examples including:
- All twelve factors implemented in multiple languages
- Good vs. bad patterns
- Complete application examples
- Docker, Kubernetes, cloud platform configurations

### CHECKLIST.md
Compliance verification tools:
- Detailed checklist for each factor
- Quick verification commands
- Scorecard template
- Priority identification guide

## Capabilities

This Skill enables Claude to:

1. **Assess Compliance**: Evaluate applications against all twelve factors
2. **Provide Specific Recommendations**: Offer concrete, actionable improvements
3. **Show Code Examples**: Demonstrate correct implementation patterns
4. **Identify Anti-Patterns**: Point out common violations
5. **Prioritize Improvements**: Help teams focus on highest-impact changes
6. **Support Multiple Languages**: Provide guidance for Python, Node.js, Ruby, Java, Go, and more
7. **Consider Platform Context**: Adapt advice for AWS, GCP, Azure, Heroku, etc.

## Example Outputs

### Compliance Assessment
```markdown
# Twelve-Factor Compliance Assessment

**Overall Score: 7/12 factors compliant**

## Critical Issues
1. ❌ Factor III (Config): Credentials hardcoded in config/database.yml
2. ❌ Factor VI (Processes): Sessions stored in memory

## Recommendations
1. [HIGH] Move all credentials to environment variables
2. [HIGH] Migrate sessions to Redis
3. [MEDIUM] Add Procfile for process types
```

### Implementation Guidance
```python
# Factor III: Config - Python Implementation

import os

# ✅ Good: Configuration from environment
DATABASE_URL = os.environ['DATABASE_URL']
SECRET_KEY = os.environ['SECRET_KEY']

# Validate required config at startup
required = ['DATABASE_URL', 'SECRET_KEY', 'REDIS_URL']
missing = [k for k in required if k not in os.environ]
if missing:
    raise ValueError(f"Missing: {missing}")
```

## Updating the Skill

To update the skill with new guidance or examples:

1. Edit the relevant `.md` files
2. Re-zip the directory (for Claude.ai and API)
3. Re-upload to your platform

The skill automatically reflects changes in Claude Code when you update files in `.claude/skills/`.

## Skill Metadata

- **Name**: `twelve-factor-methodology`
- **Version**: 1.0
- **Author**: Twelve-Factor Community
- **License**: CC BY 4.0 (matches twelve-factor documentation)

## Related Resources

- **Twelve-Factor Documentation**: The `content/` directory contains authoritative factor documentation
- **Capabilities Overview**: See `CAPABILITIES.md` for benefits and use cases
- **Official Website**: [https://12factor.net](https://12factor.net)
- **GitHub Repository**: [https://github.com/twelve-factor/twelve-factor](https://github.com/twelve-factor/twelve-factor)

## Limitations

This Skill:
- Does not modify code automatically (provides guidance only)
- Requires code execution environment to be most effective
- Works best with access to your codebase
- Focuses on SaaS applications (may not apply to all software types)

## Support and Contributions

This Skill is based on the twelve-factor methodology maintained at:
- GitHub: https://github.com/twelve-factor/twelve-factor
- Discord: https://discord.gg/9HFMDMt95z
- Mailing List: https://groups.google.com/g/twelve-factor

For issues or improvements to this Skill, please contribute to the twelve-factor repository.

## License

This Skill is licensed under CC BY 4.0, matching the twelve-factor documentation.

You are free to:
- Share: Copy and redistribute
- Adapt: Remix, transform, and build upon

Under the following terms:
- Attribution: You must give appropriate credit

See [LICENSE](../LICENSE) for details.
