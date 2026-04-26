high_performance_feed

A Flutter project for a high performance social media feed.

Overview

This app shows an infinite scrolling feed with focus on speed, smooth UI, and low memory usage.
Built using Flutter, Riverpod, and Supabase.

Features
Infinite scrolling (pagination)
Pull to refresh
Optimized UI using RepaintBoundary
Memory optimized image loading
Hero animation to detail screen
Like button with instant update (optimistic UI)
Handles offline and fast multiple clicks
Tech Stack
Flutter
Riverpod
Supabase (Database, Storage, RPC)
Performance
Used RepaintBoundary to reduce GPU load
Used cacheWidth / memCacheWidth to control image size
Used thumbnail images in feed
Smooth scrolling without lag
Like System
UI updates instantly
Backend sync using Supabase RPC
Handles rapid clicks safely
Reverts UI if request fails
How to Run
Clone project
Add Supabase keys
Run:
flutter pub get
flutter run
Notes

This project focuses on performance, clean UI, and proper state management.
