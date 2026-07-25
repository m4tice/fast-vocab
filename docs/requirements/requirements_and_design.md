# Vocabulary Article/Plural Trainer — Requirements & Design Draft

Working name: **ArtikelUp** (placeholder)

---

## 1. Vision (highest abstraction)

A Duolingo-style gamified iOS app that drills grammatical gender/article and plural forms for vocabulary, starting with German (der/die/das), built on a language-agnostic core so new languages (French le/la, Spanish el/la, Italian il/la, etc.) can be added as content packs, not rewrites.

---

## 2. Functional Requirements

### 2.1 Core learning loop
- FR1: Present a word, user selects correct article (multiple choice / tap).
- FR2: Present a word, user types or selects the correct plural form.
- FR3: Mixed review combining article + plural + translation recall.
- FR4: Spaced repetition scheduling per word per user (not just per lesson).
- FR5: Adaptive difficulty — weight toward words the user gets wrong.

### 2.2 Gamification (Duolingo-parity)
- FR6: XP per exercise, daily streak counter, streak freeze mechanic.
- FR7: Hearts/lives system with regeneration or practice-to-refill.
- FR8: Skill tree / path map as home screen (topics unlock sequentially or by prerequisite).
- FR9: Achievements/badges (e.g., "100 der-words mastered").

### 2.3 Social / competitive (per your scope choice)
- FR10: Friends list, add/search users.
- FR11: Weekly leaderboard leagues (promotion/demotion tiers like Duolingo).
- FR12: Optional async challenges between friends (e.g., "beat my score on this deck").

### 2.4 Content & extensibility
- FR13: Built-in curated word decks, organized by topic (food, travel, work, etc.) and by grammar difficulty (e.g., German: regular vs. exception plurals).
- FR14: Language module abstraction — each language defines its own article set and plural rule types, so the exercise engine stays generic.
- FR15: **AI-assisted content curation tool** (admin/content-creator side, not runtime): given a topic, AI proposes candidate word + article + plural + example sentence. A human curator must approve before it ships into the app.
  - Non-negotiable: no AI-generated word enters the live deck unverified. Gender/plural is exactly what the app teaches — a wrong answer in the source data silently corrupts learning. This needs a review step, not blind trust.

---

## 3. Non-Functional Requirements

- NFR1: Core learning loop must work fully offline; sync XP/streak/leaderboard on reconnect.
- NFR2: New language = new content pack + rule config, no app-binary changes for exercise logic.
- NFR3: UI localized separately from target/study language (a Vietnamese speaker studying German is a real case here).
- NFR4: Social features imply user accounts → GDPR-relevant data handling (EU users), Apple Sign-In support, minimal PII.
- NFR5: Leaderboard/social requires low-latency backend reads — plan for this explicitly (see open questions).

---

## 4. System Architecture

**Client (iOS)**
- SwiftUI + MVVM + Combine, Core Data for local cache/offline state — matches your existing stack from the Odd-One-Out project.
- Local-first: exercises, SRS state, streak logic run client-side against cached decks.

**Backend (new — required for FR10–FR12)**
- Auth, user profiles, friend graph, leaderboard aggregation.
- Sync service for XP/streak/progress across devices.
- Not optional once social/leaderboards are in scope — CloudKit's public database can approximate this but is limited for real-time competitive leaderboards at scale; a proper backend (custom REST/GraphQL, or Firebase-style BaaS) is the more realistic path. This is a real infra decision, not a detail to defer.

**Content pipeline (offline, admin-side)**
- AI-suggestion tool → curator review UI → versioned, signed content packs → published to app (bundled or downloaded).

---

## 5. Data Model (core entities)

- `Language` — id, display name, UI direction, etc.
- `LanguageRuleSet` — article set (e.g., der/die/das), plural pattern types, exceptions handling, linked to `Language`.
- `Word` — lemma, language, article/gender, plural form, translations, topic tags, difficulty tier, source (curated/AI-suggested-approved), example sentence.
- `Deck/Topic` — ordered set of `Word`s, prerequisite deck(s).
- `User` — auth id, profile, UI language.
- `UserWordProgress` — per user/word SRS state (interval, ease, last reviewed, error count).
- `StreakState`, `XPLedger`, `Hearts` — per user.
- `FriendEdge` — user-to-user relationship.
- `LeagueMembership` — user, league tier, week, rank.
- `Achievement`, `UserAchievement`.

---

## 6. UI/UX Screens

1. Home / path map (skill tree, Duolingo-style).
2. Lesson/exercise screen (article picker, plural input, mixed review).
3. Result/summary screen (XP gained, streak status, mistakes review).
4. Profile (stats, achievements, streak history).
5. Leaderboard / league view.
6. Friends (list, add, challenge).
7. Content browser (topics/decks, locked/unlocked state).

---

## 7. Tech Stack (proposed, aligned to your current setup)

- **Client:** Swift, SwiftUI, MVVM, Combine, Core Data (local persistence + offline queue), Swift Concurrency (async/await) for networking.
- **Backend:** TBD — options: (a) Firebase/Supabase for speed to MVP, (b) custom Node/Python service for control over leaderboard logic and future AI content pipeline integration.
- **Content pipeline:** could run as a separate internal tool (Python is fine here) using an LLM API for suggestion generation, output as JSON reviewed by a curator before packaging into the app's content bundle.

---

## 8. Open Questions / Risks (flagging now, not later)

- **Backend choice is unresolved and blocks FR10–FR12.** This is the single biggest scope item you added versus a personal-tool version of this app — social features are backend-heavy, not a client-side add-on.
- **Monetization** wasn't specified. App Store release with social features usually implies subscription/IAP to cover backend costs — worth deciding before backend architecture, since it affects auth/entitlement design.
- **Content licensing/IP**: curated word lists (translations, example sentences) — confirm you're building original content or using a properly licensed dictionary source, not scraping.
- **AI suggestion accuracy for German plurals/gender is a known weak spot for LLMs** (exceptions are numerous) — budget real curator time, don't assume the AI step reduces work to near-zero.

---

## 9. Suggested MVP cut (if useful)

Ship without social first (FR10–12 deferred), validate core loop + gamification + content pipeline, then add backend/social in v2. Cheaper to de-risk the harder infra decision after the learning loop itself is proven fun. Your call — you already chose full scope, just flagging this as the lower-risk sequencing if timeline pressure shows up later.