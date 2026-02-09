import os
import json
import math
import time
import shutil
import requests
import google.generativeai as genai

# Optional: For combining audio files (install with: pip install pydub)
try:
    from pydub import AudioSegment
    from pydub.utils import which
    PYDUB_AVAILABLE = True
except ImportError:
    PYDUB_AVAILABLE = False

# ==========================
# CONFIG
# ==========================
WORDS_PER_MINUTE = 155
SEGMENT_MINUTES = 4  # each segment ~4 minutes

# API Keys
gemini_api_key = 'GEMINI_API_KEY'  # Add your Gemini API key here
elevenlabs_api_key = 'ELEVENLABS_API_KEY'  # Add your ElevenLabs API key here

# FFmpeg Configuration (if not in PATH)
# Set this to the directory containing ffmpeg.exe and ffprobe.exe
# Example: r"C:\ffmpeg\ffmpeg-master-latest-win64-gpl\bin"
FFMPEG_PATH = None  # Set to your ffmpeg bin directory if ffmpeg is not in PATH

# API Rate Limiting
# Delay between API calls in seconds (increase if you hit rate limits)
API_DELAY_SECONDS = 2  # Recommended: 1-3 seconds for free tier, 0.5-1 for paid tier

genai.configure(api_key=gemini_api_key)
model = genai.GenerativeModel("gemma-3-1b-it")

# Configure pydub to use custom ffmpeg path if specified
if PYDUB_AVAILABLE and FFMPEG_PATH:
    AudioSegment.converter = os.path.join(FFMPEG_PATH, "ffmpeg.exe")
    AudioSegment.ffmpeg = os.path.join(FFMPEG_PATH, "ffmpeg.exe")
    AudioSegment.ffprobe = os.path.join(FFMPEG_PATH, "ffprobe.exe")

# ==========================
# LLM CALL PLACEHOLDER
# ==========================
def call_llm(prompt: str) -> str:
    response = model.generate_content(prompt)
    return response.text

# ==========================
# STEP 1 — CREATE OUTLINE
# ==========================
def generate_outline(topic: str, total_minutes: int):
    num_segments = math.ceil(total_minutes / SEGMENT_MINUTES)

    prompt = f"""
Use simple language: Write plainly with short sentences.

Example: "I need help with this issue."

Avoid AI-giveaway phrases: Don't use clichés like "dive into," "unleash your potential," etc.

Avoid: "Let's dive into this game-changing solution."

Use instead: "Here's how it works."

Be direct and concise: Get to the point; remove unnecessary words.

Example: "We should meet tomorrow."

Maintain a natural tone: Write as you normally speak; it's okay to start sentences with "and" or "but."

Example: "And that's why it matters."

Avoid marketing language: Don't use hype or promotional words.

Avoid: "This revolutionary product will transform your life."

Use instead: "This product can help you."

Keep it real: Be honest; don't force friendliness.

Example: "I don't think that's the best idea."

Simplify grammar: Don't stress about perfect grammar; it's fine not to capitalize "i" if that's your style.

Example: "i guess we can try that."

Stay away from fluff: Avoid unnecessary adjectives and adverbs.

Example: "We finished the task."

Focus on clarity: Make your message easy to understand.

Example: "Please send the file by Monday."

Here is your job:

You are planning a SINGLE, continuous podcast episode.

TOPIC:
"{topic}"

CONVERSATION STYLE:
- Two speakers: HOST (curious, non-expert) and EXPERT (knowledgeable)
- The EXPERT should speak more than the HOST
  - Each EXPERT turn can be multiple sentences, giving in-depth explanations, examples, or analogies
- The HOST should speak briefly and occasionally
  - Mostly asks questions, seeks clarification, or reacts naturally
- Dialogue should feel like a real conversation, not a lecture or scripted reading
- Allow the EXPERT to elaborate fully on ideas without interruption
- Avoid repeating points already made
- Use natural spoken language, not academic or formal style
- Include occasional interruptions from the HOST, but only when it makes the conversation flow
- Encourage the EXPERT to explore each topic in depth

PODCAST STRUCTURE:
- The conversation is split into {num_segments} internal segments
- Each segment should focus on a single, clear idea
- Segments should flow naturally from one to the next
- First segment starts the podcast; subsequent segments continue mid-conversation
- Only the final segment includes a reflective conclusion

FOR EACH SEGMENT, RETURN:
- title: short, informal, conversational
- learning_goal: what the listener should understand after this part
- summary: 1–2 sentences describing how the HOST and EXPERT explore this idea together

OUTPUT FORMAT:
Return ONLY valid JSON. No markdown, comments, or explanations.
JSON format:
[
  {{
    "title": "...",
    "learning_goal": "...",
    "summary": "..."
  }}
]

"""

    outline_text = call_llm(prompt)
    
    # Debug: Print raw response
    print("Raw LLM Response:")
    print(outline_text)
    print("-" * 50)
    
    # Extract JSON from markdown code blocks if present
    if "```json" in outline_text:
        # Extract content between ```json and ```
        start = outline_text.find("```json") + 7
        end = outline_text.find("```", start)
        outline_text = outline_text[start:end].strip()
    elif "```" in outline_text:
        # Extract content between ``` and ```
        start = outline_text.find("```") + 3
        end = outline_text.find("```", start)
        outline_text = outline_text[start:end].strip()
    
    # Clean up any leading/trailing whitespace
    outline_text = outline_text.strip()
    
    try:
        return json.loads(outline_text)
    except json.JSONDecodeError as e:
        print(f"ERROR: Failed to parse JSON")
        print(f"Error details: {e}")
        print(f"Attempted to parse: {outline_text[:200]}...")
        raise

