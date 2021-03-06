# minst-flutter-app

A flutter app that lets you experiment with a MNIST (28x28) tf-keras model in real-time!

Works over websockets, using the amazing [Starlette](https://www.starlette.io/) web framework.

![out](https://user-images.githubusercontent.com/19492893/68985653-144ff380-083e-11ea-9cee-8c260e558fc9.gif)


## How to use this code?
1. Save model using `model.save(mnist_model.h5)`
2. Download model file to `client/server/mnist_model.h5`.
3. Deploy python server by running the following commands in the `server/` directory (on a publically accessible server) -
```
pip install -e .
uvicorn --port <server port> server:app
```
3. Change [`serverUrl`](https://github.com/scientifichackers/minst-flutter-app/blob/c7470999a0608706ca24daae1207c1ceac5af6a2/client/lib/src/constants.dart#L25) accordingly.
4. In the `client/` directory, `flutter run`.

## Thanks

Thanks to [this](https://github.com/sergiofraile/when_flutter_meets_tensorflow_part_4) medium article for the hand drawing canvas code.
