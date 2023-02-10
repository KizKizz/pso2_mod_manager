# PSO2NGS Mod Manager 
 An app to manage and apply mod files to Phantasy Star Online 2 New Genesis  
 
![Screenshot 2023-02-09 202346](https://user-images.githubusercontent.com/101075148/218000260-af778197-8d57-4b68-ae6b-08043cc995cc.png)

# Download

[Release page](https://github.com/KizKizz/pso2_mod_manager/releases)  
Check back for latest releases

# Features

- Organize, keep track of available and applied mods
- Add, remove single/multiple items or mods
- Apply entire mod, or single .ice file
- Mod sets, save mods into sets to apply later 
- Backup originals from the game, restore when unapplying mods
- Preview mods by hovering mouse cursor on them, and right click to zoom on an image (if there are images [.jpg, .png] or videos [.mp4, .webm] included inside the mod)
- Search (literally any keyword, even .ice file), favorites list

and more..

# Usage
**Note:**  
- Restore the game files to their originals before using the app
- App's settings (light\dark mode, pso2_bin path, ect) are stored in:  
  ```C:\Users\YourUserName\AppData\Roaming\PSO2NGS Mod Manager\shared_preferences.json```
- Mod files settings are stored in:  
  ```...\PSO2 Mod Manager\PSO2ModManSettings.json```
- If the app started as a blank white screen, resizing it would fix this issue.
- If the app wont start or crashing on start:

  ```Right click on PSO2NGSModManager.exe > Properties > Compatibility tab > Check the box under Compatibility mode > Apply```
  
  ![Screenshot 2022-10-03 195833-side](https://user-images.githubusercontent.com/101075148/193726661-01acdf9c-c698-490e-af08-e7445adde2cb.png)


**First time setup:**

- Locate pso2_bin folder

   ![Screenshot 2022-06-26 143014](https://user-images.githubusercontent.com/101075148/175836232-f62b8484-c4a5-4815-a7b0-66d54b8f6332.png)
   ![Screenshot 2022-06-26 143139-crop](https://user-images.githubusercontent.com/101075148/175836300-1d3462b6-57e1-4418-b2ab-12bf66f7bcd8.png)

- Click to auto download checksum, or hold to manually select 

   ![Screenshot 2022-06-26 143206-crop](https://user-images.githubusercontent.com/101075148/175836423-3b2b0ed6-b6b1-401c-9b71-2c7cb911db82.png)
 
**Adding item's Category:**

Only if you want to add more, the app already creates default categories after the first run.

   &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; ![Screenshot 2022-10-03 210742](https://user-images.githubusercontent.com/101075148/193732721-3aebd1f3-ae9f-4059-8f1d-87d701671ff3.png)
 
   &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;![Screenshot 2022-10-03 210837](https://user-images.githubusercontent.com/101075148/193732744-d6f284e9-8b57-4a60-b181-d0df4ef11619.png)

**Adding item(s):**

Mods can also be added by copying your mod folders into each category folder in ```...\PSO2 Mod Manager\Mods``` then refresh or restart the app

[add mods.webm](https://user-images.githubusercontent.com/101075148/213642075-ccc1af8f-70e7-4e11-9cd3-73254db96259.webm)

**Note:** Supporting .zip files, folders, .ice files, drag and drop to add

**Applying - unapplying mod(s):**

- Applying mod(s) to the game

   ![Screenshot 2022-10-03 215212](https://user-images.githubusercontent.com/101075148/193738228-041f0d31-a369-446e-b32f-422d4b1cd643.png)

- Unapplying

   ![Screenshot 2022-10-03 215149](https://user-images.githubusercontent.com/101075148/193738266-d3ccbabf-452a-4a1e-8e5d-2c9bee0e7846.png)
   
**Mod Sets:**

[modset.webm](https://user-images.githubusercontent.com/101075148/214807248-aebc667d-0d5b-41a8-a28f-acd7cc74d8df.webm)   
   
**Preview:**

Add images and videos when adding your mods to preview them (or just drop images and videos inside their folders).

![Screenshot 2022-10-03 221410](https://user-images.githubusercontent.com/101075148/193740743-db6a6ad2-c84f-48b7-b360-9b73aa0906ee.png)
![Screenshot 2022-10-03 221456](https://user-images.githubusercontent.com/101075148/193740766-179e4e6d-f971-4637-adff-1e7f81ec1e51.png)


# Known Issues
Drag & drop won't work if app is running with Administrator

# Plans
More improvements  
Maybe a Linux version for steam deck

# Built With

Flutter and various libraries from [pub.dev](https://pub.dev/packages)

[Zamboni](https://github.com/Shadowth117/Zamboni) and [DDStronk](https://github.com/scorpdx/ddstronk)

Found a bug? [Leave a message here](https://github.com/KizKizz/pso2_mod_manager/issues)

Made by キス★ (KizKizz)  
<sup>I'm not taking any responsibility if your game files messed up</sup>
