# Fried — Hooks & Scripts (production fuel)

Config: faceless · pre-launch · $0 · lean-in-hard. Pairs with `PLANNING/GROWTH-OS.md`.

**Rules baked in:** hook in frame 1 (on-screen text + said aloud) · **declarative, never a question** ("?" hooks ~8% survival) · payoff fast · flash the absurd number (replay moment) · drop the app name ~60% through · loop the ending · works sound-off.

**Pre-launch CTA menu** (rotate — we're not live yet, so we drive to waitlist/follow, not installs):
- "it's not out yet — link in bio to get it first."
- "comment your guess, then get on the list."
- "follow so you're first when it drops."
- "@getfried — early access in bio."

---

## 50 hooks (first frame: on-screen text, also spoken)

### A. The number (Score Reveal — our #1)
1. "This app says my brain is 47. I'm 19."
2. "My brain age came back older than my dad's."
3. "I'm 21. My brain is 50. I have to lie down."
4. "It found 5 things wrong with my brain in 60 seconds."
5. "More fried than 92% of people my age. Cool. Cool cool cool."
6. "I scored 'Deep Fried.' That's the worst one."
7. "My focus score is a 12. Out of 100."
8. "I took a brain rot test and it humbled me instantly."
9. "It rated my brain and I'm not okay."
10. "The number it gave me should be illegal."

### B. Confession / POV (relatable, lean-in)
11. "POV: you check how fried your brain is and it's worse than you thought."
12. "not to be dramatic but scrolling actually broke my brain."
13. "I can't watch a movie without my phone anymore. So I checked why."
14. "I've opened 3 apps since you started reading this."
15. "me pretending I don't have brain rot → [the score]."
16. "I haven't finished a single video this week. Including my own."
17. "my attention span filed for divorce."
18. "I checked how cooked I am and immediately regretted it."
19. "I thought I was fine. The test disagreed."
20. "this is your sign to find out how fried you actually are."

### C. Aura-points / listicle crossover
21. "things frying your brain and the aura you're losing →"
22. "-10,000 aura for doomscrolling at 2am. let's add it up."
23. "rating my own habits until I cried. starting score: 0."
24. "every '5 more minutes' is costing you aura. here's the math."
25. "watching everything at 1.5x: -5,000 aura. I'll explain."
26. "your for-you page is taking aura points. take the test for the total."

### D. Challenge / duet / social bait
27. "duet this with your brain age. I'll go first: 47."
28. "made my whole friend group take the fried test. we're not okay."
29. "most fried brain in the room wins. loser deletes TikTok."
30. "if your brain age is under 25 on this you're not human."
31. "stitch this with your score. bet you can't beat mine."
32. "tell me you have brain rot without telling me. score below 👇"
33. "-10,000 aura to whoever scores worse than me."
34. "send this to the most fried person you know."

### E. Curiosity / open-loop (pre-launch teaser)
35. "there's a test that tells you your brain age. I'm scared."
36. "this app is about to ruin everyone's day. it's not even out yet."
37. "everyone's about to find out their brain age. get on the list."
38. "the most unhinged app of the year drops this week."
39. "I got early access to the brain rot test. here's what happened."
40. "you have no idea how fried you are until you see the number."

### F. Shock / pattern-interrupt
41. "your brain is cooked and I can prove it in 60 seconds."
42. "this is what 6 hours of screen time does to your brain age."
43. "they should not let people see this number about themselves."
44. "I've never closed an app this fast."
45. "the test said 'recoverable.' barely."
46. "brain age 47 at 19 is a cry for help and that's me."
47. "watch the number go up. that's not a high score."
48. "I did the reaction test sober and still failed."
49. "the egg looked disappointed in me. genuinely."
50. "everyone scored bad. nobody scored worse than this."

---

## 12 ready-to-render scripts

Each maps to the pipeline: write the **VO** into `marketing/fried-ad/script.txt`, run `kokoro_tts.py` (→ `vo.wav` + `captions.json`), convert to mp3, render the composition. `[ON-SCREEN]` = burned-in hook text (frame 1). `[VISUAL]` = the scene. Lengths target 5–7s or 27–35s (skip the dead middle).

> **#1–#3 are the immediate batch to render next.** The current `FriedAdVO` already implements the Score-Reveal body; these mostly swap the hook + result numbers.

---

### Script 1 — "47 at 19" (Score Reveal · ~12s) ⭐ render first
- **[ON-SCREEN]** "this app said my brain is 47. I'm 19."
- **[VO]** "I took a brain rot test for fun. My brain age came back 47. I'm nineteen. It found five things wrong with me. I'm more fried than ninety-two percent of people my age."
- **[VISUAL]** selfie-cam egg (worried) → SCAN bar → brain age counts 19→**47** (flash, screen-shake) → 5 CRITICAL ISSUES stamp red → "92%" → soft CTA.
- **[CTA]** "it's not even out yet. link in bio to get it first."
- **[CAPTION]** this app said my brain is 47 and I'm 19 😭 #brainrot #brainage #screentime #fyp

### Script 2 — "I have to lie down" (Confession · ~22s)
- **[ON-SCREEN]** "I tested how fried my brain is and I have to lie down."
- **[VO]** "Okay so I can't watch a movie without checking my phone. I can't finish one video without opening another app. I thought I was normal. Then I took this test. My brain age is forty-seven. My focus score is twelve out of a hundred. I'm more fried than most people my age. I have to lie down."
- **[VISUAL]** confession framing → SCAN → brain age reveal → focus axis "12/100" → percentile → CTA.
- **[CTA]** "find out yours before everyone does — link in bio."
- **[CAPTION]** I thought I was fine. I was not fine. #brainrot #attentionspan #fyp #cooked

### Script 3 — "the egg looked disappointed" (POV · ~10s)
- **[ON-SCREEN]** "the egg in this app looked genuinely disappointed in me."
- **[VO]** "I took the fried test and the little egg just stared at me. Then it told me my brain is forty-seven. I'm nineteen. Why did a cartoon egg ruin my whole day."
- **[VISUAL]** egg curious → SCAN → egg shifts shocked→worried on reveal → brain age 47 → CTA.
- **[CTA]** "@getfried — it drops this week."
- **[CAPTION]** betrayed by a cartoon egg 🍳💀 #brainrot #fyp #brainage

### Script 4 — "things frying your brain" (Aura listicle · ~30s)
- **[ON-SCREEN]** "things frying your brain (and the aura you're losing)"
- **[VO]** "Doomscrolling at 2am: minus ten thousand aura. Watching everything at one-point-five speed: minus five thousand. Checking your phone before you're even out of bed: minus eight thousand. Opening a second app while the first one's still playing: minus twelve thousand. Want your real number? There's a test for that."
- **[VISUAL]** faceless text slideshow, running aura tally turning red → final "your score: take the test" card → Fried card drop.
- **[CTA]** "get the real number — link in bio."
- **[CAPTION]** add up your aura loss in the comments 👇 #aurapoints #brainrot #screentime #fyp

### Script 5 — "duet your brain age" (Challenge bait · ~7s)
- **[ON-SCREEN]** "duet this with your brain age. I'll go first."
- **[VO]** "My brain age is forty-seven and I'm nineteen. Duet this with yours. Bet you can't beat me. Actually — bet you can."
- **[VISUAL]** big "47" hero, split-screen-safe framing (room on one side for the duet), egg fried.
- **[CTA]** "stitch your score 👇 (app drops this week)"
- **[CAPTION]** duet your brain age, loser deletes TikTok 😭 #duet #brainrot #brainage #fyp

### Script 6 — "I've opened 3 apps" (Pattern-interrupt · ~9s)
- **[ON-SCREEN]** "you've opened 3 apps since you started watching this."
- **[VO]** "Be honest — you've already opened another app in your head. That's brain rot. There's a test that gives it a number. Mine was forty-seven. I'm nineteen."
- **[VISUAL]** fast cuts of app icons → SCAN → 47 reveal → CTA.
- **[CTA]** "find your number — link in bio."
- **[CAPTION]** caught you 😭 #brainrot #attentionspan #fyp

### Script 7 — "what 6 hours of screen time does" (Shock · ~12s)
- **[ON-SCREEN]** "this is what 6 hours of screen time does to your brain age."
- **[VO]** "Six hours of screen time a day. This is what it does to your brain age. Nineteen on paper. Forty-seven on the test. Five things wrong. Ninety-two percent more fried than people my age. Six hours. Every day."
- **[VISUAL]** screen-time number "6h 04m" → arrow → brain age 19→47 → issues → CTA.
- **[CTA]** "see your number — it's coming, link in bio."
- **[CAPTION]** check your screen time then check this 💀 #screentime #brainrot #fyp

### Script 8 — "most unhinged app of the year" (Teaser · ~8s)
- **[ON-SCREEN]** "the most unhinged app of the year drops this week."
- **[VO]** "There's an app that tells you your brain age, names everything wrong with you, and ranks you against everyone your age. It is not out yet. It's about to ruin everyone's week."
- **[VISUAL]** quick teaser montage of the reveal screens, blurred numbers → "soon" → CTA.
- **[CTA]** "get early access — link in bio."
- **[CAPTION]** you are NOT ready for your number #brainrot #newapp #fyp

### Script 9 — "I thought I was fine" (Confession · ~20s)
- **[ON-SCREEN]** "I thought I was fine. the test disagreed."
- **[VO]** "I genuinely thought my attention was fine. I finish things. I'm present. Then I did the sixty-second test — a quiz and a reaction game. Brain age forty-seven. Reflex speed: slow. Focus: gone. The egg looked so disappointed. I was not fine."
- **[VISUAL]** confident egg → reaction-game blips → reveal → axis fails stamp → CTA.
- **[CTA]** "find out before everyone does — link in bio."
- **[CAPTION]** the delusion was strong until 60 seconds ago #brainrot #fyp #cooked

### Script 10 — "rating my own habits" (Listicle · ~28s)
- **[ON-SCREEN]** "rating my own habits until I felt something."
- **[VO]** "Phone before coffee: terrible. Three-second video attention span: tragic. Re-reading the same text four times: concerning. Watching a show while scrolling about the show: unforgivable. I added it all up in this app. Brain age forty-seven. Yeah. That tracks."
- **[VISUAL]** habit cards stack with grades F, F, D, F → tally → Fried card.
- **[CTA]** "get your real grade — link in bio."
- **[CAPTION]** rate yours in the comments, be honest 👇 #brainrot #aurapoints #fyp

### Script 11 — "they shouldn't let you see this number" (Shock · ~7s)
- **[ON-SCREEN]** "they should not let people see this number about themselves."
- **[VO]** "They really should not let you find out your own brain age. Because mine is forty-seven. And I'm nineteen. And I have not been the same since."
- **[VISUAL]** dramatic slow build to the 47 reveal, heavy flash + shake.
- **[CTA]** "see yours if you're brave — link in bio."
- **[CAPTION]** ignorance was bliss 💀 #brainrot #brainage #fyp

### Script 12 — "got early access" (Teaser/UGC · ~15s)
- **[ON-SCREEN]** "I got early access to the brain rot test. here's my number."
- **[VO]** "I got into the early access for the fried test before it's out. Sixty seconds — a quiz and a reflex game. It gave me a brain age of forty-seven, five critical issues, and told me I'm more fried than ninety-two percent of people my age. You can get on the list now."
- **[VISUAL]** "EARLY ACCESS" badge → walkthrough of reveal → CTA card with waitlist.
- **[CTA]** "link in bio for early access before launch."
- **[CAPTION]** got in early and immediately humbled #brainrot #earlyaccess #fyp

---

## Caption + hashtag bank

**Core tags (rotate 3–4, don't stack all):** `#brainrot #brainage #aurapoints #screentime #attentionspan #cooked #fyp #foryou #newapp #duet`

**Caption formula:** [repeat the hook in lowercase] + [one emoji: 😭 💀 🍳] + [3–4 tags]. Captions are a search surface — always restate the hook in words.

**Pinned comment (every post):** "it's not out yet — get on the early list 👉 @getfried (link in bio)"
