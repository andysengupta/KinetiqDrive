# AFM Prompts - Complete Examples

## 📝 All Three Prompts Sent to Apple Intelligence

---

## 🖼️ **Prompt #1: Image Interpretation**

### Location: `AFMJudge.swift` Line 15-30

### Actual Prompt Sent:
```markdown
# Analyze Attached Image

You are a precise visual analyzer. Examine the image and fill the ImageInterpretation structure:

- **Objects**: List concrete nouns visible (e.g., "cat", "laptop", "tree")
- **Scene**: Write one clear sentence describing the overall scene
- **Actions**: List verbs for any actions/interactions happening
- **Vibes**: Describe atmosphere in 1-3 words (e.g., "cozy", "energetic")
- **AltText**: Write accessible alt text (1-2 sentences)
- **SafetyFlag**: Choose one: "none", "contains_people", "contains_children", "contains_text", "contains_logos"

Be concise and factual. Output only structured fields.
```

### What's Included:
- ✅ Image data (base64 encoded, typically 50-200KB)
- ✅ Clear instructions for structured output
- ✅ Examples for each field
- ✅ Request for JSON-like format

### Expected Response:
```json
{
    "objects": ["ear", "face", "skin"],
    "scene": "Close-up photograph of a human ear",
    "actions": ["showing", "displaying"],
    "vibes": ["detailed", "close", "anatomical"],
    "altText": "A close-up photograph showing a human ear with visible details of the ear structure against skin.",
    "safetyFlag": "contains_people"
}
```

### Generation Options:
```swift
temperature: 0.3        // Low = more factual
maximumResponseTokens: 256
```

---

## 🤖 **Prompt #2: AI Caption Generation**

### Location: `AFMJudge.swift` Line 34-53

### Example for Ear Image:

```markdown
## Image Analysis
**Scene:** Close-up photograph of a human ear

**Objects:** ear, face, skin

**Actions:** showing, displaying

**Vibes:** detailed, close, anatomical

**Alt Text:** A close-up photograph showing a human ear with visible details of the ear structure against skin.

# Task: Generate Caption

Based on the image analysis above, create a clever, evocative caption.

**Rules:**
- Exactly 3-5 words
- Title Case (e.g., "Cozy Morning Vibes")
- No emojis
- Max 1 punctuation mark
- Be creative but accurate to the image

Output only the AICaption structure.
```

### What's Included:
- ✅ Image interpretation from Stage A
- ✅ Clear formatting rules
- ✅ Word count constraint (3-5 words)
- ✅ Style guidelines (Title Case, no emojis)

### Expected Response:
```json
{
    "caption": "Close Ear Detail"
}
```

Or could be:
- "Anatomical Ear Study"
- "Human Ear Close-Up"
- "Detailed Ear Portrait"

### Generation Options:
```swift
temperature: 0.7        // Medium = balanced creativity
maximumResponseTokens: 128
```

---

## ⚖️ **Prompt #3: Caption Judging**

### Location: `AFMJudge.swift` Line 57-104

### Example: User wrote "Ears and face"

```markdown
## Image Analysis
**Scene:** Close-up photograph of a human ear

**Objects:** ear, face, skin

**Actions:** showing, displaying

**Vibes:** detailed, close, anatomical

**Alt Text:** A close-up photograph showing a human ear with visible details of the ear structure against skin.

# Compare Captions

**User Caption:** "Ears and face"
**AI Caption:** "Close Ear Detail"

## Scoring Rubric (0-10)

**0-3**: Off-topic, generic, or completely misses image content
**4-6**: Partially relevant but bland, vague, or weak connection
**7-8**: Strong alignment with image, specific and clear
**9-10**: Evocative, precise, creative—captures essence perfectly

## Evaluation Categories
- **Relevance**: Does it match the image content?
- **Specificity**: Is it concrete or generic?
- **Fluency**: Is it well-phrased?
- **Originality**: Is it creative or cliché?

# Task: Judge User Caption

Score the **user's caption** (0-10) based on the rubric above.
Provide 2-3 short, actionable tips for improvement.
List 2-3 category names evaluated (e.g., ["Relevance", "Specificity"]).

Output only the CaptionJudgment structure.
```

### What's Included:
- ✅ Image interpretation for context
- ✅ Both captions (user vs AI)
- ✅ Detailed scoring rubric
- ✅ Evaluation criteria
- ✅ Request for specific output format

### Expected Response:
```json
{
    "score": 6,
    "shortTips": [
        "Use singular 'ear' instead of plural for accuracy",
        "Remove 'and face' - focus on the main subject",
        "Try more descriptive words like 'close-up' or 'detailed'"
    ],
    "categories": ["Relevance", "Specificity", "Fluency"]
}
```

### Generation Options:
```swift
temperature: 0.6        // Balanced = fair judging
maximumResponseTokens: 256
```

---

## 🎨 **More Examples: Locker Image**

### Stage A: Interpretation Prompt
```markdown
# Analyze Attached Image

[Same instructions as above]

[Image: Metal lockers in a school hallway]
```

### Stage A: Expected Response
```json
{
    "objects": ["lockers", "metal", "doors", "hallway"],
    "scene": "Row of blue metal lockers in a school hallway",
    "actions": ["standing", "aligned", "stored"],
    "vibes": ["institutional", "organized", "blue"],
    "altText": "A row of blue metal school lockers with combination locks aligned in a hallway.",
    "safetyFlag": "none"
}
```

### Stage B: Caption Generation Prompt
```markdown
## Image Analysis
**Scene:** Row of blue metal lockers in a school hallway

**Objects:** lockers, metal, doors, hallway

**Actions:** standing, aligned, stored

**Vibes:** institutional, organized, blue

**Alt Text:** A row of blue metal school lockers with combination locks aligned in a hallway.

# Task: Generate Caption

[Same rules as above]
```

