# requirement_color_design.md

# fastVocab Color and Design Requirements v1.1

## 1. Purpose

This document defines the color palette, visual philosophy and design requirements for fastVocab.

The objectives are to:

- provide a calm and enjoyable learning experience,
- encourage long-term vocabulary learning habits,
- minimize cognitive load,
- provide clear and consistent visual feedback,
- maintain a modern and approachable visual identity,
- preserve design consistency across all supported platforms.

This document is technology agnostic and applies to all implementations of fastVocab.


---

## 2. Design Philosophy

fastVocab shall emphasize:

- learning,
- progress,
- consistency,
- simplicity,
- positive reinforcement.

The application shall provide a calm and productive learning environment suitable for long study sessions.

The visual identity of fastVocab follows the philosophy:

> Greek Mediterranean × Modern Minimalism × Positive Learning

The application shall feel:

- calm,
- warm,
- modern,
- encouraging,
- productive,
- lightweight,
- mature,
- enjoyable.

The application shall prioritize learning progress over visual complexity.


---

## 3. Design Principles

The application shall follow the following principles.

### Principle 1 - One Task at a Time

The user interface shall present one primary learning objective at a time.

The application should avoid:

- multiple competing actions,
- excessive visual elements,
- unnecessary distractions.

### Principle 2 - Positive Learning Experience

The application shall provide constructive and encouraging feedback whenever possible.

The user experience shall emphasize:

- progress,
- completion,
- achievements,
- continuous improvement.

Incorrect answers shall be presented as learning opportunities rather than failures.

### Principle 3 - Calm and Minimal Interface

The application shall:

- utilize generous whitespace,
- minimize visual clutter,
- maintain visual consistency,
- prioritize readability and accessibility.

### Principle 4 - Consistent Visual Language

Colors shall communicate meaning consistently throughout the application.

Users should be able to recognize:

- learning,
- progress,
- rewards,
- constructive feedback,
- navigation,
- disabled states,

through consistent visual representations.


---

## 4. Color Philosophy

The application shall follow the principle:

> Three Primary Colors + One Secondary Accent Color + Neutral Colors

The visual identity of fastVocab shall be defined by:

- three primary colors,
- one secondary accent color,
- a neutral color palette.

Neutral colors shall support:

- backgrounds,
- texts,
- borders,
- disabled states,
- secondary UI components.

Additional primary colors shall not be introduced unless explicitly required by future product requirements.


---

## 5. Primary Color Palette

```swift
let greek_palette = [

    "aegean_blue" : "#4F86C6",
    "olive_green": "#8FA76B",
    "golden_sand": "#E9C46A"

]
```

| Name | Hex | Purpose |
|------|-----|---------|
| Aegean Blue | #4F86C6 | Learning, navigation and primary interactions |
| Olive Green | #8FA76B | Progress, success and positive feedback |
| Golden Sand | #E9C46A | Rewards, motivation and achievements |

### Aegean Blue

Represents:

- learning,
- navigation,
- focus,
- progression.

### Olive Green

Represents:

- success,
- improvement,
- lesson completion,
- encouragement.

### Golden Sand

Represents:

- rewards,
- achievements,
- motivation,
- celebration.

Golden Sand should be used sparingly to preserve its visual significance.


---

## 6. Secondary Accent Color Palette

```swift
let accent_palette = [

    "terracotta" : "#D98C5F"

]
```

| Name | Hex | Purpose |
|------|-----|---------|
| Terracotta | #D98C5F | Constructive feedback, mistake review and warnings |

### Terracotta

Represents:

- continuous improvement,
- constructive feedback,
- learning opportunities,
- reflection,
- supportive guidance.

Terracotta shall be utilized when communicating that users have additional opportunities to improve their learning outcomes.

Terracotta shall not represent failure or punishment.


---

## 7. Neutral Color Palette

```swift
let neutral_palette = [

    "background"      : "#F1F3F4",
    "card"            : "#FFFFFF",

    "text_primary"   : "#2F3E46",
    "text_secondary" : "#8EA6B1",

    "border"         : "#D6DDE2",
    "disabled"       : "#D6DDE2"

]
```

| Name | Hex | Purpose |
|------|-----|---------|
| Background | #F1F3F4 | Main application background |
| Card | #FFFFFF | Cards and containers |
| Primary Text | #2F3E46 | Main text |
| Secondary Text | #8EA6B1 | Secondary information |
| Border | #D6DDE2 | Borders and separators |
| Disabled | #D6DDE2 | Disabled states |


---

## 8. Visual Requirements

The application shall:

- utilize generous whitespace,
- use rounded and approachable components,
- prioritize readability,
- maintain visual consistency across pages,
- minimize unnecessary visual complexity.

