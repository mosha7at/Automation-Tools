#!/bin/bash

# --- 1. أداة استخراج وترجمة Subtitles (النسخة المتوافقة مع بايثون 3.14) ---
sup_ar() {
    # استخراج النص الإنجليزي باستخدام Whisper
    whisper "$1" --model base --language English --device cpu
    
    local srt_file="${1%.*}.srt"
    local output_file="${1%.*}_ar.srt"

    if [ -f "$srt_file" ]; then
        echo "⏳ جاري الترجمة الاحترافية (Direct Injection)..."
        # تشغيل كود بايثون مدمج يعالج مشكلة مكتبة cgi
        python3 - "$srt_file" "$output_file" <<'EOF'
import sys
import types
try:
    import cgi
except ImportError:
    sys.modules['cgi'] = types.ModuleType('cgi')
    sys.modules['cgi'].parse_header = lambda x: (x, {})

from googletrans import Translator
input_path, output_path = sys.argv[1], sys.argv[2]
translator = Translator()

try:
    with open(input_path, 'r', encoding='utf-8') as f:
        lines = f.readlines()
    translated_lines = []
    for line in lines:
        if '-->' in line or line.strip().isdigit() or not line.strip():
            translated_lines.append(line)
        else:
            res = translator.translate(line.strip(), src='en', dest='ar')
            translated_lines.append(res.text + '\n')
    with open(output_path, 'w', encoding='utf-8') as f:
        f.writelines(translated_lines)
    print(f"✅ Done: {output_path}")
except Exception as e:
    print(f"❌ Error: {e}")
EOF
    else
        echo "❌ لم يتم العثور على ملف srt."
    fi
}

# --- 2. أداة استخراج النص الإنجليزي فقط ---
sup() {
    whisper "$1" --model base --language English --device cpu
}

# --- 3. أدوات التحميل السريع (yt-dlp) ---
# تحميل بأقصى سرعة باستخدام aria2c
alias fast='yt-dlp --external-downloader aria2c --external-downloader-args "-x 16 -s 16 -k 1M"'

# تحميل فيديو مع تخطي حماية المواقع (باستخدام الكوكيز)
alias tfast='yt-dlp -f "bestvideo+bestaudio/best" --cookies-from-browser firefox'
