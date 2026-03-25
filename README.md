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