# ==========================
# STEP 2A — CREATE FIRST SEGMENT PROMPT TEMPLATE
# ==========================
def create_first_segment_prompt(topic, segment, target_words):
    """Creates a prompt template for the first segment (with welcome)"""
    
    template = f"""==============================================
SEGMENT 1 - OPENING SEGMENT (WITH WELCOME)
==============================================

MAIN TOPIC:
{topic}

SEGMENT TITLE:
{segment["title"]}

PREVIOUS SEGMENTS COVERED:
None - This is the opening segment

WHAT THIS SEGMENT IS ABOUT:
{segment["summary"]}

LEARNING GOAL/FUN FACTS FOR THIS SEGMENT:
{segment["learning_goal"]}

ADDITIONAL NOTES / FUN FACTS TO DISCUSS:
- This is the opening of the podcast
- Include a warm, natural greeting from the HOST
- The HOST briefly introduces the topic and explains why they're curious
- The EXPERT begins exploring the first concept in depth
- Set the tone for the entire conversation

==============================================
WRITING GUIDELINES:
==============================================

CONVERSATION STYLE:
- Two speakers: HOST (curious, non-expert) and EXPERT (knowledgeable)
- The EXPERT should speak significantly more than the HOST (EXPERT: ~90% of words, HOST: ~10%)
- The EXPERT can speak for multiple sentences at a time, giving in-depth explanations, examples, or analogies
- The HOST speaks briefly and occasionally: asks questions, seeks clarification, or reacts naturally

LANGUAGE & TONE:
- Use simple, spoken language with short sentences when needed
- Be direct, conversational, and natural
- Avoid AI clichés like "dive into," "game-changing," "unleash"
- Write as people actually speak; starting sentences with "and" or "but" is fine
- Avoid hype, marketing language, or unnecessary adjectives
- Keep it honest, real, and engaging

TARGET:
- Approximately {target_words} words for this segment
- Do NOT include stage directions or descriptions
- Do NOT end with a conclusion; the podcast continues

OUTPUT FORMAT:
Return ONLY valid JSON with the dialogue. No markdown, no explanations.
JSON format:
[
  {{
    "speaker": "HOST",
    "text": "actual words spoken by the host"
  }},
  {{
    "speaker": "EXPERT",
    "text": "actual words spoken by the expert"
  }}
]

IMPORTANT: Return ONLY the JSON array. No additional text or formatting.

==============================================
"""
    
    return template


