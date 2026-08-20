# ADR-003: Drift SQLite as Local Source of Truth

- **Status:** Accepted
- **Date:** 2026-06-25
- **Deciders:** Architecture Team

## Context
College students frequently encounter spotty campus Wi-Fi, underground lecture halls, and zero-connectivity environments. The app cannot block or stall when network connectivity drops.

## Decision
Design an **offline-first** architecture where **Drift SQLite** is the definitive local source of truth. All UI screens read from local SQLite stream providers, and all mutations write to SQLite first before being enqueued to a local FIFO sync queue.

## Consequences
- **Positive:** Zero latency UI updates, 100% offline functionality, compile-safe SQL queries, reactive stream subscriptions.
- **Negative:** Requires background queue processing and conflict resolution logic.