The application should avoid:

- excessive visual effects,
- unnecessary animations,
- cluttered layouts,
- visually overwhelming interfaces.

The interface should remain comfortable during extended learning sessions.


---

## 9. Feedback Requirements

Positive feedback shall feel:

- rewarding,
- encouraging,
- calm,
- satisfying.

Constructive feedback shall feel:

- educational,
- supportive,
- respectful,
- helpful.

The application shall prioritize positive reinforcement whenever appropriate.

Visual feedback shall remain subtle and consistent throughout the application.


---

## 10. Usage Requirements

### Primary Actions

Primary actions should utilize:

- Aegean Blue,
- Olive Green when indicating successful progression.

### Progress Indicators

Progress indicators should utilize:

- Olive Green.

### Rewards and Achievements

Rewards should utilize:

- Golden Sand.

### Constructive Feedback

Constructive feedback should utilize:

- Terracotta.

Examples include:

- mistake review,
- warnings,
- lesson cancellation confirmations,
- supportive instructional messages,
- game over presentations.

### Background Components

Background elements should primarily utilize:

- Background,
- Card,
- Neutral colors.

### Disabled Components

Disabled components should utilize:

- Disabled,
- Secondary text colors.


---

## 11. Color Usage Guidelines

The application shall prioritize semantic color usage over the number of colors utilized within a view.

Colors shall communicate meaning consistently throughout the application.

### Guideline 1 - One Dominant Semantic Color

Each view should utilize one dominant semantic color representing its primary purpose.

Examples include:

- Aegean Blue for learning and navigation,
- Olive Green for progress and success,
- Golden Sand for rewards and achievements,
- Terracotta for constructive feedback and reflection.

### Guideline 2 - Neutral First Design

Neutral colors should occupy the majority of the user interface.

Neutral colors should primarily be utilized for:

- backgrounds,
- cards,
- texts,
- borders,
- secondary components,
- disabled states.

### Guideline 3 - Accent Colors Should Be Used Sparingly

Accent colors should communicate meaningful information only.

Colors shall not be introduced solely for decorative purposes.

Accent colors should emphasize:

- progress,
- achievements,
- rewards,
- constructive feedback,
- important interactions.

### Guideline 4 - Multiple Colors Are Permitted When Semantically Appropriate

A view may utilize multiple primary colors when each color communicates a distinct semantic meaning.

Examples include:

#### Home Page

- Aegean Blue for learning and navigation,
- Golden Sand for achievements and streaks.

#### Game Page

- Olive Green for lesson progression,
- Terracotta for constructive feedback,
- Neutral colors for all supporting components.

#### Score Page

- Golden Sand for rewards and achievements,
- Olive Green for successful lesson completion,
- Neutral colors for supporting information.

### Guideline 5 - Recommended Color Distribution

The application should approximately follow the following distribution whenever appropriate:

```text
60%
-----
Neutral Colors


30%
-----
Dominant Semantic Color


10%
-----
Accent Colors
```

This distribution is intended as a design guideline rather than a strict requirement.

The application shall prioritize usability and semantic consistency over numerical color restrictions.


---

## 12. Future Compatibility

Future features shall preserve:

- the three-primary-color philosophy,
- the secondary accent color philosophy,
- positive learning experiences,
- visual consistency,
- minimal cognitive load,
- cross-platform consistency.

Future themes and dark mode implementations shall preserve the semantic meaning of all primary and accent colors.


---

## 13. Acceptance Criteria

The color and design requirements shall be considered satisfied when:

- only the defined primary palette is utilized for primary visual interactions,
- Terracotta is consistently utilized for constructive feedback scenarios,
- neutral colors are consistently applied,
- visual feedback remains calm and encouraging,
- learning progress is clearly communicated,
- the interface remains comfortable during extended usage,
- the visual identity remains consistent across supported platforms,
- users are presented with one primary learning objective at a time,
- semantic color meanings remain consistent throughout the application.


---

## 14. Summary

```text
                        fastVocab

                  Greek Mediterranean
                             +
                     Modern Minimalism
                             +
                      Positive Learning
                             |
                         Learning
                             |
                      Aegean Blue
                             |
                          Progress
                             |
                       Olive Green
                             |
                   Rewards & Motivation
                             |
                      Golden Sand
                             |
                 Reflection & Improvement
                             |
                        Terracotta
                             |
                       Neutral Colors
                             |
                  Background • Text • UI
                             |
                   Calm Learning Experience
```

> ### Design Philosophy
>
> **Greek Mediterranean × Modern Minimalism × Positive Learning**
>
> fastVocab shall provide a calm, consistent and encouraging learning experience that emphasizes progress, simplicity and long-term engagement.

```