# ==========================
# STEP 2B — CREATE CONTINUING SEGMENT PROMPT TEMPLATE
# ==========================
def create_continuing_segment_prompt(topic, segment, previous_summary, target_words, segment_number):
    """Creates a prompt template for continuing segments"""
    
    template = f"""==============================================
SEGMENT {segment_number} - CONTINUATION
==============================================

MAIN TOPIC:
{topic}

SEGMENT TITLE:
{segment["title"]}

PREVIOUS SEGMENTS COVERED:
{previous_summary}

WHAT THIS SEGMENT IS ABOUT:
{segment["summary"]}

LEARNING GOAL FOR THIS SEGMENT:
{segment["learning_goal"]}

ADDITIONAL NOTES / FUN FACTS TO DISCUSS:
- Continue naturally from where the previous segment ended
- Explore new aspects of the topic that build on what was previously discussed
- Provide in-depth explanations, examples, stories, or analogies
- Keep the conversation flowing seamlessly

==============================================
WRITING GUIDELINES:
==============================================

CONVERSATION STYLE:
- Two speakers: HOST (curious, non-expert) and EXPERT (knowledgeable)
- The EXPERT should speak significantly more than the HOST (EXPERT: ~90% of words, HOST: ~10%)
- The EXPERT can speak for multiple sentences at a time, giving in-depth explanations, examples, or analogies
- The HOST speaks briefly and occasionally: asks questions, seeks clarification, or reacts naturally

LANGUAGE & TONE:
- Use simple, spoken language with short sentences when needed
- Be direct, conversational, and natural
- Avoid AI clichés like "dive into," "game-changing," "unleash"
- Write as people actually speak; starting sentences with "and" or "but" is fine
- Avoid hype, marketing language, or unnecessary adjectives
- Keep it honest, real, and engaging

CRITICAL RULES FOR CONTINUATION:
- Do NOT greet or welcome anyone (the podcast already started)
- Do NOT reintroduce the topic
- Do NOT say things like "In this segment" or "Now let's talk about"
- Continue naturally from where the previous segment ended
- This is the MIDDLE of a conversation, not the beginning
- Smoothly flow from the previous segment to the current segment
- The HOST and EXPERT are already engaged in discussion

TARGET:
- Approximately {target_words} words for this segment
- Do NOT include stage directions or descriptions
- Do NOT end with a conclusion unless this is the final segment

OUTPUT FORMAT:
Return ONLY valid JSON with the dialogue. No markdown, no explanations.
JSON format:
[
  {{
    "speaker": "HOST",
    "text": "actual words spoken by the host"
  }},
  {{
    "speaker": "EXPERT",
    "text": "actual words spoken by the expert"
  }}
]

IMPORTANT: Return ONLY the JSON array. No additional text or formatting.

==============================================
"""
    
    return template


# ==========================
# STEP 3 — BUILD PODCAST PROMPT TEMPLATES
# ==========================
def build_podcast(topic, total_minutes):
    outline = generate_outline(topic, total_minutes)
    words_per_segment = WORDS_PER_MINUTE * SEGMENT_MINUTES

    podcast_prompts = []
    previous_summaries = []

    for i, segment in enumerate(outline, start=1):
        # Use different template for first segment vs continuing segments
        if i == 1:
            # First segment: includes welcome and introduction
            print(f"\n📝 Creating prompt template for opening segment...")
            prompt_template = create_first_segment_prompt(
                topic,
                segment,
                words_per_segment
            )
        else:
            # Continuing segments: seamless continuation
            print(f"\n📝 Creating prompt template for segment {i}...")
            
            # Build summary of what was covered previously
            previous_summary = "\n".join([
                f"- Segment {j}: {previous_summaries[j-1]}"
                for j in range(1, i)
            ])
            
            prompt_template = create_continuing_segment_prompt(
                topic,
                segment,
                previous_summary,
                words_per_segment,
                i
            )

        podcast_prompts.append({
            "segment": i,
            "title": segment["title"],
            "prompt_template": prompt_template
        })

        # Store the learning goal for building future summaries
        previous_summaries.append(segment["learning_goal"])

    return podcast_prompts

