---
title: "Blog post"
description: "A long-form post with byline, reading time, tags and share links."
layout: post
twin: false
sitemap: false
search: false
noindex: true
nav_exclude: true
edit: false
sections: []
date: "2026-10-20 09:00:00 +0900"
author: modootoday
categories: [guides]
tags: [design, dark-mode]
deck: "How we picked one set of colour tokens that reads well on paper white and on OLED black."
---
# Choosing colours that survive dark mode

Our first dark theme simply inverted the light palette. Body text looked fine, but links turned neon, borders vanished and code blocks glowed. This post walks through the three rules we use now.

## Start from contrast, not from hue

Every text token is checked against its background at 4.5:1 and every border at 3:1. We pick the hue last, once the lightness is right.

## Lower saturation as the background darkens

A blue that is calm on white vibrates on near-black. The dark palette keeps the same hues with about 20% less chroma.

## Test with real content

Tables, callouts and syntax-highlighted code catch problems that a colour swatch never shows. Open the [kitchen sink](#) in both themes before you ship a change.

> Rule of thumb: if you notice the colour before the words, it is too strong.
