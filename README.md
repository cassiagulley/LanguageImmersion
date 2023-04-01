LanguageImmersion
=================

**Final year thesis**
---------------------

My final year engineering honours thesis at University of Queensland aimed at discovering the usefulness of integrating social and mobile methodologies with augmented reality to facilitate effective and engaging language learning environments. To aid in this research, a proof of concept AR application was built natively on iOS using Swift, with the use of ARKit, RealityKit, SwiftUI and Apple's Multipeer Connectivity.

[Click here to read my thesis!](https://github.com/cassiagulley/LanguageImmersion/blob/main/ThesisDocument.pdf)

**Dependencies**
----------------

This project has the following dependencies:

-   Xcode 11.0 or higher
-   Swift 5.0 or higher
-   ARKit 4.0 or higher
-   RealityKit 2.0 or higher
-   SwiftUI 2.0 or higher
-   Apple's Multipeer Connectivity framework
-   [Multipeer Session](https://github.com/RyanKopinskyLLC/multipeer-session)

**Requirements**
----------------

To run the app, you will need to install the above dependencies, as well as any additional dependencies required by your local environment. You can install the dependencies by following these steps:

1.  Install Xcode from the App Store.
2.  Clone this repository to your local machine.
3.  Open the project in Xcode.
4.  Build and run the app on a physical device with ARKit support.

**How to Set Up/Run:**
----------------------

-   Select the device you want to run this on (currently only supported for iPhone and iPad)
<img width="1310" alt="SelectDevice" src="https://user-images.githubusercontent.com/91455929/229264479-b1872708-218e-4dae-9ba6-af175961c39c.png">

-   Select "Run"

    -   If the following error occurs:
    <img width="598" alt="BuildError" src="https://user-images.githubusercontent.com/91455929/229264489-71725b76-bfad-4514-8da8-8603336060a1.png">

    -   Make sure you trust the developer: go to your device Settings -> General -> Device Management and "trust" yourself as developer.

How to use
----------

-   If you have multiple devices, make sure you get a shared world understanding at the beginning by mapping the world with all the devices next to each other/seeing the same view
-   Then create notes by selecting the "add note button", adding the text, and selecting "done"
-   The sticky note will appear in the center of your screen and you can move it around as you see fit
-   **Avoid interrupting the AR experience.**  If the user transitions to another fullscreen UI in your app, the AR view might not be an expected state when coming back.

**Limitations**
---------------

-   This app is currently in its minimum viable product (MVP) stage and was not designed to be used as anything other than a prototype tool to facilitate research and provide a proof of concept.
-   The app is based on ARKit's loading/tracking technology which is not optimal/accurate for shared worlds beyond experimentation.
-   At present, users are unable to edit text or add anything beyond plain text notes.
