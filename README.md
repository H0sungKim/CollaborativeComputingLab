# CollaborativeComputingLab

**A Prototype of Live Mobile Learning System (using RTMP)**

The project was developed as part of research activities at the **Collaborative Computing Lab (CCL), Hongik University**.

Our goal is to provide a mobile learning experience comparable to real-world classroom lectures.

## Key Features
* Real-time audio / video lecture streaming
* Multi-room lecture support
* Live chat for real-time interaction between instructors and students
* Annotatable PDF slides and a whiteboard
* User-Adjustable UI that allows instructors to dynamically control the screen ratio between slides and the whiteboard

## Reports

[**Live Mobile Learning System with User-Adjustable UI**](/Docs/Live_Mobile_Learning_System_with_User-Adjustable_UI.pdf)

The following technical reports document the iterative development of this project. The final report consolidates all previous work and represents the complete system design and evaluation.

| Date | Source | Report |
|---|---|---|
| 2025.05.29 | [GitHub](https://github.com/H0sungKim/CollaborativeComputingLab/tree/f59d35a24dd0525328f50ce3d041e51164e1bb9a) | [A Prototype of Live Mobile Learning System Using RTMP and STOMP](/Docs/20250529_A_Prototype_of_Live_Mobile_Learning_System_Using_RTMP_and_STOMP/A_Prototype_of_Live_Mobile_Learning_System_Using_RTMP_and_STOMP.pdf) |
| 2025.07.16 | [GitHub](https://github.com/H0sungKim/CollaborativeComputingLab/tree/7fc97a588eb7dd9589e0b3206bcd89593a9c9e3f) | [Live Mobile Learning System with Multi-Room and Whiteboard Features](/Docs/20250716_Live_Mobile_Learning_System_with_Multi-Room_and_Whiteboard_Features/Live_Mobile_Learning_System_with_Multi-Room_and_Whiteboard_Features.pdf) |
| 2025.08.04 | [GitHub](https://github.com/H0sungKim/CollaborativeComputingLab/tree/af7c845076d5ff97750bf7c9c569e50f7758b930) | [User-Adjustable UI for Concurrent PDF and Whiteboard Display in Live Mobile Learning System](/Docs/20250804_User-Adjustable_UI_for_Concurrent_PDF_and_Whiteboard_Display_in_Live_Mobile_Learning_System/User-Adjustable_UI_for_Concurrent_PDF_and_Whiteboard_Display_in_Live_Mobile_Learning_System.pdf) |
| 2025.08.20 | - | [**Live Mobile Learning System with User-Adjustable UI**](/Docs/20250808_Live_Mobile_Learning_System_with_User-Adjustable_UI/Live_Mobile_Learning_System_with_User-Adjustable_UI.pdf) |

## Tech Stack

### Client
* **Platform**: iPadOS
* **Language**: Swift
* **UI Framework**: UIKit
* **Architecture**: Clean Architecture, MVVM
* **Streaming**: RTMP, HaishinKit.swift
* **Networking**: WebSocket
* **Media Capture & Processing**: ReplayKit, AVFoundation
* **Document & Drawing**: PDFKit, PencilKit

### Server
* **Platform**: macOS
* **Language**: Swift
* **Streaming Server**: NGINX
* **WebSocket Server**: Swift Network Framework
