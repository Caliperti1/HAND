# HAND
Human Augmentation w/ Neural Data (EMG ML Pipeline)

This repository is an end-to-end machine learning pipeline for EMG gesture recognition. Currently uses Thalmic Labs myo armband to collect data, MATLAB to proccess data amd train model, and a 5 servo robotic hand controlled by an Arduino Uno as the end effector. With ~5 minutes of data collection this pipeline can train a 97%+ accurate gesture classifier from scratch and deploy it in real time to a prosthetic limb. This program was originally designed to enable EMG research in our SyNAPCE Lab and to provide a practical example of applied machine learning to computational analysis students. 

## Acknowledgements 

Shoutout to Mark Toma, his Myo Mex repo (https://github.com/mark-toma/MyoMex) has enabled thousands of biomedical engineers to leverage the Thalmic Labs Myo arm band for their projects! 

## Repo Contents 

**configs.m** - *Only file you need to edit!* configs contains all necessary parameters to run HAND and adjust how data is collected, proccessed, and what gestures are identified. Futre version will allow for greater customization of program.

**ModelTrainMain.m** - Main loop to collect data and train models. Running this script will prompt a user thorugh a full data collection session, save trainign data, train multiple classifiers and select the most accurate one to be deployed later. 

  **EstablishHardwareConnection.m** - Established connection to Thalmic Labs Myo armband using Myomex. Troublesshoots possible reasons for failed connection.

  **TrainDataCollect.m** - called within ModelTrainMain.m - executes a data ollection session using Thalmic Labs arm band and organizes data into research friendly     format. Generates plot of raw EMG ttrace and radar plot corresponding to arm location for each trial collected.

  **Session2Obs.m** - takes entire session of data and reformats it array of observations by windowing data according to parameters established in configs. Uses       ReformatToObservation function.

  **DimensionalityReductionVisualiztion.m** - Generates 2D representations of data useing TSNE and PCA. (mouthfull of a function name and takes a while to run)

  **PreProccess.m** - function to preproccess single observation so same fucntion can be used for training and online use. Given the robustness of the Thalmic Labs sensor, this function currently only rectifies data (since we are using only time domain features)

  **FeatureExtract.m** - Able to extract time domain and frequency domain features. I found that for basic gesture recognition the added value of the frequency domain features did not justify the added latency when deployed online.

  **SVMTrainer.m** - trains, finetunes, and evaluates a SVM
  **DecissionTreeTrainer.m** - trains, finetunes, and evaluates a decission tree
  **KNNTrainer.m** - trains, finetunes, and evaluates a KNN

**HandControlMain.m** - Online deployment of model trained in ModelTrainMain.m. Uses serial connection to Arduino Uno running sketch in Rock-Paper-Sciossors which is connected to simple robotic limb controlled with 5 servo motors.

**ROCK_PAPER_SCISSORS.ino** - Arduino coded with preprogrammed hand gesture functions to actuate servos on prosethics hand. Configured for serial communication with **HandControlMain.m**

## Example Data
Example datasets are provided to demonstrate the structure that data files are automatically saved in.

## Getting Started

Follow Mark's great tutorial on getting started with the Thalmic Labs arm band - https://github.com/mark-toma/MyoMex

## Updates in progress

1) Rewrite in python. Starting with building more complex models in TensorFlow and Keras using data collected through MATLAB, will eventually rewrite entire program.

2) Building new ersion of TrainDataCollect to enable use of Myoware 2.0 sensors as other option

3) Adding ability to choose addiitonal models within MATLAB version. Super easy fix but wanted to get a version out there as soon as it was working!

Update config.m to set file paths, choose gestures, and adjust parameters for model training sessions.
