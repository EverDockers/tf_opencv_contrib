# tf_opencv_contrib

## Component

* Tensorflow 1.3.0
  * TensorBoard:6006
* Opencv 3.3.0
* Python 3.5
* Jupyter:8888

## Usage

```bash
docker run -it --name ml -v <local volume>:/notebooks -p 8888:8888 -p 6006:6006 baikangwang/tf_opencv_contrib /bin/bash
```
