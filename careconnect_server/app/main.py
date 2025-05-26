# careconnect_server/app/main.py
from fastapi import FastAPI, WebSocket, WebSocketDisconnect
from fastapi.middleware.cors import CORSMiddleware
import json
from app.services.llm_service import LLMService
from app.models.chat_models import UserInput, ClientResponse, ChatMessage # Ensure this import is correct

app = FastAPI(title="CareConnect WebSocket Server")

origins = ["*"] # Allow all for development. Restrict in production.

app.add_middleware(
    CORSMiddleware,
    allow_origins=origins,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Initialize LLMService. Handle potential errors during startup.
try:
    llm_service = LLMService()
except Exception as e:
    print(f"CRITICAL: Failed to initialize LLMService at startup: {e}")
    # Depending on your strategy, you might exit or run in a degraded mode.
    # For now, we'll let it run, but WebSocket connections might fail if llm_service is None.
    llm_service = None 

@app.websocket("/ws/v1/careconnect_chat")
async def websocket_chat_endpoint(websocket: WebSocket):
    await websocket.accept()
    print("Client connected to WebSocket.")
    
    if llm_service is None:
        print("LLMService not available. Closing WebSocket connection.")
        error_msg = ClientResponse(type="error", data="Chat service is currently unavailable. Please try again later.")
        await websocket.send_text(error_msg.model_dump_json())
        await websocket.close(code=1011) # Internal error
        return

    try:
        while True:
            data_str = await websocket.receive_text()
            try:
                data_json = json.loads(data_str)
                # Validate incoming data with Pydantic model
                user_input = UserInput(**data_json) 
                
                print(f"Received query: {user_input.query}")
                print(f"Received history length: {len(user_input.history)}")

                full_response_streamed = False
                async for chunk_text in llm_service.generate_response(user_input.query, user_input.history):
                    response_chunk = ClientResponse(type="content", data=chunk_text)
                    await websocket.send_text(response_chunk.model_dump_json())
                    full_response_streamed = True
                
                # If the stream was empty (e.g. LLM filtered output or error during stream)
                if not full_response_streamed:
                    print("LLM stream was empty or only yielded empty chunks.")
                    # Optionally send an info message if nothing was streamed.
                    # info_msg = ClientResponse(type="info", data="No specific response generated for the last input.")
                    # await websocket.send_text(info_msg.model_dump_json())

            except json.JSONDecodeError:
                error_msg = ClientResponse(type="error", data="Invalid JSON format received.")
                await websocket.send_text(error_msg.model_dump_json())
                print("Invalid JSON received.")
            except Exception as e: # Catch other errors during message processing
                print(f"Error processing message: {e}")
                error_msg = ClientResponse(type="error", data=f"An error occurred while processing your request: {str(e)}")
                await websocket.send_text(error_msg.model_dump_json())

    except WebSocketDisconnect:
        print(f"Client disconnected: {websocket.client_state}")
    except Exception as e:
        print(f"An unexpected WebSocket error occurred: {e}")
        # Try to inform the client if the socket is still somewhat open
        try:
            if websocket.client_state.name == 'CONNECTED':
                error_msg = ClientResponse(type="error", data=f"A server-side WebSocket error occurred: {str(e)}")
                await websocket.send_text(error_msg.model_dump_json())
        except Exception as send_e:
            print(f"Could not send error to client after initial WebSocket error: {send_e}")
    finally:
        print("Closing WebSocket connection.")
        # Ensure graceful closure
        if websocket.client_state.name == 'CONNECTED':
             await websocket.close()


@app.get("/")
async def read_root():
    return {"message": "CareConnect server is running. Connect to /ws/v1/careconnect_chat for chat."}