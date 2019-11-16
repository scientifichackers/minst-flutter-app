from starlette.applications import Starlette
from starlette.websockets import WebSocket
from keras.models import load_model
from pathlib import Path
import numpy as np


model = load_model(Path(__file__).parent / 'mnist_model.h5')
app = Starlette()


@app.websocket_route('/')
async def do_infer(ws: WebSocket):
    await ws.accept()
    while True:
        img_bytes = await ws.receive_bytes()
        img = bytes_to_img(img_bytes)
        result: np.ndarray = model.predict(img)[0]
        await ws.send_json(result.tolist())


def bytes_to_img(img: bytes) -> np.ndarray:
    arr = np.frombuffer(img, dtype=np.uint8)
    arr = arr.reshape(1, 28, 28, 1)
    return arr