# ==========================
# STEP 4 — SAVE PROMPT TEMPLATES
# ==========================
def save_podcast(topic, podcast_prompts):
    """Save individual prompt template files for each segment"""
    os.makedirs("output/prompts", exist_ok=True)

    # Save metadata JSON
    with open("output/prompts/metadata.json", "w", encoding="utf-8") as f:
        json.dump({
            "topic": topic,
            "total_segments": len(podcast_prompts),
            "segments": [
                {
                    "segment": seg["segment"],
                    "title": seg["title"]
                }
                for seg in podcast_prompts
            ]
        }, f, indent=2)

    # Save individual prompt template files
    for seg in podcast_prompts:
        filename = f"output/prompts/segment_{seg['segment']:02d}_prompt.txt"
        with open(filename, "w", encoding="utf-8") as f:
            f.write(seg["prompt_template"])
        print(f"✅ Saved: {filename}")

# ==========================
# STEP 5 — ELEVENLABS PODCAST GENERATION
# ==========================
def generate_podcast_with_elevenlabs(topic, podcast_prompts):
    """Generate a full podcast audio using ElevenLabs API"""
    
    if not elevenlabs_api_key:
        print("❌ ElevenLabs API key not configured!")
        return None
    
    print("\n🎙️ Generating podcast audio with ElevenLabs...")
    
    # Combine all segment prompts into one full script prompt
    full_script_sections = []
    for seg in podcast_prompts:
        full_script_sections.append(seg["prompt_template"])
    
    combined_prompt = "\n\n" + "="*60 + "\n\n".join(full_script_sections)
    
    # Prepare the API request
    url = "https://api.elevenlabs.io/v1/text-to-speech/podcast"
    
    headers = {
        "xi-api-key": elevenlabs_api_key,
        "Content-Type": "application/json"
    }
    
    # Build the payload for podcast generation
    payload = {
        "text": combined_prompt,
        "name": f"Podcast: {topic}",
        "voice_settings": {
            "stability": 0.5,
            "similarity_boost": 0.75
        }
    }
    
    try:
        # Create the podcast
        print("📤 Sending request to ElevenLabs...")
        response = requests.post(url, json=payload, headers=headers)
        
        if response.status_code == 200:
            # Save the audio file
            audio_filename = "output/podcast_audio.mp3"
            with open(audio_filename, "wb") as f:
                f.write(response.content)
            print(f"✅ Podcast audio saved: {audio_filename}")
            return audio_filename
        else:
            print(f"❌ ElevenLabs API error: {response.status_code}")
            print(f"Response: {response.text}")
            return None
            
    except Exception as e:
        print(f"❌ Error generating podcast: {str(e)}")
        return None

def generate_podcast_with_conversation_mode(topic, podcast_prompts):
    """
    Alternative: Generate podcast using ElevenLabs conversational AI
    This creates a more natural dialogue between HOST and EXPERT
    """
    
    if not elevenlabs_api_key:
        print("❌ ElevenLabs API key not configured!")
        return None
    
    print("\n🎙️ Generating conversational podcast with ElevenLabs...")
    
    # Combine all segments into one cohesive prompt
    segments_text = []
    for i, seg in enumerate(podcast_prompts, 1):
        segments_text.append(f"SEGMENT {i}:\n{seg['prompt_template']}")
    
    full_prompt = "\n\n".join(segments_text)
    
    url = "https://api.elevenlabs.io/v1/convai/conversation"
    
    headers = {
        "xi-api-key": elevenlabs_api_key,
        "Content-Type": "application/json"
    }
    
    payload = {
        "text": full_prompt,
        "model_id": "eleven_multilingual_v2"
    }
    
    try:
        print("📤 Sending request to ElevenLabs Conversational AI...")
        response = requests.post(url, json=payload, headers=headers)
        
        if response.status_code == 200 or response.status_code == 201:
            # Check if we got audio directly or need to poll
            if response.headers.get('content-type', '').startswith('audio'):
                audio_filename = "output/podcast_audio.mp3"
                with open(audio_filename, "wb") as f:
                    f.write(response.content)
                print(f"✅ Podcast audio saved: {audio_filename}")
                return audio_filename
            else:
                # Handle job-based response
                result = response.json()
                if 'audio_url' in result:
                    print("📥 Downloading audio from URL...")
                    audio_response = requests.get(result['audio_url'])
                    audio_filename = "output/podcast_audio.mp3"
                    with open(audio_filename, "wb") as f:
                        f.write(audio_response.content)
                    print(f"✅ Podcast audio saved: {audio_filename}")
                    return audio_filename
        else:
            print(f"❌ ElevenLabs API error: {response.status_code}")
            print(f"Response: {response.text}")
            return None
            
    except Exception as e:
        print(f"❌ Error generating podcast: {str(e)}")
        return None

