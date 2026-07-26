# requirement_color_design.md

# fastVocab Color and Design Requirements v1.2

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
- exploration,
- progress,
- consistency,
- simplicity,
- positive reinforcement,
- long-term engagement.

The application shall provide a calm and productive learning environment suitable for long study sessions.

The visual identity of fastVocab follows the philosophy:

> Coastal Mediterranean × Coastal Vietnam × Positive Learning Journey

The application shall feel:

- calm,
- warm,
- modern,
- encouraging,
- productive,
- lightweight,
- mature,
- enjoyable,
- exploratory.

The application shall prioritize learning progress over visual complexity.

The application shall communicate the feeling of exploring beautiful coastal places while learning new languages.


---

## 3. Design Principles

The application shall follow the following principles.

### Principle 1 - One Task at a Time

The user interface shall present one primary learning objective at a time.

The application should avoid:

- multiple competing actions,
- excessive visual elements,
- unnecessary distractions.

### Principle 2 - Positive Learning Journey

The application shall provide constructive and encouraging feedback whenever possible.

The user experience shall emphasize:

- progress,
- completion,
- achievements,
- exploration,
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
- exploration,
- disabled states,

through consistent visual representations.


---

## 4. Color Philosophy

The application shall follow the principle:

> Three Primary Colors + Two Accent Colors + Neutral Colors

The visual identity of fastVocab shall be defined by:

- three primary colors,
- two accent colors,
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
let vungtau_palette = [

    "front_beach_blue" : "#3F8EBF",
    "con_phung_jade"  : "#2D5955",
    "golden_sand"     : "#F2C48D"

]
```

| Name | Hex | Purpose |
|------|-----|---------|
| Front Beach Blue | #3F8EBF | Learning, navigation and primary interactions |
| Con Phung Jade | #2D5955 | Progress, success and positive feedback |
| Golden Sand | #F2C48D | Rewards, motivation and achievements |

### Front Beach Blue

Represents:

- learning,
- exploration,
- navigation,
- focus.

### Con Phung Jade

Represents:

- progress,
- success,
- improvement,
- lesson completion.

### Golden Sand

Represents:

- rewards,
- achievements,
- motivation,
- celebration.

Golden Sand should be used sparingly to preserve its visual significance.


---

## 6. Accent Color Palette

```swift
let accent_palette = [

    "coastal_sunset" : "#D98C5F",
    "marine_moss"    : "#235048"

]
```

| Name | Hex | Purpose |
|------|-----|---------|
| Coastal Sunset | #D98C5F | Constructive feedback and reflection |
| Marine Moss | #235048 | Nature and exploration accents |

### Coastal Sunset

Represents:

- constructive feedback,
- continuous improvement,
- learning opportunities,
- supportive guidance.

Coastal Sunset shall not represent punishment or failure.

### Marine Moss

Represents:

- exploration,
- discovery,
- calmness,
- coastal nature.

Marine Moss should be utilized sparingly to preserve its semantic meaning.


---

## 7. Neutral Color Palette

```swift
let neutral_palette = [

    "background"      : "#F2E4D8",
    "card"            : "#FFFFFF",

    "text_primary"   : "#2F3E46",
    "text_secondary" : "#8EA6B1",

    "border"         : "#D6DDE2",
    "disabled"       : "#D6DDE2"

]
```

| Name | Hex | Purpose |
|------|-----|---------|
| Nghinh Phong Chalk | #F2E4D8 | Main application background |
| Pure White | #FFFFFF | Cards and containers |
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

The visual language should evoke:

- coastal landscapes,
- relaxation,
- exploration,
- positive learning experiences.


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

- Front Beach Blue,
- Con Phung Jade when indicating successful progression.

### Progress Indicators

Progress indicators should utilize:

- Con Phung Jade.

### Rewards and Achievements

Rewards should utilize:

- Golden Sand.

### Constructive Feedback

Constructive feedback should utilize:

- Coastal Sunset.

Examples include:

- mistake review,
- warnings,
- lesson cancellation confirmations,
- supportive instructional messages,
- game over presentations.

### Exploration Accents

Exploration accents should utilize:

- Marine Moss.

Examples include:

- decorative illustrations,
- discovery related UI components,
- future travel inspired themes.

### Background Components

Background elements should primarily utilize:

- Nghinh Phong Chalk,
- Pure White,
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

- Front Beach Blue for learning,
- Con Phung Jade for progress,
- Golden Sand for rewards,
- Coastal Sunset for constructive feedback.

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

### Guideline 4 - Multiple Colors Are Permitted When Semantically Appropriate

A view may utilize multiple semantic colors when each communicates distinct meanings.

Examples include:

#### Home Page

- Front Beach Blue for learning,
- Golden Sand for achievements.

#### Game Page

- Con Phung Jade for lesson progression,
- Coastal Sunset for constructive feedback,
- Neutral colors for supporting components.

#### Score Page

- Golden Sand for rewards,
- Con Phung Jade for successful lesson completion,
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

- the color philosophy,
- the positive learning journey philosophy,
- visual consistency,
- minimal cognitive load,
- cross-platform consistency.

Future themes and dark mode implementations shall preserve the semantic meaning of all colors.


---

## 13. Acceptance Criteria

The color and design requirements shall be considered satisfied when:

- only the defined primary palette is utilized for primary visual interactions,
- Coastal Sunset is consistently utilized for constructive feedback,
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

                 Coastal Mediterranean
                              +
                    Coastal Vietnam
                              +
                 Positive Learning Journey
                              |
                           Learn
                              |
                     Front Beach Blue
                              |
                          Progress
                              |
                      Con Phung Jade
                              |
                    Rewards & Motivation
                              |
                        Golden Sand
                              |
                    Reflection & Improvement
                              |
                       Coastal Sunset
                              |
                    Exploration & Discovery
                              |
                         Marine Moss
                              |
                        Neutral Colors
                              |
                  Background • Text • UI
                              |
                     Calm Learning Journey
```

> ### Design Philosophy
>
> **Coastal Mediterranean × Coastal Vietnam × Positive Learning Journey**
>
> fastVocab shall provide a calm, modern and encouraging learning experience that emphasizes exploration, progress, simplicity and long-term engagement while evoking the feeling of traveling through beautiful coastal places.
