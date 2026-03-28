---
description: Maintain and Document New Behaviors and Interactions
---
# Document Behaviors Skill

## Overview
As the primary AI building out the Mac Control Center app, you are responsible for keeping the documentation in sync with all real-world code behaviors.

Whenever a structural change, new interaction, or fundamental new behavior is implemented within the Swift application, you **MUST** ensure the `BEHAVIORS.md` file located at the project's root is updated with the relevant changes.

## Procedure
1. If you add a feature, re-write a state flow (like window dragging or dot expansion), or implement something new (like a hover state for traffic lights):
2. Open `/BEHAVIORS.md` and read the current contents.
3. Append or insert the new behaviors in a concise, human-readable format, exactly detailing what triggers the behavior and what the expected visual output is.
4. After updating the code, mention updating `BEHAVIORS.md` in your final Walkthrough or wrap-up.

## Why?
MacOS applications heavily rely on native APIs and state management that isn't always immediately obvious to a new pair of eyes. This document serves as the project's institutional memory, meaning we will never lose track of *how* or *why* a specific UI element behaves the way it does.
