## User guide

The RL branch of this repository contains the reinforcement learning algorithm as well as the database used to build the biofeedback information. 

To start using the system, you must first run the 'eyetracker' algorithm to verify the pupil segmentation. If the cameras/HMD are placed correctly on the volunteer, you will be able to calculate pupil size and discriminate it from the rest of the eye features, such as ruff, limbus, and eye-browns.

Note: You must input your camera's specs/intrinsics/extrinsics to a matfile according to the 'eyetracker' and 'biofeedback' algorithms comments instructions.

The GUI interface will allow the user to make fine adjustments to pupil segmentation through different push buttons. Specifically, it has three settings that can be used by the user to correct the algorithm if it exceeds the pupillary threshold or to correct the magnitude of pixel transformation in the image (when necessary).

This algorithm was built to display the eye cameras with "magenta/green" color channels, which represents a high-contrast option that may help users with different types of problems affecting their color vision (R2012a, The Mathworks Inc).

After confirming that the pupil is well segmented, the user must run the 'biofeedback' algorithm. This algorithm will open a GUI that will provide the following options: 

(1) Baseline, (2) Scan session, and (3) Biofeedback.

The (1) Baseline comprises the procedure that estimates the pupil diameter baseline for each individual and makes it possible to estimate the pupil gain metric in subsequent tests. The algorithm ends the procedure automatically, according to the user's pre-established time limit. At the end of the baseline, the user must manually filter the artifacts/eye blinks. This procedure is necessary to calculate the pupil gain and run the Scan session or the Biofeedback session.

The (2) Scan session option is responsible for recording the pupil diameter in a practice session so that the biofeedback threshold can be estimated with the Reinforcement Learning algorithm Rltst.m. 

The (3) Biofeedback option is responsible for establishing the biofeedback protocol and providing auditory stimuli taking into account the biofeedback threshold established by the machine learning algorithm. The respective session will calculate the pupillary gain in real-time and provide an auditory stimulus (the sound of a putting shot) as the participant reaches the biofeedback threshold after the 5th putt.
