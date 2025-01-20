# Testing the Effects of Background Music and Tempo on American Sign Language Gesture Retention for Hearing Individuals

Welcome to our project of the course Multisensory Interactive Systems by Professor Luca Turchet in Univerisity of Trento in the academic year 2024-2025.

This project explores the use of a glove equipped with flex sensors on each finger to teach the American Sign Language (ASL) alphabet through an interactive memory game.


## Documentation and Project Report

> Please, find documentations through following links 

Project Report: [here](https://drive.google.com/file/d/1FhDKdjihH3C6WtuiAkJMdMqAWktrXtSK/view?usp=sharing)

Project demo video: [here](https://drive.google.com/drive/folders/1hFU4EqIl6tcsIl3rfCUv7YJyBS03Tobo?usp=sharing)

All the documentation related to the project can be found here: [Google Drive](https://drive.google.com/drive/folders/1SSq1FzPsZK90wIQJlsbJ2PDyiV-El-Cn?usp=sharing)
    
## 🔧Tools used in the project
    - Arduino micro-contoller
    - Flex sensors - 5 pieces
    - Vibration motor - 1 piece
    - Resistor of 10Ω - 5 pieces
    - Breadboard
    - Jumper wires
    - A plain glove

## 💻Software tools used in the project
    - Arduino 2.3.3 
    - Processing 4.3
    - Pure Data 0.54.1

## ⚙️ How to make it work?

**There are 3 component directories of the system**
```
    - ArduinoSignLanguageGame
    - ProcessingSingLanguageGame
    - PureDataSignLanguageGame
```

**Follow this order to make the system work**

    1. Open and upload the /ArduinoSignLanguageGame/ArduinoSignLanguageGame.ino 
    sketch to the connected Arduino micro-controller

    2. Open the /PureDataSignLanguageGame/MAIN.pd

    3. Open /ProcessingSignLanguageGame/ProcessingSignLanguageGame.pde and press button 
    play to start

> To start the system, each of tehe files mentioned above must be opened at the same time.
> From this on, user only needs to instruction from the user interface


## 🕹️How to play the game 🖐️
The user engages in the memorization game designed to teach sign language letters through corresponding hand gestures. To complete the game, the user goes through the start screen, calibration screen, memorization game screen, and the final screen. The screens are all explained in more detail. 

**Start**

The user begins by putting on the glove, which is equipped with flex sensors to detect hand gestures. To start the game, the user presses the  Enter button.

**Calibration**

Before the game starts, the glove needs to be calibrated for each individual to account for variations in hand size, finger length variations, and finger bending abilities. During calibration, the user follows on-screen instructions to calibrate the glove. 

- Stretch your hand and hold it open for 3 seconds; 
- Make a fist with your hand and hold it for 3 seconds;

**Memory-Learn game**

Once the calibration is complete, the user can start the memorization game by pressing the Enter button again. The game consists of three levels, each featuring the same six letters. The user learns the letters by replicating the hand gesture, by mimicking the purple highlighted gesture on the interface. The user must hold the correct gesture for three seconds. This process continues until all six letters are learned at each level. The order of when which letter is highlighted differs per level to avoid the user relying on the sequence rather than truly learning each gesture. After completing the level, the user has five seconds to prepare for the next level. This brief pause allows the user to reset and get ready for the next level.

**Finish**

The finish screen contains the time the user took to complete each level. After completing all levels, the user is tested on their short-term retention of the letters by the researcher. The user needs to mention the letter out loud and perform the corresponding gesture