def combine_audio_segments(segment_files, output_filename="output/podcast_full.mp3"):
    """Combine multiple audio segment files into one"""
    
    if not PYDUB_AVAILABLE:
        print("⚠️  pydub not installed. Cannot combine segments automatically.")
        print("   Install with: pip install pydub")
        print("   Or combine the segments manually using audio editing software.")
        return None
    
    try:
        print("\n🔗 Combining audio segments...")
        combined = AudioSegment.empty()
        
        for i, segment_file in enumerate(segment_files, 1):
            print(f"  → Adding segment {i}/{len(segment_files)}...")
            audio = AudioSegment.from_mp3(segment_file)
            combined += audio
        
        # Export combined audio
        print(f"  → Exporting combined podcast...")
        combined.export(output_filename, format="mp3")
        print(f"✅ Combined podcast saved: {output_filename}")
        
        return output_filename
        
    except Exception as e:
        print(f"❌ Error combining segments: {str(e)}")
        return None

def parse_dialogue_json(script_text):
    """Parse the LLM-generated script and extract JSON dialogue"""
    import re
    
    # Try to extract JSON from markdown code blocks if present
    if "```json" in script_text:
        start = script_text.find("```json") + 7
        end = script_text.find("```", start)
        script_text = script_text[start:end].strip()
    elif "```" in script_text:
        start = script_text.find("```") + 3
        end = script_text.find("```", start)
        script_text = script_text[start:end].strip()
    
    # Clean up the text - remove any problematic control characters
    script_text = script_text.strip()
    
    # Remove any control characters except newlines and tabs
    script_text = re.sub(r'[\x00-\x08\x0B-\x0C\x0E-\x1F\x7F]', '', script_text)
    
    try:
        dialogue = json.loads(script_text)
        return dialogue
    except json.JSONDecodeError as e:
        print(f"  ⚠️  Failed to parse JSON: {e}")
        print(f"  Attempting to fix and retry...")
        
        # Try fixing common JSON issues
        try:
            # Replace smart quotes with regular quotes
            script_text = script_text.replace('\u2018', "'").replace('\u2019', "'")
            script_text = script_text.replace('\u201C', '"').replace('\u201D', '"')
            
            # Try parsing again
            dialogue = json.loads(script_text)
            print(f"  ✅ Successfully parsed after fixing quotes")
            return dialogue
        except:
            pass
        
        print(f"  Attempting to extract dialogue manually...")
        
        # Fallback: Try to parse line by line if JSON fails
        lines = script_text.split('\n')
        dialogue = []
        current_speaker = None
        current_text = ""
        
        for line in lines:
            line = line.strip()
            # Look for speaker patterns
            if '"speaker"' in line and '"HOST"' in line:
                if current_speaker and current_text:
                    dialogue.append({"speaker": current_speaker, "text": current_text.strip()})
                current_speaker = "HOST"
                current_text = ""
            elif '"speaker"' in line and '"EXPERT"' in line:
                if current_speaker and current_text:
                    dialogue.append({"speaker": current_speaker, "text": current_text.strip()})
                current_speaker = "EXPERT"
                current_text = ""
            elif '"text"' in line:
                # Extract text value
                match = re.search(r'"text"\s*:\s*"(.+)"', line)
                if match:
                    current_text = match.group(1)
            elif line.startswith('HOST:'):
                if current_speaker and current_text:
                    dialogue.append({"speaker": current_speaker, "text": current_text.strip()})
                current_speaker = "HOST"
                current_text = line[5:].strip()
            elif line.startswith('EXPERT:'):
                if current_speaker and current_text:
                    dialogue.append({"speaker": current_speaker, "text": current_text.strip()})
                current_speaker = "EXPERT"
                current_text = line[7:].strip()
        
        # Don't forget the last entry
        if current_speaker and current_text:
            dialogue.append({"speaker": current_speaker, "text": current_text.strip()})
        
        if dialogue:
            print(f"  ✅ Extracted {len(dialogue)} dialogue lines manually")
            return dialogue
        else:
            print(f"  ❌ Could not parse dialogue")
            return None

