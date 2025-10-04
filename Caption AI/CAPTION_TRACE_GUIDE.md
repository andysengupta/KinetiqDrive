# AI Caption Complete Trace Guide

## 🔍 How to Trace the Caption Flow

I've added comprehensive logging throughout the entire caption generation pipeline. Here's what to look for in the Xcode console.

---

## 📊 **Complete Console Output (Expected Flow)**

### **Step 1: AFM Availability Check**
```
🔍 [AFM AVAILABILITY CHECK]
   Device compatible: true
   SystemLanguageModel availability: LanguageModelAvailability.unavailable(reason: ...)
   ❌ AFM Unavailable: ...
   Final isAvailable: false
```

**OR** (if AFM is available):
```
🔍 [AFM AVAILABILITY CHECK]
   Device compatible: true
   SystemLanguageModel availability: LanguageModelAvailability.available
   ✅ AFM Available and Ready
   Final isAvailable: true
```

**KEY INDICATOR:** Look at `Final isAvailable:` - This determines if real AFM or mock is used.

---

### **Step 2: Image Interpretation**
```
🖼️ Processing image for AFM...
📊 Image size: 142KB
🤖 Sending image to AFM for interpretation...
```

Then either:
- `✅ Used enhanced multimodal AFM API` (if available)
- `🔍 Enhancing with image analysis...` (fallback)

---

### **Step 3: Caption Generation (CRITICAL)**

#### **If AFM is Unavailable (Mock Mode):**
```
📝 [CAPTION GENERATION START]
   AFM Available: false
   Interpretation: objects=ear, face, skin
⚠️ AFM unavailable, using mock caption
🤖 Generated mock caption: 'Interesting Image'
🤖 Mock Caption Generated: 'Interesting Image'
```

#### **If AFM is Available (Real Mode):**
```
📝 [CAPTION GENERATION START]
   AFM Available: true
   Interpretation: objects=ear, face, skin
📤 Sending caption prompt to AFM...
   Prompt length: 257 chars
📥 AFM Caption Response received
   Raw content: '{"caption":"Close Ear Detail"}'
🔍 Parsing AI Caption - Raw input: '{"caption":"Close Ear Detail"}'
✅ Extracted from JSON: 'Close Ear Detail'
✅ Final cleaned caption: 'Close Ear Detail'
🎨 [CAPTION GENERATION END]
   Final AI Caption: 'Close Ear Detail'
   Caption length: 16 chars, 3 words
```

---

### **Step 4: Caption Received in PlayView**

#### **Background Processing:**
```
✅ PlayView: Background AI caption received: 'Close Ear Detail'
```

**OR**

#### **Foreground Processing:**
```
⚠️ PlayView: AI caption not cached, generating now...
✅ PlayView: Foreground AI caption received: 'Close Ear Detail'
```

**OR**

#### **Using Cached:**
```
✅ PlayView: Using cached AI caption: 'Close Ear Detail'
```

---

### **Step 5: Before Passing to ScoreView**
```
📊 PlayView: About to pass to ScoreView: 'Close Ear Detail'
```

---

### **Step 6: ScoreView Receives Caption**
```
🖼️ [SCOREVIEW] Received AI Caption: 'Close Ear Detail'
   Length: 16 chars
✅ ScoreView: Displaying AI caption 'Close Ear Detail'
```

**OR if malformed:**
```
🖼️ [SCOREVIEW] Received AI Caption: '{'
   Length: 1 chars
⚠️ ScoreView: Malformed AI caption '{', using fallback
```

---

## 🎯 **What To Look For**

### **Problem: Seeing Fallback Caption**

#### **Scenario A: AFM is Unavailable**
**You'll See:**
```
Final isAvailable: false
⚠️ AFM unavailable, using mock caption
🤖 Mock Caption Generated: 'Interesting Image'
```

**Why:** Device doesn't support Apple Intelligence or it's not enabled.

**Solution:** This is expected behavior. The app gracefully falls back to mock captions.

---

#### **Scenario B: AFM Fails to Respond**
**You'll See:**
```
Final isAvailable: true
📤 Sending caption prompt to AFM...
❌ AFM Caption Error: [error details]
🤖 Fallback Mock Caption: 'Interesting Image'
```

**Why:** AFM is available but encountered an error during generation.

**Solution:** Check the error details. May be a temporary issue.

---

#### **Scenario C: Parsing Failure**
**You'll See:**
```
📥 AFM Caption Response received
   Raw content: '[garbage text]'
🔍 Parsing AI Caption - Raw input: '[garbage text]'
⚠️ Caption still malformed: '...', using fallback
✅ Final cleaned caption: 'Moment Captured'
```

**Why:** AFM responded but with unparseable content.

**Solution:** Check if the prompt needs adjustment or if it's a one-off error.

---

#### **Scenario D: ScoreView Rejects Caption**
**You'll See:**
```
🖼️ [SCOREVIEW] Received AI Caption: '{'
   Length: 1 chars
⚠️ ScoreView: Malformed AI caption '{', using fallback
```

**Why:** Caption passed to ScoreView is malformed (only brackets, no letters).

**Solution:** Check why parsing didn't catch this earlier.

---

## 🔑 **Key Debug Points**

### **1. Check AFM Availability**
Look for:
```
Final isAvailable: true ✅
```
or
```
Final isAvailable: false ❌
```

**If false:** All captions will be mock. This is the root cause.

---

