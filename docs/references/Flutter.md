# Flutter Reference

## Purpose

Quick Flutter development guidelines.

---

# Preferred Widgets

- MaterialApp
- Scaffold
- CustomScrollView
- ListView.builder
- SliverAppBar
- Card
- FilledButton
- NavigationBar

---

# State Management

Riverpod

Avoid:

- setState for large features
- Global mutable state

---

# Widget Rules

Prefer:

- StatelessWidget
- Small widgets
- Reusable widgets

Avoid:

- Giant build methods
- Deep widget nesting

---

# Performance

Prefer:

- const constructors
- ListView.builder
- Lazy loading
- Efficient rebuilds

---

# Theme

Always use ThemeData.

Never hardcode:

- Colors
- Typography
- Radius
- Padding

---

# Folder Structure

Feature-first.

Every feature owns:

- screens
- widgets
- providers
- repositories
- models

---

# Goal

Build maintainable Flutter code that feels native on Android.