source /repos/LMI_AI_Solutions/lmi_ai.env

im_w=640
im_h=256

python3 -m yolov5.export --weights /app/trained-inference-models/2022-12-16/best.pt \
    --imgsz $im_h $im_w  --include engine --half --device 0

python3 -m yolov5.trt.infer_trt --engine /app/trained-inference-models/2022-12-16/best.engine \
    --imsz $im_h $im_w --path_imgs /app/images --path_out /app/outputs
