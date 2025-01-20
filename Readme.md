# Multisensory Finger Spelling project

Welcome to our project of the course Multisensory Interactive Systems by Professor Luca Turchet in Univerisity of Trento.

This project explores the use of a glove equipped with flex sensors on each finger to teach the American Sign Language (ASL) alphabet through an interactive memory game.


## Documentation and Project Report

> Please, find documentations through following links 

Project Report: [here](https://docs.google.com/document/d/1gL_c4BlxqP8ISIDm0Py-T-ePMDPG7qw1Fc6F-MYCPrk/edit?usp=sharing)

Project demo video: [here](https://drive.google.com/drive/folders/1hFU4EqIl6tcsIl3rfCUv7YJyBS03Tobo?usp=sharing)

All the documentation related to the project here [GoogleDrive](https://drive.google.com/drive/folders/1SSq1FzPsZK90wIQJlsbJ2PDyiV-El-Cn?usp=drive_link)
    
## 🔧Tools used in the project
    - Arduino
    - Flex sensors - 5 pieces
    - Vibration motor - 1 piece
    - Resistor of 10Ω - 5 pieces
    - Breadboard
    - Jumper wires

## 💻Software tools used in the project
    - Arduino
    - Processing
    - Pure Data

## ⚙️ How to make it work?

**There are 3 component directories of the system**
```
    - ArduinoSignLanguageGame
    - ProcessingSingLanguageGame
    - PureDataSignLanguageGame
```

**Follow this order to make the system work**

    1. Open and upload the ArduinoSignLanguageGame/ArduinoSignLanguageGame.ino 
    sketch to connected Arduino

    2. Open the PureDataSignLanguageGame/MAIN.pd

    3. Open ProcessingSingLanguageGame/ProcessingSingLanguageGame.pde and press button 
    play to start

> To start the system, each of tehe files mentioned above must be opened at the same time.

> To start the system, each of tehe files mentioned above must be opened at the same time.


## 🕹️How to play the game
The user plays a memory game by memorizing/learning the sign language letters with their corresponding hand gestures Before the game starts, the user wears the glove and the glove is calibrated for the user to be personalized to take into account the hand size and finger length variations. 


- During calibration, the user needs to follow the instructions that are displayed on the user interface, where the user needs to stretch his hand and then make a fist with his hand for 3 seconds. 
After calibration, the game starts by the user presses enter, and the user plays the game of three levels, each has the same 6 letters, in which the user needs to learn the letters by replicating the hand gesture by himself/herself,  by following the letters starting from the highlighted one. The letters will be highlighted one after each when the user makes the correct gesture for 3 seconds. Between levels, the user will be given 5 seconds to prepare for the next level. 

- After finishing the levels of the game, the user will be tested on how many of the letters are retained from his/her memory. For example, the following image depicts the example letters with their gestures that will be shown in the user interface.
