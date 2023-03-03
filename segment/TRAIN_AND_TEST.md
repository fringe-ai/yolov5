# Training Steps
## Activate the python virtual environments
The following command assumes that the virtual python environment is installed in `~/virtual_env`.
```bash
source ~/virtual_env/bin/activate
```

## Install the YOLO related libraries
```bash
git clone https://github.com/lmitechnologies/LMI_AI_Solutions.git && cd LMI_AI_Solutions && git submodule update --init object_detectors/yolov5

pip install -r object_detectors/yolov5/requirements.txt
```

## Activate LMI_AI environment
The following commands assume that the LMI_AI_Solution repo is cloned in `~/LMI_AI_Solutions`. This tutorial assumes that the working directory is your home directionry i.e., `~`.
```bash
source ~/LMI_AI_Solutions/lmi_ai.env
```

## Prepare the datasets
The example dataset can be downloaded using GCP (the link will be provided later):
```
Canadian-SPF_2023-01-19
```

Prepare the datasets by the followings:
- pad images to 1600 x 720
- resize images to 640 x 288
- convert to YOLO annotation format

Assume that the original data is downloaded in `./data/Canadian-SPF_2023-01-19`. After execting the exmaple commands below, it will generate a yolo formatted folder in `./data/resized_640_yolo`.

```bash
python -m label_utils.pad_with_csv --path_imgs ./data/Canadian-SPF_2023-01-19 --path_out ./data/pad_1600x720 --out_imsz 1600,720

python -m label_utils.resize_with_csv --path_imgs ./data/pad_1600x720 --path_out ./data/resized_640x288 --out_imsz 640,288

python -m label_utils.convert_data_to_yolo --path_imgs ./data/resized_640x288 --path_out ./data/resized_640x288_yolo --seg
```

## Create a yaml file indicating the locations of datasets
Note that the order of class names in the yaml file must match with the order of names in the json file. Below is what is in the `./data/resized_640x288_yolo/class_map.json`:
```json
{"knot": 0, "wane": 1}
```

Below is the yaml file and save it as `./config/example.yaml`:
```yaml
path: /home/user/data/resized_640x288_yolo  # dataset root dir
train: images  # train images (relative to 'path') 128 images
val: images  # val images (relative to 'path') 128 images
test:  # test images (optional)

# the order of names must match with the names in class_map.json!
names: 
  0: knot
  1: wane
```

## Download the pre-trained model weights (optional)
The pre-trained yolo models can be found in: https://github.com/ultralytics/yolov5/releases/tag/v7.0. 
The following command shows that 
- download the pre-trained model (yolov5s-seg.pt).
- save it to `./pretrained-models`.

```bash
wget https://github.com/ultralytics/yolov5/releases/download/v7.0/yolov5s-seg.pt -P ./pretrained-models
```

## Train the model
The command below trains the model with the datasets in the yaml file. It has the following arguments:
- img: image size (the largest edge if images are rectangular)
- batch: batch size
- data: the path to the yaml file
- **rect: if the images are rectangular**
- weights: the path to the pre-trained weights file
- project: the output folder
- name: the subfolder to be created inside the output folder
- exist-ok(optional): if it's okay to overwrite the existing output subfolder

```bash
python -m yolov5.segment.train --img 640 --batch 8 --rect --epoch 300 --data ./config/example.yaml --weights ./pretrained-models/yolov5s-seg.pt --project training --name example --exist-ok
```

## Monitor the training progress
While training process is running, open another terminal. Execuate the command below and go to http://localhost:6006 to monitor the training.
```bash
tensorboard --logdir ./training/example
```


# Testing
## Save trained model
After training, the weights are saved in `./training/example/weights/best.pt`. Copy the best.pt to `./trained-inference-models/example`.

```bash
mkdir -p ./trained-inference-models/example
cp ./training/example/weights/best.pt ./trained-inference-models/example
```

## Run inference
The command below generates perdictions using the following arguments:
- source: the path to the test images
- weights: the path to the trained model weights file
- img: a list of image size (height width)
- project: the output folder
- conf-thres(optional): the confidence level, default is 0.25
- name: the subfolder to be created inside the output folder
- save-txt: save the outputs as a txt file

```bash
python -m yolov5.segment.predict --img 256 640 --source data/predict_images --weights trained-inference-models/example/best.pt --project validation --name example --exist-ok --save-txt
```
The output results are saved in `./validation/example`.

# Generate TensorRT Engine
Refer to here: https://github.com/lmitechnologies/yolov5/tree/ais/trt.