def generate_audio_for_line(text, voice_id, output_file, max_retries=3):
    """Generate audio for a single line of dialogue with retry logic"""
    
    url = f"https://api.elevenlabs.io/v1/text-to-speech/{voice_id}"
    
    headers = {
        "xi-api-key": elevenlabs_api_key,
        "Content-Type": "application/json"
    }
    
    payload = {
        "text": text,
        "model_id": "eleven_multilingual_v2",
        "voice_settings": {
            "stability": 0.5,
            "similarity_boost": 0.75,
            "style": 0.0,
            "use_speaker_boost": True
        }
    }
    
    for attempt in range(max_retries):
        try:
            # Longer timeout for better reliability
            response = requests.post(url, json=payload, headers=headers, timeout=30)
            
            if response.status_code == 200:
                with open(output_file, "wb") as f:
                    f.write(response.content)
                return True
            elif response.status_code == 429:
                # Rate limit hit - wait longer
                wait_time = (attempt + 1) * 5
                print(f"    ⚠️  Rate limit hit. Waiting {wait_time} seconds...")
                time.sleep(wait_time)
                continue
            else:
                print(f"    ❌ Error: {response.status_code} - {response.text}")
                if attempt < max_retries - 1:
                    print(f"    🔄 Retrying... (attempt {attempt + 2}/{max_retries})")
                    time.sleep(2)
                    continue
                return False
                
        except requests.exceptions.Timeout:
            print(f"    ⚠️  Request timed out")
            if attempt < max_retries - 1:
                wait_time = (attempt + 1) * 3
                print(f"    🔄 Retrying in {wait_time} seconds... (attempt {attempt + 2}/{max_retries})")
                time.sleep(wait_time)
                continue
            return False
            
        except requests.exceptions.ConnectionError as e:
            print(f"    ⚠️  Connection error: {str(e)}")
            if attempt < max_retries - 1:
                wait_time = (attempt + 1) * 5
                print(f"    🔄 Retrying in {wait_time} seconds... (attempt {attempt + 2}/{max_retries})")
                time.sleep(wait_time)
                continue
            return False
            
        except Exception as e:
            print(f"    ❌ Error: {str(e)}")
            if attempt < max_retries - 1:
                print(f"    🔄 Retrying... (attempt {attempt + 2}/{max_retries})")
                time.sleep(2)
                continue
            return False
    
    return False

