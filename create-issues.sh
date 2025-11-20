#!/bin/bash

# GitHub Issue Creation Script for Codex ZSH Plugin Roadmap
# This script creates all issues from the project roadmap in the correct order
# Run: chmod +x create-issues.sh && ./create-issues.sh

set -e  # Exit on any error

echo "Creating GitHub issues from roadmap..."

# Check if gh CLI is installed and authenticated
if ! command -v gh &> /dev/null; then
    echo "Error: GitHub CLI (gh) is not installed. Please install it first."
    echo "   macOS: brew install gh"
    echo "   Linux: https://github.com/cli/cli#installation"
    exit 1
fi

if ! gh auth status &> /dev/null; then
    echo "Error: GitHub CLI is not authenticated. Please run 'gh auth login' first."
    exit 1
fi

echo "GitHub CLI is ready"

# Create required milestones
echo ""
echo "Creating project milestones..."

MILESTONES=("v1.1.0" "v1.2.0" "v1.3.0" "v2.0.0")
MILESTONE_DESCRIPTIONS=(
    "Critical bug fixes and basic infrastructure"
    "Documentation and development infrastructure"
    "Feature enhancements and user experience"
    "Architecture improvements and advanced features"
)

for i in "${!MILESTONES[@]}"; do
    milestone="${MILESTONES[$i]}"
    description="${MILESTONE_DESCRIPTIONS[$i]}"
    if gh api "repos/:owner/:repo/milestones" --jq ".[].title" 2>/dev/null | grep -q "^${milestone}$"; then
        echo "   Milestone '${milestone}' already exists"
    else
        echo "   Creating milestone '${milestone}'"
        if gh api "repos/:owner/:repo/milestones" \
            --method POST \
            --field title="${milestone}" \
            --field description="${description}" \
            --field state="open" >/dev/null 2>&1; then
            echo "   Created milestone '${milestone}'"
        else
            echo "   Warning: Failed to create milestone '${milestone}'"
        fi
    fi
done

# Create required labels
echo ""
echo "Creating project labels..."

declare -A LABELS=(
    ["jules"]="0052CC:Jules project identifier - added to all issues for tracking"
    ["bug"]="d73a4a:Something isn't working"
    ["critical"]="b60205:Highest priority - needs immediate attention"
    ["high priority"]="d93f0b:High priority issues that should be addressed soon"
    ["good first issue"]="7057ff:Good for newcomers"
    ["enhancement"]="a2eeef:New feature or request"
    ["documentation"]="0075ca:Improvements or additions to documentation"
    ["installation"]="e4e669:Related to plugin installation process"
    ["error handling"]="f9d0c4:Improvements to error handling and user feedback"
    ["async"]="c5def5:Related to asynchronous operations"
    ["testing"]="c2e0c6:Related to testing infrastructure"
    ["infrastructure"]="5319e7:Project infrastructure and tooling"
    ["ci/cd"]="1d76db:Continuous integration and deployment"
    ["community"]="ff9500:Community management and contributor experience"
    ["security"]="d4edda:Security-related improvements"
    ["release management"]="fbca04:Release processes and versioning"
    ["cross-platform"]="bfe5bf:Cross-platform compatibility"
    ["configuration"]="e1f5fe:User configuration options"
    ["debugging"]="f7c6c7:Debugging tools and capabilities"
    ["user experience"]="e99695:User experience improvements"
    ["compatibility"]="c5def5:Compatibility with other tools"
    ["performance"]="0e8a16:Performance optimizations"
    ["update system"]="b794f4:Self-update mechanisms"
    ["cleanup"]="ffeaa7:Code cleanup and refactoring"
    ["examples"]="d4edda:Documentation examples and samples"
    ["troubleshooting"]="fbca04:Troubleshooting guides and help"
)

