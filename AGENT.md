# Barnkeeper Agent Coordination Guide

## Purpose
This document guides all agents (AI and human) collaborating on the Barnkeeper project. It focuses on coordination, workflow, and communication to ensure smooth collaboration.

## Project Reference
- All technical requirements, features, and implementation guidelines are in `ampcode-prompt.md`
- This is a multi-tenant horse management application built with Elixir, Phoenix, Postgres (Supabase), Tailwind CSS, and DaisyUI

## Agent Roles & Responsibilities

### Subagent Coordination
- Each subagent is responsible for their assigned domain (see ampcode-prompt.md)
- **Must coordinate for integration** - this is critical for success
- All agents must follow the coding, testing, and documentation standards in the main prompt

### Communication Requirements
- Report progress, blockers, and integration needs clearly
- Surface integration issues early for group resolution
- Provide regular status updates with test results and screenshots

## Workflow & Collaboration

### Development Process
- Use feature branches for major features or fixes
- Write clear, descriptive commit messages
- Run tests frequently and report results
- Take screenshots at key milestones for visibility

### Code Reviews & Integration
- All major changes should be reviewed by at least one other agent
- Use pull requests for discussion and feedback
- Regularly merge and test with main branch to avoid integration issues
- Resolve merge conflicts promptly and collaboratively

### Quality Gates
- All code must pass Elixir formatter (`mix format --check-formatted`)
- All tests must pass (`mix test`)
- No compiler warnings (`mix compile --warnings-as-errors`)
- All database migrations must be reversible

## Local Development Setup
- Ensure app runs at http://localhost:4000
- Use asdf and .tool-versions file for dependency management
- Follow Phoenix conventions for structure and configuration
- Update README with any setup or dependency changes

## Reporting & Progress

### Status Updates
- Provide regular status updates in project channel or via PRs
- Include test results and screenshots as part of progress reports
- Report any architectural or process decisions that affect other agents

### Blockers & Issues
- Surface blockers or integration issues early
- Request clarification if requirements are unclear
- Don't consider tasks complete until receiving explicit approval

## Handover & Onboarding

### Handover Process
- When completing a feature, provide summary and onboarding notes
- Document any manual steps or commands required
- Include screenshots and test results in handover

### Onboarding
- New agents should read this file and ampcode-prompt.md before starting
- Review existing codebase and test suite
- Understand the multi-tenant architecture and data isolation requirements

## Contact & Support
- Use designated project communication channel for questions
- Tag project lead for clarifications or support
- Collaborate openly on integration challenges

## Key Success Factors
- **Clear communication** about progress and blockers
- **Regular integration** to avoid merge conflicts
- **Quality focus** - don't merge code that doesn't meet standards
- **Documentation** of decisions and handover information
- **Testing** at every stage with screenshots for visibility

Remember: The goal is to build a maintainable, high-quality application through effective coordination, clear communication, and rigorous standards.