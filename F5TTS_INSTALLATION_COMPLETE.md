# F5-TTS Installation Complete ✅

## Installation Summary
Successfully reinstalled F5-TTS using the official pip/venv installation method after abandoning the problematic uv package manager approach.

## Environment Details
- **Python Version**: 3.11.14_1 (via Homebrew)
- **Python Path**: `/opt/homebrew/bin/python3.11`
- **Virtual Environment**: `/Users/mond/Desktop/tts/F5-TTS/.venv`
- **PyTorch Version**: 2.9.1 for Apple Silicon
- **Gradio Version**: 5.50.0

## Installation Steps Taken
1. Installed Python 3.11 via Homebrew
2. Created fresh venv with Python 3.11
3. Installed PyTorch 2.9.1 and torchaudio 2.9.1
4. Installed F5-TTS in editable mode with `pip install -e .`

## Service Status
- **F5-TTS**: Running on port 7860 ✅
- **IndexTTS**: Running on port 7861 ✅
- **Cloudflare Tunnel**: Active ✅

## Access URLs
- F5-TTS: https://f5tts.propsdin.com
- IndexTTS: https://indextts.propsdin.com
- Local F5-TTS: http://localhost:7860
- Local IndexTTS: http://localhost:7861

## Known Issues

### 1. Cloudflare Workers Authentication
**Status**: Documented, not yet fixed
**Description**: Cloudflare Workers at `propsdin.com/tts-auth` intercepts all requests to F5-TTS and IndexTTS, including Gradio API calls.

**Solution**: Modify the Workers script at `/Users/mond/Desktop/web/propsdin-theme/worker.ts` to bypass authentication for the following paths:
- `/gradio_api/*`
- `/queue/*`
- `/file/*`
- `/upload/*`
- `/api/*`

**Documentation**: See `WORKERS_AUTH_FIX.md` for detailed implementation.

### 2. torchcodec Compatibility
**Status**: Mitigated
**Description**: torchcodec 0.8.1 is installed as a dependency but may cause `RuntimeError: Could not load libtorchcodec` on Apple Silicon.

**Mitigation**: 
- Set `TORCHAUDIO_BACKEND=soundfile` environment variable (already configured in startup script)
- Modified code to force `backend="soundfile"` in `torchaudio.load()` calls
- Files modified:
  - `src/f5_tts/infer/infer_gradio.py`
  - `src/f5_tts/infer/utils_infer.py`

## Log Files
- F5-TTS: `/Users/mond/Desktop/tts/F5-TTS/f5tts.log`
- IndexTTS: `/Users/mond/Desktop/tts/index-tts/indextts.log`
- Cloudflare Tunnel: `/Users/mond/Desktop/tts/tunnel.log`

## Management Scripts
All scripts are located in `/Users/mond/Desktop/tts/`:

- `start_f5tts.sh` - Start F5-TTS service
- `start_indextts.sh` - Start IndexTTS service
- `start_tunnel.sh` - Start Cloudflare Tunnel
- `stop_services.sh` - Stop all services
- `restart_services.sh` - Restart all services
- `check_status.sh` - Check status of all services
- `watch_f5tts_log.sh` - Monitor F5-TTS logs
- `watch_indextts_log.sh` - Monitor IndexTTS logs
- `watch_tunnel_log.sh` - Monitor tunnel logs

## Testing

### Local Testing
```bash
# Check F5-TTS interface
curl -I http://localhost:7860/

# Check IndexTTS interface
curl -I http://localhost:7861/
```

### Remote Testing (requires authentication bypass)
Once Cloudflare Workers authentication is configured:
1. Access https://f5tts.propsdin.com
2. Upload a reference audio file
3. Enter text to generate
4. Verify file upload doesn't show `upload_id=undefined`
5. Generate speech and verify audio output

## Next Steps
1. **Fix Cloudflare Workers Authentication** (priority)
   - Edit `/Users/mond/Desktop/web/propsdin-theme/worker.ts`
   - Add API path bypasses as documented in `WORKERS_AUTH_FIX.md`
   - Deploy updated Workers script

2. **Verify File Upload Functionality**
   - After authentication fix, test file uploads
   - Ensure `upload_id` is properly generated
   - Test audio generation end-to-end

3. **Monitor for torchcodec Issues**
   - Watch logs for any torchcodec-related errors
   - If errors occur, verify `TORCHAUDIO_BACKEND=soundfile` is set
   - Check that code modifications are working correctly

## Package Details
Key packages installed:
- torch==2.9.1
- torchaudio==2.9.1
- gradio==5.50.0
- transformers==4.57.1
- librosa==0.11.0
- soundfile==0.13.1
- torchcodec==0.8.1
- accelerate==1.12.0
- wandb==0.23.0
- huggingface-hub==0.36.0

Total packages: 148 (including all dependencies)

## Environment Variables
Configured in `start_f5tts.sh`:
```bash
export PATH="/opt/homebrew/bin:$PATH"
export HF_ENDPOINT=https://hf-mirror.com
export TORCHAUDIO_BACKEND=soundfile
export TORCHAUDIO_USE_BACKEND_DISPATCHER=1
```

## Installation Time
- Python 3.11 installation: ~1 minute
- PyTorch installation: ~2 minutes
- F5-TTS + dependencies: ~5 minutes
- Total: ~8 minutes

## Success Confirmation
✅ Python 3.11 installed
✅ Fresh venv created
✅ PyTorch 2.9.1 installed
✅ F5-TTS 1.1.9 installed in editable mode
✅ Service starts without critical errors
✅ Port 7860 listening
✅ Gradio interface accessible locally
✅ Cloudflare Tunnel routing configured

---
**Installation Date**: November 23, 2025
**System**: macOS Apple Silicon
**Shell**: zsh
