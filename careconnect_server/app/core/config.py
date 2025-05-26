# careconnect_server/app/core/config.py
import os
from pydantic_settings import BaseSettings
from dotenv import load_dotenv

# --- Environment Variable Loading ---
print("[CONFIG START] Starting app/core/config.py execution...")

dotenv_path = os.path.join(os.path.dirname(os.path.dirname(os.path.dirname(__file__))), '.env')
print(f"[CONFIG STEP 1] Expected .env path: {dotenv_path}")

if os.path.exists(dotenv_path):
    print(f"[CONFIG STEP 2] .env file FOUND at: {dotenv_path}")
    # override=True ensures .env values overwrite existing system env vars for this process
    # verbose=True prints what dotenv is doing
    load_dotenv(dotenv_path=dotenv_path, verbose=True, override=True)
    # Let's check immediately if GEMINI_API_KEY was loaded into os.environ by python-dotenv
    gemini_key_from_os_env_after_dotenv = os.getenv('GEMINI_API_KEY')
    if gemini_key_from_os_env_after_dotenv:
        print(f"[CONFIG STEP 3] GEMINI_API_KEY successfully loaded into os.environ by python-dotenv. Length: {len(gemini_key_from_os_env_after_dotenv)}")
    else:
        print(f"[CONFIG STEP 3] GEMINI_API_KEY NOT loaded into os.environ by python-dotenv from .env file.")
else:
    print(f"[CONFIG STEP 2] .env file NOT FOUND at: {dotenv_path}. Please ensure it exists in the project root (careconnect_server/.env) with GEMINI_API_KEY=\"your_key\".")

class Settings(BaseSettings):
    GEMINI_API_KEY: str = "" # This MUST match the variable name in your .env file
    LLM_MODEL_NAME: str = "gemini-2.5-pro" # Default if not set elsewhere

    class Config:
        env_prefix = '' 
        extra = "ignore"

print("[CONFIG STEP 4] Initializing Pydantic Settings object...")
settings = Settings()

api_key_status_pydantic = 'SET and non-empty' if settings.GEMINI_API_KEY else 'EMPTY or NOT SET by Pydantic'
print(f"[CONFIG STEP 5] Pydantic Settings - GEMINI_API_KEY status: {api_key_status_pydantic}")
print(f"[CONFIG STEP 5] Pydantic Settings - LLM_MODEL_NAME: {settings.LLM_MODEL_NAME}")

if settings.GEMINI_API_KEY:
    os.environ['GOOGLE_API_KEY'] = settings.GEMINI_API_KEY
    print(f"[CONFIG STEP 6] GOOGLE_API_KEY environment variable has been SET from settings.GEMINI_API_KEY.")
    # Verify it was set in os.environ
    google_api_key_in_os_env = os.getenv('GOOGLE_API_KEY')
    if google_api_key_in_os_env == settings.GEMINI_API_KEY:
        print(f"[CONFIG STEP 6] Verification: GOOGLE_API_KEY is correctly set in os.environ.")
    else:
        print(f"[CONFIG STEP 6] Verification WARNING: GOOGLE_API_KEY in os.environ does not match settings.GEMINI_API_KEY or is not set.")
else:
    print(f"[CONFIG STEP 6] settings.GEMINI_API_KEY is empty, so GOOGLE_API_KEY environment variable was NOT SET.")
    if not os.getenv('GOOGLE_API_KEY'):
        print(f"[CONFIG STEP 6] Also, GOOGLE_API_KEY was not found in current os.environ from other sources.")

print("[CONFIG END] Finished app/core/config.py execution.")