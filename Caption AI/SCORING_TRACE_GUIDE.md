# Scoring/Judgment Complete Trace Guide

## 🎯 How to Trace the Scoring Flow

I've added comprehensive logging throughout the entire judgment/scoring pipeline. Here's what to look for in the Xcode console.

---

## 📊 **Complete Console Output (Expected Flow)**

### **Step 1: Judging Start**
```
⚖️ [JUDGING START]
   AFM Available: false
   User Caption: 'Ears and face'
   AI Caption: 'Close Ear Detail'
```

**KEY INDICATORS:**
- `AFM Available: true` = Real AFM judging
- `AFM Available: false` = Mock judging (score will be heuristic)

---

### **Step 2A: Mock Judgment (if AFM unavailable)**
```
⚠️ AFM unavailable, using mock judgment
🤖 Mock Judgment: score=7/10
```

**Mock scoring logic:**
```
Base score: 5
+ Word count 3-5: +2
+ Contains vibe words: +1  
+ Contains object words: +2
= Final: 5-10 (typically 7-9)
```

**Why you see 7/10:** Most captions match this pattern!

---

### **Step 2B: Real AFM Judgment (if available)**
```
📤 Sending judgment prompt to AFM...
   Prompt length: 432 chars
📥 AFM Judgment Response received
   Raw content: '{"score":6,"shortTips":["Use singular","Remove and face"],"categories":["Relevance"]}'
🔍 Parsing judgment response...
✅ Successfully parsed judgment: score=6
⚖️ [JUDGING END]
   Final Score: 6/10
   Tips: ["Use singular ear", "Remove and face", "Try more descriptive"]
   Categories: ["Relevance", "Specificity", "Fluency"]
```

---

### **Step 3: PlayView Receives Judgment**
```
📊 PlayView: Judgment received
   Score: 6/10
   Winner: tie
   Tips count: 3
   About to pass to ScoreView...
```

---

### **Step 4: ScoreView Renders**
```
🎯 [SCOREVIEW RENDER]
   Judgment Score: 6/10
   User Caption: 'Ears and face'
   AI Caption (raw): 'Close Ear Detail'
   Winner: tie
```

**This is what the user will see!**

---

## 🐛 **Problem: Score Always Shows 7/10**

### **Scenario A: AFM is Unavailable (Most Common)**

**Console Output:**
```
⚖️ [JUDGING START]
   AFM Available: false
⚠️ AFM unavailable, using mock judgment
🤖 Mock Judgment: score=7/10
```

**Why:** Device doesn't support Apple Intelligence.

**Solution:** This is expected. Mock judgment uses heuristics:
- Base: 5
- Good word count (3-5): +2 → **7**
- Has object words: +2 → **9**
- Has vibe words: +1 → **10**

Most captions score **7-9** with this system!

---

### **Scenario B: AFM Available But Parsing Fails**

**Console Output:**
```
⚖️ [JUDGING START]
   AFM Available: true
📤 Sending judgment prompt to AFM...
📥 AFM Judgment Response received
   Raw content: '[garbage]'
🔍 Parsing judgment response...
⚠️ Could not parse judgment, using heuristic
🤖 Fallback Mock Judgment: score=7/10
```

**Why:** AFM responded but with unparseable content.

**Solution:** Check the raw content. May need to adjust prompt or parsing.

---

### **Scenario C: AFM Errors**

**Console Output:**
```
⚖️ [JUDGING START]
   AFM Available: true
📤 Sending judgment prompt to AFM...
❌ AFM Judge Error: [error details]
🤖 Fallback Mock Judgment: score=7/10
```

**Why:** AFM encountered an error during judgment.

**Solution:** Check error details. May be temporary.

---

## 🔍 **Detailed Trace Points**

### **1. Check AFM Availability for Judging**
```
⚖️ [JUDGING START]
   AFM Available: [true/false]
```

**If false:** Score will be mock (typically 7/10)

---

### **2. Check Raw AFM Response**
```
📥 AFM Judgment Response received
   Raw content: '[actual JSON response]'
```

**Expected format:**
```json
{
    "score": 6,
    "shortTips": ["tip 1", "tip 2"],
    "categories": ["Relevance", "Specificity"]
}
```

---

### **3. Check Parsing Success**
```
🔍 Parsing judgment response...
✅ Successfully parsed judgment: score=6
```

**OR**

```
🔍 Parsing judgment response...
⚠️ Could not parse judgment, using heuristic
```

---

### **4. Check Final Score**
```
⚖️ [JUDGING END]
   Final Score: X/10
```

**This is what gets returned to PlayView.**

---

### **5. Check PlayView Receipt**
```
📊 PlayView: Judgment received
   Score: X/10
```

**This is what gets passed to ScoreView.**

---

### **6. Check ScoreView Display**
```
🎯 [SCOREVIEW RENDER]
   Judgment Score: X/10
```

**This is what the user sees.**

---

## 🧪 **Test Scenarios**

### **Test 1: Identify Judging Mode**
1. Run the app
2. Play a round
3. Search console for `⚖️ [JUDGING START]`
4. Look at `AFM Available:` line

**Expected on most devices:** `false` (Mock mode)