### Stage B: Expected Response
```json
{
    "caption": "Blue Metal Lockers"
}
```

Or alternatives:
- "School Locker Row"
- "Organized Blue Storage"
- "Institutional Metal Doors"

### Stage C: Judging Prompt (User wrote "Lockers")
```markdown
## Image Analysis
[Same as above]

# Compare Captions

**User Caption:** "Lockers"
**AI Caption:** "Blue Metal Lockers"

## Scoring Rubric (0-10)
[Same rubric]

# Task: Judge User Caption
[Same instructions]
```

### Stage C: Expected Response
```json
{
    "score": 5,
    "shortTips": [
        "Add descriptive details like 'blue' or 'metal'",
        "Use 3-5 words instead of just one",
        "Specify the context - school, storage, etc."
    ],
    "categories": ["Specificity", "Fluency"]
}
```

---

## 🌅 **Example: Sunset Image**

### Stage A Response:
```json
{
    "objects": ["sky", "clouds", "horizon", "sun"],
    "scene": "Beautiful sunset with orange and pink sky over the horizon",
    "actions": ["setting", "glowing", "fading"],
    "vibes": ["peaceful", "warm", "golden"],
    "altText": "A stunning sunset with vibrant orange and pink clouds spread across the sky as the sun sets over the horizon.",
    "safetyFlag": "none"
}
```

### Stage B Response:
```json
{
    "caption": "Golden Sunset Horizon"
}
```

### Stage C (User: "Pretty Sky Colors"):
```json
{
    "score": 7,
    "shortTips": [
        "Great color focus! Try being more specific with 'sunset' or 'golden'",
        "Consider atmosphere words like 'peaceful' or 'glowing'"
    ],
    "categories": ["Relevance", "Specificity", "Originality"]
}
```

---

## 🔧 **How Prompts Are Built**

### Code Flow:
```swift
// Stage A: Image Interpretation
let prompt = AFMJudge.buildInterpretationPrompt()
// Returns: The markdown prompt above

// Stage B: Caption Generation  
let prompt = AFMJudge.buildCaptionPrompt(interpretation: interp)
// Returns: Markdown with image analysis + caption rules

// Stage C: Judging
let prompt = AFMJudge.buildJudgmentPrompt(
    userCaption: "Ears and face",
    aiCaption: "Close Ear Detail",
    interpretation: interp
)
// Returns: Markdown with analysis + both captions + rubric
```

---

## 📊 **Prompt Characteristics**

| Stage | Token Count | Temperature | Format | Focus |
|-------|-------------|-------------|--------|-------|
| **A: Interpret** | ~150-200 | 0.3 (factual) | Structured JSON | Visual analysis |
| **B: Caption** | ~200-250 | 0.7 (creative) | Short text | 3-5 words |
| **C: Judge** | ~300-400 | 0.6 (balanced) | Structured scoring | Fair evaluation |

---

## 🎯 **Key Design Principles**

### 1. **Markdown Formatting**
All prompts use markdown for clarity:
- `#` Headers for sections
- `**Bold**` for emphasis
- `-` Lists for structure
- Code blocks for examples

### 2. **Structured Output Requests**
Each prompt asks for specific JSON-like structures:
- `ImageInterpretation`
- `AICaption`
- `CaptionJudgment`

### 3. **Progressive Context**
- Stage A: Just image
- Stage B: Image interpretation
- Stage C: Image interpretation + both captions

### 4. **Clear Constraints**
- Word counts (3-5 words)
- Format rules (Title Case)
- Scoring ranges (0-10)
- Safety considerations

---

## 🔍 **Where to Find These**

### In Code:
```
AFMJudge.swift:15-30   → buildInterpretationPrompt()
AFMJudge.swift:34-53   → buildCaptionPrompt()
AFMJudge.swift:57-104  → buildJudgmentPrompt()
```

### Called From:
```
AFMService.swift:137   → Stage A prompt
AFMService.swift:211   → Stage B prompt
AFMService.swift:248   → Stage C prompt
```

---

## 🧪 **Testing Prompts**

### To see prompts in console:
```swift
// Add debug prints in AFMService.swift before session.respond()
print("📤 Sending prompt to AFM:")
print(prompt)
print("---")
```

### Console Output:
```
📤 Sending prompt to AFM:
# Analyze Attached Image

You are a precise visual analyzer...
---
🚀 Sending to Apple Intelligence...
✅ Response received
```

---

## 💡 **Why These Prompts Work**

### ✅ **Clear Instructions**
- Tells AI exactly what to do
- Provides examples
- Specifies output format

### ✅ **Structured Thinking**
- Breaks down image analysis into categories
- Separates concerns (objects, scene, vibes)
- Progressive refinement (interpret → caption → judge)

### ✅ **Consistent Format**
- All use markdown
- All request structured output
- All provide context

### ✅ **Safety Considerations**
- Flags sensitive content
- Sanitizes tips for privacy
- Generic fallbacks for people/faces

---

## 🚀 **Summary**

**3 Prompts are sent to AFM:**

1. **"Analyze Attached Image"** → Get image interpretation
2. **"Generate Caption"** + interpretation → Get 3-5 word caption
3. **"Judge User Caption"** + both captions + rubric → Get score & tips

**All prompts:**
- ✅ Use markdown formatting
- ✅ Request structured JSON output
- ✅ Include clear examples
- ✅ Specify constraints (word counts, formats)
- ✅ Build on previous stage results

**Files:**
- `AFMJudge.swift` - Builds prompts
- `AFMService.swift` - Sends prompts to AI
- `AFMModels.swift` - Defines response structures

Want to see the actual console output when these prompts are sent? 🔍

