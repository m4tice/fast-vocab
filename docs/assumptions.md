# fastVocab PoC Assumptions

Status: Frozen for PoC implementation  
Authority: `docs/requirements/req_poc_final.md` v1.4

This document records the simplest implementation choices made where the authoritative requirements intentionally do not prescribe behavior. These choices clarify the PoC; they do not add product scope.

## A-001: Initial Content

The bundled PoC catalog contains curated German-to-English vocabulary. The engine stores language codes in content, but the PoC does not provide language selection or localization features.

## A-002: Topic Lesson Size

A lesson uses every valid vocabulary item in its selected topic exactly once during the main phase. A selectable topic must contain at least three valid items.

## A-003: Exercise Assignment

Main questions cycle deterministically through article, plural, and translation. This guarantees all supported types in every lesson without random gaps, adaptive weighting, or stored generation rules.

## A-004: Question Order

The main question order is the order of items in the selected vocabulary topic. It is persisted in the session. Randomization is not necessary to satisfy the PoC.

## A-005: Review Exercise

Each review item uses the same exercise type assigned to that item in the main phase. Review order is the order in which unique mistakes first occurred.

## A-006: XP Value

Each correct main-phase answer awards 10 XP. Review answers award zero XP. No bonus, level, streak, or multiplier is calculated.

## A-007: Text Answer Matching

Plural and translation answers are trimmed, Unicode-normalized, and compared case-insensitively. Any listed translation is valid. Typo tolerance and fuzzy matching are excluded.

## A-008: Article Choices

Article options come from the distinct article values in the selected topic and always include the correct value. The initial German catalog supplies `der`, `die`, and `das`.

## A-009: Feedback Advancement

After a non-terminal answer, the Game page displays feedback until the user chooses Continue. Feedback is transient and is not recovered. A main-phase wrong answer that reaches zero hearts terminates immediately and navigates to Score.

## A-010: Pause Behavior

Pause is available only while a question is being presented at a durable boundary. It is unavailable during answer feedback. Pausing saves the session and returns Home, where Resume is shown.

## A-011: Interruption Behavior

When the application backgrounds or terminates, only the most recently saved question boundary is recoverable. Unsaved typed text, selection, feedback, and animation state are intentionally lost.

## A-012: Cancellation and User Progress

Session statistics and XP remain staged until completion or game over. Cancelling from Main or Review removes the session snapshot and staged progress, so global user progress is unchanged.

## A-013: Game Over Progress

Game over commits statistics and XP earned before termination to user progress, then presents Score. It does not present Review.

## A-014: Correct and Wrong Counts

Lesson and vocabulary wrong counts include every incorrect occurrence in Main and Review. Correct counts likewise record correct occurrences by phase. The recorded mistake list remains a separate unique list of vocabulary items.

## A-015: One Active Lesson

A recoverable paused or interrupted lesson counts as the one active lesson. Home offers Resume, and a new lesson cannot start until that lesson completes, reaches game over, or is cancelled.

## A-016: Score Exit

The Score page has a Home action. Starting another lesson happens through Home and Topic Selection; a separate retry flow is not required.

## A-017: Error Presentation

Errors use alerts or inline states within the five required pages. No separate error page is introduced. If vocabulary is unavailable, Splash remains visible with Retry and lesson creation stays blocked.

## A-018: Vocabulary Source Validity

A vocabulary source is usable when its schema decodes and it contains at least one valid topic with three valid items. Invalid local data falls through to the next source. API failure is irrelevant when cache or bundle data is usable.

## A-019: Cache Meaning

Cache means previously validated API vocabulary stored in Core Data. Bundled JSON remains an independent fallback and need not be copied into Core Data on every launch.

## A-020: User Progress Commit

Completion and game-over commits atomically save the lesson result, merge XP and vocabulary statistics, and remove the recoverable snapshot. This prevents a restored terminal session from awarding progress twice.

## A-021: Persistence Failure

If a required save fails, the app keeps its current in-memory state and presents a retryable error. It does not report durable completion until persistence succeeds.

## A-022: Backend Configuration

The API base URL is an implementation configuration. No default backend connection is needed for bundled offline operation, and no backend setup is required to run client tests or lessons.

## A-023: Supported Devices

The existing project deployment target remains iOS 18.2 unless implementation discovers a concrete compatibility reason to lower it. The existing target supports iPhone and iPad, so the PoC uses adaptive layouts in supported orientations and supports light and dark appearance.

## A-024: Existing Template Data

The generated SwiftData `Item` model contains no product data. It can be removed without migration when Core Data is introduced.

## A-025: Optional Backend Refresh

The mandatory source order is evaluated when usable vocabulary is needed. Fetching supplemental API content after successful local startup is not required for the PoC.

## A-026: Data Retention

Lesson result history and vocabulary statistics are retained locally across launches. No account, cloud synchronization, export, analytics, or remote retention is assumed.

## A-027: Cancel Confirmation

Cancel requires confirmation because it irreversibly discards the active lesson and its staged progress. Dismissing the confirmation leaves the lesson unchanged.

## A-028: Standard iOS Accessibility

The PoC follows standard SwiftUI accessibility practices, including semantic labels, Dynamic Type, and feedback that does not rely on color alone. These practices do not add a page or product feature.