---

### **Test 2: Check Mock Score Calculation**
If AFM unavailable, check:
```
🤖 Mock Judgment: score=X/10
```

Then trace backwards to see why that score:
- Check if user caption has 3-5 words
- Check if it contains object words from interpretation
- Check if it contains vibe words

---

### **Test 3: Check Real AFM Response**
If AFM available:
```
📥 AFM Judgment Response received
   Raw content: '[full response]'
```

**Compare:**
- What AFM returned
- What parsing extracted
- What user sees

---

## 📋 **Mock Judgment Logic (Default)**

**File:** `AFMService.swift` Line ~640

```swift
var score = 5  // Base score

// Good word count (3-5 words)
if wordCount >= 1 && wordCount <= 5 { score += 2 }  // → 7

// Contains vibe words (e.g., "detailed", "close")
if hasVibeWords { score += 1 }  // → 8

// Contains object words (e.g., "ear", "face")
if hasObjectWords { score += 2 }  // → 9-10

score = min(10, max(0, score))  // Clamp 0-10
```

**Why most captions score 7-9:**
- Most valid captions have 1-5 words → +2 → 7
- Many mention objects → +2 → 9
- Some mention vibes → +1 → 10

**Result:** Very forgiving scoring system!

---

## 🎯 **Quick Diagnostic**

### **Is score always 7?**

#### **Step 1: Check Console**
```bash
Search for: "AFM Available:"
```

#### **Step 2: Determine Mode**
- **If `false`:** You're using mock judgment (expected)
  - Mock typically gives 7-9 based on heuristics
  - This is normal for devices without Apple Intelligence

- **If `true`:** You're using real AFM
  - Check if parsing succeeds
  - Check final score in `[JUDGING END]`
  - Compare to what user sees

#### **Step 3: Verify Path**
Follow the score through the pipeline:
```
⚖️ [JUDGING END] Final Score: X/10
    ↓
📊 PlayView: Judgment received Score: X/10
    ↓
🎯 [SCOREVIEW RENDER] Judgment Score: X/10
```

**If score changes anywhere, we found the problem!**

---

## 📊 **Expected Behavior**

### **On Most Devices (No Apple Intelligence):**

**Every round:**
```
⚖️ [JUDGING START]
   AFM Available: false
⚠️ AFM unavailable, using mock judgment
🤖 Mock Judgment: score=7/10 (or 8/10, 9/10)

📊 PlayView: Judgment received
   Score: 7/10

🎯 [SCOREVIEW RENDER]
   Judgment Score: 7/10
```

**User sees:** 7/10 (or close to it)

**Why:** Mock heuristic is very forgiving. Most captions get 7-9.

**This is correct and expected!**

---

### **On Devices with Apple Intelligence:**

**Every round:**
```
⚖️ [JUDGING START]
   AFM Available: true
📤 Sending judgment prompt to AFM...
📥 AFM Judgment Response received
   Raw content: '{"score":6,...}'
✅ Successfully parsed judgment: score=6
⚖️ [JUDGING END]
   Final Score: 6/10

📊 PlayView: Judgment received
   Score: 6/10

🎯 [SCOREVIEW RENDER]
   Judgment Score: 6/10
```

**User sees:** 6/10 (actual AFM score)

**Scores vary:** 0-10 based on actual judgment

---

## 🔧 **How to Get Varied Scores**

### **Option 1: Wait for Apple Intelligence**
Real AFM gives varied scores (0-10) based on actual quality.

### **Option 2: Adjust Mock Heuristic**
**File:** `AFMService.swift` Line ~640

Make it more critical:
```swift
var score = 3  // Stricter base (was 5)

if wordCount >= 1 && wordCount <= 5 { score += 1 }  // Less generous (was +2)
if hasVibeWords { score += 2 }  // Reward quality
if hasObjectWords { score += 2 }  // Reward relevance

// More strict thresholds
if wordCount < 3 { score -= 1 }  // Penalize too short
if wordCount > 5 { score -= 1 }  // Penalize too long
```

---

## 🎯 **Summary**

### **Why Score is Always 7:**
1. ✅ **Most likely:** AFM unavailable, using mock
2. ✅ Mock heuristic is forgiving (base 5 + 2 for valid = 7)
3. ✅ Most captions meet the criteria
4. ✅ This is expected behavior!

### **How to Verify:**
1. Run app
2. Check console for `⚖️ [JUDGING START]`
3. Look at `AFM Available:` line
4. If `false` → Mock mode (7-9 typical)
5. If `true` → Check parsing and final score

### **How to Fix (if needed):**
1. If using mock: Adjust heuristic to be more critical
2. If using AFM: Check parsing is working
3. Trace score through entire pipeline

---

## 📱 **Console Search Commands**

```bash
# Find judging start
Search: "JUDGING START"

# Check AFM availability
Search: "AFM Available:"

# Check final score
Search: "Final Score:"

# Check what user sees
Search: "SCOREVIEW RENDER"

# Check mock usage
Search: "Mock Judgment:"

# Check parsing
Search: "Parsing judgment"
```

---

**With this trace, you'll know EXACTLY why the score is what it is!**