def generate_segments_and_combine(topic, podcast_prompts):
    """
    Generate each segment separately using text-to-speech with proper voice switching
    Uses JSON dialogue format to separate HOST and EXPERT voices
    """
    
    if not elevenlabs_api_key:
        print("❌ ElevenLabs API key not configured!")
        return None
    
    if not PYDUB_AVAILABLE:
        print("❌ pydub is required for this feature. Install with: pip install pydub")
        return None
    
    print("\n🎙️ Generating podcast segments with ElevenLabs TTS...")
    
    # Voice configuration - change these to customize
    host_voice_id = "21m00Tcm4TlvDq8ikWAM"  # Rachel (female)
    expert_voice_id = "29vD33N1CtxCmqQRPOHJ"  # Drew (male)
    
    segment_files = []
    
    for i, seg in enumerate(podcast_prompts, 1):
        print(f"\n📝 Generating segment {i}/{len(podcast_prompts)}...")
        
        # Generate the script from the prompt using Gemini
        print(f"  → Creating script with LLM...")
        script = call_llm(seg['prompt_template'])
        
        # Save the raw script
        script_filename = f"output/prompts/segment_{i:02d}_script.txt"
        with open(script_filename, "w", encoding="utf-8") as f:
            f.write(script)
        print(f"  ✅ Script saved: {script_filename}")
        
        # Parse the JSON dialogue
        print(f"  → Parsing dialogue...")
        dialogue = parse_dialogue_json(script)
        
        if not dialogue:
            print(f"  ❌ Failed to parse dialogue for segment {i}")
            return None
        
        # Save parsed dialogue as JSON
        dialogue_json_file = f"output/prompts/segment_{i:02d}_dialogue.json"
        with open(dialogue_json_file, "w", encoding="utf-8") as f:
            json.dump(dialogue, f, indent=2)
        print(f"  ✅ Parsed {len(dialogue)} dialogue lines")
        
        # Generate audio for each line
        print(f"  → Generating audio for each line...")
        line_audio_files = []
        
        for j, line in enumerate(dialogue):
            speaker = line.get("speaker", "EXPERT")
            text = line.get("text", "")
            
            if not text:
                continue
            
            # Choose voice based on speaker
            voice_id = host_voice_id if speaker == "HOST" else expert_voice_id
            
            # Generate audio file for this line
            line_audio_file = f"output/temp/segment_{i:02d}_line_{j:03d}.mp3"
            os.makedirs("output/temp", exist_ok=True)
            
            print(f"    {speaker}: {text[:50]}{'...' if len(text) > 50 else ''}")
            
            if generate_audio_for_line(text, voice_id, line_audio_file):
                line_audio_files.append(line_audio_file)
            else:
                print(f"  ❌ Failed to generate audio for line {j}")
                return None
            
            # Delay to avoid rate limits (especially important for free tier)
            time.sleep(API_DELAY_SECONDS)
        
        # Combine all lines into one segment
        print(f"  → Combining {len(line_audio_files)} audio lines...")
        try:
            segment_audio = AudioSegment.empty()
            
            for line_file in line_audio_files:
                audio = AudioSegment.from_mp3(line_file)
                segment_audio += audio
                # Add a small pause between lines (300ms)
                segment_audio += AudioSegment.silent(duration=300)
            
            # Save the complete segment
            segment_filename = f"output/segment_{i:02d}_audio.mp3"
            segment_audio.export(segment_filename, format="mp3")
            segment_files.append(segment_filename)
            print(f"  ✅ Segment audio saved: {segment_filename}")
            
        except Exception as e:
            print(f"  ❌ Error combining audio lines: {str(e)}")
            return None
    
    # Clean up temporary files
    print(f"\n🧹 Cleaning up temporary files...")
    try:
        import shutil
        if os.path.exists("output/temp"):
            shutil.rmtree("output/temp")
        print(f"  ✅ Temporary files removed")
    except Exception as e:
        print(f"  ⚠️  Could not remove temp files: {e}")
    
    # Combine all segments
    print(f"\n✅ All {len(segment_files)} segments generated!")
    
    # Combine into final podcast
    combined_file = combine_audio_segments(segment_files)
    
    if combined_file:
        print(f"\n🎉 Final podcast: {combined_file}")
    else:
        print("📝 Individual segment files saved:")
        for sf in segment_files:
            print(f"   - {sf}")
    
    return segment_files

# ==========================
# MAIN
# ==========================
if __name__ == "__main__":
    topic = input("What do you want to learn? ")
    minutes = int(input("Commute duration (minutes): "))

    # Generate the podcast structure and prompts
    podcast_prompts = build_podcast(topic, minutes)
    save_podcast(topic, podcast_prompts)

    print("\n" + "="*50)
    print("✅ Podcast prompt templates generated successfully!")
    print(f"📁 Location: output/prompts/")
    print(f"📊 Total segments: {len(podcast_prompts)}")
    print("="*50)
    
    # Ask if user wants to generate audio with ElevenLabs
    if elevenlabs_api_key:
        generate_audio = input("\n🎙️ Generate audio with ElevenLabs? (y/n): ").strip().lower()
        
        if generate_audio == 'y':
            print("\n📋 Choose generation method:")
            print("1. Generate segments separately (recommended)")
            print("2. Generate full podcast at once")
            
            method = input("Enter choice (1 or 2): ").strip()
            
            if method == "1":
                audio_files = generate_segments_and_combine(topic, podcast_prompts)
                if audio_files:
                    print("\n" + "="*50)
                    print("✅ Podcast audio generation complete!")
                    print(f"📁 Audio files saved in: output/")
                    print("="*50)
            elif method == "2":
                audio_file = generate_podcast_with_elevenlabs(topic, podcast_prompts)
                if audio_file:
                    print("\n" + "="*50)
                    print("✅ Podcast audio generation complete!")
                    print(f"📁 Audio file: {audio_file}")
                    print("="*50)
    else:
        print("\n⚠️ ElevenLabs API key not configured. Skipping audio generation.")
        print("   Add your API key to the 'elevenlabs_api_key' variable to enable audio generation.")