### **2. Check Caption Generation Start**
Look for:
```
📝 [CAPTION GENERATION START]
   AFM Available: [true/false]
```

**If false:** Mock caption will be generated immediately.

---

### **3. Check Raw AFM Response**
Look for:
```
📥 AFM Caption Response received
   Raw content: '[actual response]'
```

**This shows exactly what AFM returned.** If it's JSON, parsing should extract it.

---

### **4. Check Parsing Output**
Look for:
```
🔍 Parsing AI Caption - Raw input: '...'
✅ Extracted from JSON: '...'
✅ Final cleaned caption: '...'
```

**This shows the parsing process.** Make sure "Final cleaned caption" looks correct.

---

### **5. Check Final Caption**
Look for:
```
🎨 [CAPTION GENERATION END]
   Final AI Caption: '...'
   Caption length: X chars, Y words
```

**This is what's returned to PlayView.**

---

### **6. Check ScoreView Reception**
Look for:
```
🖼️ [SCOREVIEW] Received AI Caption: '...'
✅ ScoreView: Displaying AI caption '...'
```

**This is what the user will see.**

---

## 🧪 **Test Scenarios**

### **Test 1: Check AFM Availability**
1. Run the app
2. Look for `🔍 [AFM AVAILABILITY CHECK]`
3. Note the `Final isAvailable` value

**Expected:** `false` on most devices (Apple Intelligence not widely available yet)

---

### **Test 2: Trace Caption Flow**
1. Select an image
2. Click "Continue"
3. Watch console for:
   - `📝 [CAPTION GENERATION START]`
   - Caption generation logs
   - `🎨 [CAPTION GENERATION END]`

---

### **Test 3: Check What User Sees**
1. After "Clash!" button
2. Look for:
   - `🖼️ [SCOREVIEW] Received AI Caption`
   - `✅ ScoreView: Displaying AI caption`
3. Compare to what's shown in the app

---

## 🐛 **Troubleshooting Guide**

### **Issue: User sees "Captured Moment" fallback**

#### **Step 1: Check AFM Availability**
```bash
Search console for: "Final isAvailable:"
```
- If `false` → Device doesn't support AFM (expected)
- If `true` → Continue to Step 2

#### **Step 2: Check Caption Generation**
```bash
Search console for: "CAPTION GENERATION START"
```
- If you see "AFM unavailable" → AFM became unavailable (check why)
- If you see "Sending caption prompt" → Continue to Step 3

#### **Step 3: Check AFM Response**
```bash
Search console for: "AFM Caption Response received"
```
- If missing → AFM didn't respond (error occurred)
- If present → Check the "Raw content" line

#### **Step 4: Check Parsing**
```bash
Search console for: "Parsing AI Caption"
```
- Check if "Extracted from JSON" appears
- Check "Final cleaned caption" value

#### **Step 5: Check ScoreView**
```bash
Search console for: "[SCOREVIEW] Received AI Caption"
```
- Check what caption was received
- Check if it's being displayed or rejected

---

## 📋 **Quick Reference**

| Emoji | Meaning |
|-------|---------|
| 🔍 | Checking/searching |
| ✅ | Success |
| ❌ | Error/failure |
| ⚠️ | Warning/fallback used |
| 📝 | Starting a process |
| 📤 | Sending to AFM |
| 📥 | Receiving from AFM |
| 🎨 | Final caption ready |
| 🖼️ | ScoreView activity |
| 📊 | Data/metrics |
| 🤖 | Mock/fallback used |

---

## 🎯 **Expected Results**

### **On Most Devices (No Apple Intelligence):**
```
🔍 [AFM AVAILABILITY CHECK]
   Final isAvailable: false

📝 [CAPTION GENERATION START]
   AFM Available: false
⚠️ AFM unavailable, using mock caption
🤖 Mock Caption Generated: 'Interesting Image'

✅ PlayView: Background AI caption received: 'Interesting Image'
📊 PlayView: About to pass to ScoreView: 'Interesting Image'

🖼️ [SCOREVIEW] Received AI Caption: 'Interesting Image'
✅ ScoreView: Displaying AI caption 'Interesting Image'
```

**User sees:** Mock caption (this is correct and expected!)

---

### **On Devices with Apple Intelligence:**
```
🔍 [AFM AVAILABILITY CHECK]
   Final isAvailable: true

📝 [CAPTION GENERATION START]
   AFM Available: true
📤 Sending caption prompt to AFM...
📥 AFM Caption Response received
   Raw content: '{"caption":"Close Ear Detail"}'
🎨 [CAPTION GENERATION END]
   Final AI Caption: 'Close Ear Detail'

✅ PlayView: Background AI caption received: 'Close Ear Detail'
📊 PlayView: About to pass to ScoreView: 'Close Ear Detail'

🖼️ [SCOREVIEW] Received AI Caption: 'Close Ear Detail'
✅ ScoreView: Displaying AI caption 'Close Ear Detail'
```

**User sees:** Real AFM caption!

---

## 🚀 **Action Items**

1. **Run the app**
2. **Open Xcode Console** (Cmd + Shift + C)
3. **Clear console** (trash icon)
4. **Play a round**
5. **Search for** key indicators:
   - `"Final isAvailable"`
   - `"CAPTION GENERATION"`
   - `"SCOREVIEW"`
6. **Copy the console output** and share it

---

**This trace will tell us EXACTLY where the caption is getting lost or replaced with fallback text!**

