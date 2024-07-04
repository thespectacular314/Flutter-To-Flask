# Flutter To Flask
This is a simple flutter app for image classification using ResNet50. The user can upload the image, the image will be sent to the server and processed over there and send back the results to the Flutter app where it will be displayed with the prediction result and how confident it is (confidence score).
# How does it work?
- I made a Flask application of the same, you can check it out in this link [Flask App](https://github.com/thespectacular314/Image-classification-using-ResNet50-with-Flask-and-Docker). I hosted this Flask app in Google cloud run through the docker image that I created and use this as my server for the flutter app.

# Demo
https://github.com/thespectacular314/Flutter-To-Flask/assets/155757417/bc535032-bb65-40cd-a76c-76c08d447243


# How to run?
- Git clone the repo.
  ```
  git clone https://github.com/thespectacular314/Flutter-To-Flask
  cd Flutter-To-Flask
  ```
- Install the required setup for running Flutter apps.
- Install the dependencies from `pubspec.yaml`
- Run the `main.dart` file found in `lib` folder.
  
  ```
  flutter run
  ```



<h2>Access my Flask App from here <a href="https://img-classification-using-flask-lgcs2dkt6a-uc.a.run.app/">Image Classification</a></h2>
