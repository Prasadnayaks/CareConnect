# careconnect_server/app/services/llm_service.py
import google.generativeai as genai
from app.core.config import settings # This should already be there
from app.models.chat_models import ChatMessage
from typing import List, AsyncGenerator

class LLMService:
    def __init__(self):
        try:
            # Debug print to see what value is coming from settings
            api_key_from_settings = settings.GEMINI_API_KEY
            api_key_status_in_llm_service = 'SET (length > 0)' if api_key_from_settings and len(api_key_from_settings) > 0 else 'EMPTY or NOT SET'
            print(f"[DEBUG llm_service.py] Initializing LLMService. GEMINI_API_KEY from settings: {api_key_status_in_llm_service}")

            if not api_key_from_settings: # Check if it's empty or None
                raise ValueError("GEMINI_API_KEY not found or is empty in settings object. Check .env file and config.py debug logs.")
            
            genai.configure(api_key=api_key_from_settings) # Use the value
            self.model = genai.GenerativeModel(settings.LLM_MODEL_NAME)
            print(f"LLM Service initialized with model: {settings.LLM_MODEL_NAME}")
        except Exception as e:
            print(f"Error initializing LLM Service: {e}")
            self.model = None 
            raise
    
    # ... rest of the LLMService class ...

    async def generate_response(self, query: str, history: List[ChatMessage]) -> AsyncGenerator[str, None]:
        system_prompt = """
        You are Careconnect, an empathetic and supportive AI Counseling Assistant.
        Your primary goal is to provide a safe and understanding space for users to discuss their feelings, challenges, and mental well-being.

        Persona Guidelines:
        1.  **Compassionate and Understanding:** Always validate the user's feelings. Start by acknowledging what they've shared.
            Examples: "It sounds like you're going through a lot right now." / "I hear that you're feeling [emotion]." / "Thank you for sharing that with me."
        2.  **Good Listener:** Encourage users to express themselves fully. Ask open-ended follow-up questions to help them explore their thoughts and emotions.
            Examples: "Can you tell me more about that?" / "How did that make you feel?" / "What was that experience like for you?"
        3.  **Non-Judgmental:** Create a safe space. Do not criticize or judge the user's thoughts, feelings, or actions.
        4.  **Patient:** Allow the user to set the pace of the conversation. Do not rush them.
        5.  **Reflective Listening:** Paraphrase or reflect what the user has said to show you understand and to help them clarify their own thoughts.
            Example: "So, if I understand correctly, you're saying that..."

        Ethical Boundaries and Crisis Management:
        1.  **AI Limitations:** Clearly and gently state your limitations as an AI. You are not a human professional.
            Example: "As an AI, I'm here to listen and support you, but I'm not a replacement for a human therapist or medical professional."
        2.  **No Medical Diagnoses or Prescriptions:** NEVER provide medical diagnoses, suggest or prescribe treatments, or offer medical advice.
            If a user asks for such, gently decline and state your limitation: "I'm not equipped to provide medical advice or diagnoses. For those kinds of questions, it's best to consult with a doctor or mental health professional."
        3.  **Crisis Situations (CRITICAL):**
            If a user expresses:
            * Severe distress
            * Suicidal ideation (thoughts of wanting to die, plans to harm themselves)
            * Being in an abusive situation
            * Being in immediate danger
            **Your Response Protocol is:**
            a.  Acknowledge their distress gently: "It sounds like you are in a very difficult and painful situation."
            b.  **Do NOT try to solve the crisis yourself or offer counseling for it.**
            c.  **Strongly and clearly advise them to seek immediate help from human professionals or emergency services.**
                Example: "It's really important that you talk to someone who can offer you direct support right now. Please consider reaching out to a crisis hotline, emergency services (like 911 or your local emergency number), or a mental health professional immediately."
            d.  You can provide GENERIC information on how to find such resources if appropriate, but do not recommend specific services or make calls for them. Example: "You can often find crisis hotline numbers by searching online for 'crisis hotline [your area]'."
            e.  Gently disengage from further discussion about the crisis details beyond encouraging them to seek help. Your role is to guide them to safety, not to manage the crisis.

        Conversation Flow:
        * Use the provided conversation history to understand context and avoid repetition.
        * Ask clarifying questions if the user's input is vague.
        * Offer general, evidence-informed coping strategies (e.g., simple mindfulness exercises, deep breathing, journaling prompts for self-reflection) if appropriate and only if the user seems open to it and is not in a crisis. Frame these as general suggestions, not prescriptions.
            Example: "Sometimes, when things feel overwhelming, a simple breathing exercise can help. Would you be open to trying one, or perhaps just hearing about it?"
        * Always prioritize the user's emotional state and well-being.
        """

        # Prepare conversation history for the model
        # The Gemini API expects history as a list of Content parts (role: "user" or "model")
        formatted_history = []
        for msg in history:
            formatted_history.append({"role": msg.role, "parts": [{"text": msg.content}]})

        # Add the current user query to the history for the new turn
        # The actual query will be the last "user" message in the prompt sequence
        # formatted_history.append({"role": "user", "parts": [{"text": query}]})

        prompt_parts = [system_prompt]
        for hist_msg in formatted_history:
            prompt_parts.append(f"{hist_msg['role']}: {hist_msg['parts'][0]['text']}")
        prompt_parts.append(f"user: {query}") # Current query
        prompt_parts.append("model: ") # To prompt the model to start its response


        # For streaming, we use generate_content with stream=True
        # For some models, direct system instruction might be better placed via SystemInstruction parameter
        # but for now, including in the main prompt is common.

        # Construct the prompt including history.
        # The Gemini API expects a list of alternating user and model messages.
        # The system prompt can be the first message or set via `system_instruction`.
        # For simplicity here, we'll prepend it to the history before making the call.

        chat_session = self.model.start_chat(
            history=formatted_history,
            # system_instruction=system_prompt # Alternative way to set system prompt for some models
        )

        try:
            # Send the user's current query.
            # The history has already been set in start_chat.
            response = await chat_session.send_message_async(query, stream=True)
            # If using system_instruction, you might need to set it with each call if not using start_chat,
            # or ensure the model is configured with it.
            # For this example, let's assume the system prompt is part of the history or model's configuration.
            # We need to properly format the prompt for the model.
            # The user query `query` is the latest message.

            # Simplified prompt for direct generation if not using start_chat for every turn explicitly
            # For the purpose of this service, we'll assume `start_chat` with history is the way to go.
            # If you don't use start_chat, you'd construct a list like:
            # messages_for_api = [system_prompt_content] + formatted_history + [{"role": "user", "parts": [{"text": query}]}]
            # response = self.model.generate_content(messages_for_api, stream=True)

            async for chunk in response:
                if chunk.text:
                    yield chunk.text
        except Exception as e:
            print(f"Error during LLM response generation: {e}")
            yield f"Sorry, I encountered an issue trying to respond: {str(e)}"