for label_name in "${!LABELS[@]}"; do
    IFS=':' read -r color description <<< "${LABELS[$label_name]}"
    if gh api "repos/:owner/:repo/labels" --jq ".[].name" 2>/dev/null | grep -q "^${label_name}$"; then
        echo "   Label '${label_name}' already exists"
    else
        if gh api "repos/:owner/:repo/labels" \
            --method POST \
            --field name="${label_name}" \
            --field color="${color}" \
            --field description="${description}" >/dev/null 2>&1; then
            echo "   Created label '${label_name}'"
        fi
    fi
done

echo ""
echo "Creating issues..."
echo ""

# Critical Issues (High Priority) - Bug Fixes

echo "Creating Issue #7: Incorrect Comment Header"
gh issue create \
  --title "Fix incorrect comment header" \
  --body "**Priority:** Critical
**Effort:** 5 minutes
**Location:** \`codex.plugin.zsh:1\`

**Problem**
Comment states \"Autocompletion for the GitHub CLI (codex)\" but should be \"OpenAI Codex CLI\"

**Impact**
Confusing for users and maintainers

**Acceptance Criteria**
- [ ] Update comment on line 1 to correctly reference \"OpenAI Codex CLI\"
- [ ] Verify comment accuracy reflects the actual tool being supported" \
  --label "jules,bug,critical,good first issue" \
  --milestone "v1.1.0"

echo "Creating Issue #8: Function Call Before Definition"
gh issue create \
  --title "Fix function call order" \
  --body "**Priority:** High
**Effort:** 5 minutes
**Location:** \`codex.plugin.zsh:14\`

**Problem**
\`codex_update_completions\` called before being defined (line 26)

**Impact**
May cause undefined function errors in some ZSH configurations

**Acceptance Criteria**
- [ ] Move function definition before first call, OR
- [ ] Defer function call until after definition
- [ ] Test in clean ZSH environment to ensure no errors" \
  --label "jules,bug,high priority" \
  --milestone "v1.1.0"

echo "Creating Issue #9: Missing Directory Creation"
gh issue create \
  --title "Add directory creation" \
  --body "**Priority:** High
**Effort:** 10 minutes
**Location:** \`codex.plugin.zsh:7-8\`

**Problem**
Plugin assumes \`\$ZSH_CACHE_DIR/completions\` exists

**Impact**
Plugin fails silently if directory doesn't exist

**Acceptance Criteria**
- [ ] Add check for directory existence
- [ ] Create directory if it doesn't exist
- [ ] Handle permission errors gracefully
- [ ] Test with fresh ZSH installation" \
  --label "jules,bug,high priority" \
  --milestone "v1.1.0"

echo "Creating Issue #10: Installation Path Errors"
gh issue create \
  --title "Fix installation paths" \
  --body "**Priority:** High
**Effort:** 5 minutes
**Location:** \`README.md:70,75,80\`

**Problem**
Git clone commands target wrong directory path

**Impact**
Plugin won't be found by Oh My Zsh

**Acceptance Criteria**
- [ ] Fix git clone paths to target \`\$ZSH_CUSTOM/plugins/codex-zsh-plugin\`
- [ ] Update all installation methods (HTTPS, SSH, gh CLI)
- [ ] Test installation instructions on clean system" \
  --label "jules,bug,documentation,high priority" \
  --milestone "v1.1.0"

echo "Creating Issue #11: Non-existent Install Script Reference"
gh issue create \
  --title "Create install script" \
  --body "**Priority:** High
**Effort:** 2 hours
**Location:** \`README.md:85\`

**Problem**
References \`tools/install.sh\` which doesn't exist

**Impact**
Users can't use curl installation method

**Acceptance Criteria**
- [ ] Create \`tools/install.sh\` script
- [ ] Script should detect ZSH_CUSTOM directory
- [ ] Handle various installation scenarios (Oh My Zsh, custom paths)
- [ ] Include error handling and user feedback
- [ ] Test on macOS and Linux" \
  --label "jules,enhancement,high priority,installation" \
  --milestone "v1.2.0"

echo "Creating Issue #12: No Error Handling"
gh issue create \
  --title "Add basic error handling" \
  --body "**Priority:** Medium
**Effort:** 30 minutes

**Problem**
No error handling for failed commands or missing dependencies beyond initial check

**Impact**
Silent failures, poor user experience

**Acceptance Criteria**
- [ ] Add error handling for \`codex completion zsh\` failures
- [ ] Handle missing \`shasum\` command gracefully
- [ ] Provide clear error messages to users
- [ ] Test error scenarios (missing codex, permission issues)" \
  --label "jules,enhancement,error handling" \
  --milestone "v1.1.0"

echo "Creating Issue #13: Async Callback Issues"
gh issue create \
  --title "Fix async callback issues" \
  --body "**Priority:** Medium
**Effort:** 1 hour
**Location:** \`codex.plugin.zsh:38-39\`

**Problem**
The async callback function \`codex_update_completions\` is passed to \`async_register_callback\` but may not fire reliably, particularly:
- Potential race condition between worker start and callback registration
- Callback function may not be properly scoped when called asynchronously
- No verification that the callback actually executes successfully

**Impact**
Async completion updates may fail silently, leaving users with stale completions

**Acceptance Criteria**
- [ ] Test async callback functionality with zsh-async
- [ ] Fix any callback registration issues
- [ ] Ensure proper error handling in async context
- [ ] Test fallback behaviour when zsh-async unavailable" \
  --label "jules,bug,async,testing" \
  --milestone "v1.2.0"

# Documentation Issues

echo "Creating Issue #14: Inconsistent Documentation"
gh issue create \
  --title "Improve documentation consistency" \
  --body "**Priority:** Medium
**Effort:** 2 hours

**Problem**
Various typos, inconsistencies, and unclear instructions

**Examples**
- Line 109: \"yuo relaly lvoe typing acucrately\" (intentional humour but unprofessional)
- Line 98: Inconsistent tone throughout

**Acceptance Criteria**
- [ ] Fix all typos and grammatical errors
- [ ] Maintain consistent professional tone
- [ ] Review all installation instructions for clarity
- [ ] Ensure technical accuracy throughout" \
  --label "jules,documentation,cleanup" \
  --milestone "v1.2.0"

echo "Creating Issue #15: Missing Usage Examples"
gh issue create \
  --title "Add usage examples" \
  --body "**Priority:** Medium
**Effort:** 1 hour

**Problem**
No concrete examples of how completions work

**Impact**
Users don't understand the value proposition

**Acceptance Criteria**
- [ ] Add screenshots/recordings of completions in action
- [ ] Include example commands that benefit from completions
- [ ] Show before/after comparison (with/without plugin)
- [ ] Add troubleshooting examples" \
  --label "jules,documentation,examples" \
  --milestone "v1.2.0"

echo "Creating Issue #16: Incomplete Troubleshooting"
gh issue create \
  --title "Complete troubleshooting guide" \
  --body "**Priority:** Low
**Effort:** 1 hour

**Problem**
Limited troubleshooting guidance

**Impact**
Users struggle with issues

**Acceptance Criteria**
- [ ] Add comprehensive troubleshooting section
- [ ] Include common error scenarios and solutions
- [ ] Add debug mode instructions
- [ ] Provide steps for reporting issues" \
  --label "jules,documentation,troubleshooting" \
  --milestone "v1.3.0"

# Missing Infrastructure (High Priority)

echo "Creating Issue #17: No Test Suite"
gh issue create \
  --title "Add test suite foundation" \
  --body "**Priority:** High
**Effort:** 4-6 hours

**Problem**
No tests for plugin functionality

**Impact**
Regressions likely, hard to verify fixes

**Requirements**
- Unit tests for core functions
- Integration tests for ZSH environment
- Mock tests for external dependencies

**Acceptance Criteria**
- [ ] Set up testing framework (bats or similar)
- [ ] Create unit tests for all functions
- [ ] Add integration tests for plugin loading
- [ ] Mock external dependencies (codex CLI)
- [ ] Achieve >80% test coverage" \
  --label "jules,infrastructure,testing,high priority" \
  --milestone "v1.1.0"

echo "Creating Issue #18: No CI/CD Pipeline"
gh issue create \
  --title "Add CI/CD pipeline" \
  --body "**Priority:** High
**Effort:** 2-3 hours

**Problem**
No automated testing or deployment

**Impact**
Manual testing burden, deployment inconsistencies

**Requirements**
- GitHub Actions workflow
- Multi-platform testing (macOS, Linux)
- Automated linting and formatting

**Acceptance Criteria**
- [ ] Create GitHub Actions workflow
- [ ] Test on macOS and Linux
- [ ] Add linting (shellcheck)
- [ ] Add automated formatting checks
- [ ] Run tests on PRs and pushes" \
  --label "jules,infrastructure,ci/cd,high priority" \
  --milestone "v1.1.0"

echo "Creating Issue #19: Missing GitHub Templates"
gh issue create \
  --title "Add GitHub templates" \
  --body "**Priority:** Medium
**Effort:** 1 hour

**Problem**
No issue/PR templates, contributing guidelines

**Impact**
Poor contributor experience, inconsistent reports

**Requirements**
- Issue templates (bug, feature request)
- Pull request template
- CONTRIBUTING.md
- CODE_OF_CONDUCT.md

**Acceptance Criteria**
- [ ] Create bug report template
- [ ] Create feature request template
- [ ] Add pull request template
- [ ] Write CONTRIBUTING.md
- [ ] Add CODE_OF_CONDUCT.md" \
  --label "jules,infrastructure,documentation,community" \
  --milestone "v1.2.0"

echo "Creating Issue #20: No Security Policy"
gh issue create \
  --title "Add security policy" \
  --body "**Priority:** Medium
**Effort:** 30 minutes

**Problem**
No SECURITY.md or vulnerability reporting process

**Impact**
Unclear how to report security issues

**Acceptance Criteria**
- [ ] Create SECURITY.md file
- [ ] Define vulnerability reporting process
- [ ] Include security contact information
- [ ] Add security best practices for contributors" \
  --label "jules,infrastructure,security" \
  --milestone "v1.2.0"

echo "Creating Issue #21: No Formal Release Process"
gh issue create \
  --title "Formalise release process" \
  --body "**Priority:** Medium
**Effort:** 1 hour

**Problem**
No standardised release procedures or versioning guidelines

**Impact**
Inconsistent releases, unclear versioning, missing changelogs

**Requirements**
- Semantic versioning guidelines
- Git tag creation procedures
- GitHub release automation
- Automated changelog generation
- Release testing checklist

**Acceptance Criteria**
- [ ] Document semantic versioning approach
- [ ] Create release automation script
- [ ] Set up automated changelog generation
- [ ] Define release testing checklist
- [ ] Document release procedures" \
  --label "jules,infrastructure,release management" \
  --milestone "v1.2.0"

# Feature Improvements (Medium-Low Priority)

echo "Creating Issue #22: Cross-Platform Notifications"
gh issue create \
  --title "Cross-platform notifications" \
  --body "**Priority:** Medium
**Effort:** 1 hour
**Location:** \`codex.plugin.zsh:31-35\`

**Problem**
Notifications only work on macOS

**Enhancement**
Add Linux notification support (notify-send)

**Acceptance Criteria**
- [ ] Detect platform (macOS vs Linux)
- [ ] Use osascript for macOS notifications
- [ ] Use notify-send for Linux notifications
- [ ] Gracefully handle missing notification systems
- [ ] Test on both platforms" \
  --label "jules,enhancement,cross-platform" \
  --milestone "v1.3.0"

echo "Creating Issue #23: Configuration Options"
gh issue create \
  --title "Configuration options" \
  --body "**Priority:** Low
**Effort:** 2-3 hours

**Problem**
No user configuration options

**Enhancement**
Add configurable options for:
- Notification preferences
- Cache directory location
- Update frequency
- Debug mode

**Acceptance Criteria**
- [ ] Create configuration file format
- [ ] Add notification toggle
- [ ] Allow custom cache directory
- [ ] Add configurable update checking
- [ ] Include debug mode option
- [ ] Document all configuration options" \
  --label "jules,enhancement,configuration" \
  --milestone "v1.3.0"

echo "Creating Issue #24: Debug Mode"
gh issue create \
  --title "Debug mode" \
  --body "**Priority:** Low
**Effort:** 1 hour

**Problem**
No verbose/debug logging

**Enhancement**
Add debug mode for troubleshooting

**Acceptance Criteria**
- [ ] Add CODEX_PLUGIN_DEBUG environment variable
- [ ] Include verbose logging for all operations
- [ ] Show timing information
- [ ] Log file paths and command executions
- [ ] Document debug usage" \
  --label "jules,enhancement,debugging" \
  --milestone "v1.3.0"

echo "Creating Issue #25: Better Error Messages"
gh issue create \
  --title "Better error messages" \
  --body "**Priority:** Low
**Effort:** 1 hour

**Problem**
Generic error messages

**Enhancement**
More specific, actionable error messages

**Acceptance Criteria**
- [ ] Provide specific error messages for each failure scenario
- [ ] Include suggested solutions in error messages
- [ ] Add helpful links to documentation
- [ ] Make error messages user-friendly
- [ ] Test all error conditions" \
  --label "jules,enhancement,user experience" \
  --milestone "v1.3.0"

# Architecture Improvements (Future)

echo "Creating Issue #26: Plugin Manager Compatibility"
gh issue create \
  --title "Plugin manager compatibility" \
  --body "**Priority:** Low
**Effort:** 2 hours

**Problem**
Only documented for Oh My Zsh

**Enhancement**
Add support documentation for:
- Zinit
- Zplug
- Antigen
- Manual installation

**Acceptance Criteria**
- [ ] Document Zinit installation
- [ ] Document Zplug installation
- [ ] Document Antigen installation
- [ ] Add manual installation guide
- [ ] Test with each plugin manager" \
  --label "jules,enhancement,documentation,compatibility" \
  --milestone "v2.0.0"

echo "Creating Issue #27: Performance Monitoring"
gh issue create \
  --title "Performance monitoring" \
  --body "**Priority:** Low
**Effort:** 2 hours

**Problem**
No performance metrics

**Enhancement**
Add timing and performance tracking

**Acceptance Criteria**
- [ ] Track plugin load time
- [ ] Monitor completion generation time
- [ ] Add performance logging
- [ ] Create performance benchmarks
- [ ] Identify optimisation opportunities" \
  --label "jules,enhancement,performance" \
  --milestone "v2.0.0"

echo "Creating Issue #28: Update Mechanism"
gh issue create \
  --title "Update mechanism" \
  --body "**Priority:** Low
**Effort:** 3-4 hours

**Problem**
No self-update capability

**Enhancement**
Add plugin self-update functionality

**Acceptance Criteria**
- [ ] Check for plugin updates
- [ ] Download and install updates
- [ ] Handle update conflicts gracefully
- [ ] Provide update notifications
- [ ] Support rollback mechanism" \
  --label "jules,enhancement,update system" \
  --milestone "v2.0.0"

echo ""
echo "All 22 issues created successfully!"
echo ""
echo "Next steps:"
echo "  1. Review the created issues on GitHub"
echo "  2. Assign issues to team members"
echo "  3. Start with v1.1.0 milestone issues"
echo "  4. Create projects/boards for better tracking"
echo ""
echo "Summary:"
echo "  - Critical issues: 1"
echo "  - High priority: 6"
echo "  - Medium priority: 8"
echo "  - Low priority: 7"
echo "  - Total issues: 22"
echo ""
echo "View all issues: https://github.com/$(gh repo view --json nameWithOwner -q .nameWithOwner)/issues"
