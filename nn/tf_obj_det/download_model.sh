#!/bin/sh

set -e

mkdir -p graph_def

MODELS="ssd_mobilenet_v1_coco_11_06_2017 ssd_inception_v2_coco_11_06_2017 rfcn_resnet101_coco_11_06_2017 faster_rcnn_resnet101_coco_11_06_2017 faster_rcnn_inception_resnet_v2_atrous_coco_11_06_2017"
for model in ${MODELS}
do
    echo ${model}
    curl -OL http://download.tensorflow.org/models/object_detection/${model}.tar.gz
    mkdir -p ${model}
    tar -xzf ${model}.tar.gz ${model}/frozen_inference_graph.pb
    mv ${model} ./graph_def
done

ln -sf `pwd`/graph_def/faster_rcnn_resnet101_coco_11_06_2017/frozen_inference_graph.pb `pwd`/graph_def/frozen_inference_graph.pb
