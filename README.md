# PSO2NGS Mod Manager 
 An app to manage and apply mod files to Phantasy Star Online 2 New Genesis  
 
 ![Screenshot 2022-07-05 000852](https://user-images.githubusercontent.com/101075148/177270347-927d60f6-2f05-43e8-90a3-ad78074107be.png)

# Download

[Release page](https://github.com/KizKizz/pso2_mod_manager/releases)  
Check back for latest releases

# Features

- Organize, keep track of available and applied mods
- Add, remove single/multiple items or mods
- Apply entire mod, or single .ice file
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

**First time setup:**

- Locate pso2_bin folder

   ![Screenshot 2022-06-26 143014](https://user-images.githubusercontent.com/101075148/175836232-f62b8484-c4a5-4815-a7b0-66d54b8f6332.png)
   ![Screenshot 2022-06-26 143139-crop](https://user-images.githubusercontent.com/101075148/175836300-1d3462b6-57e1-4418-b2ab-12bf66f7bcd8.png)

- Locate checksum file

   ![Screenshot 2022-06-26 143206-crop](https://user-images.githubusercontent.com/101075148/175836423-3b2b0ed6-b6b1-401c-9b71-2c7cb911db82.png)
 
**Adding item's Category:**

   &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;![Screenshot 2022-06-26 143206-crop](https://user-images.githubusercontent.com/101075148/175836771-62ce70ce-c8fa-423a-ae97-77fe00c178f0.png)  
   &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;![Screenshot 2022-06-26 143310-crop](https://user-images.githubusercontent.com/101075148/175836775-7cb5bcda-d86b-4be9-8b80-a3931487cc8a.png)

**Adding item(s):**  
Mods can also be added by copying your mod folders into each category folder in ```...\PSO2 Mod Manager\Mods``` then restart the app

**Note:** Only extracted files and folders, open zipped files then drag and drop to add

- Single item

   ![Screenshot 2022-06-26 143206-crop](https://user-images.githubusercontent.com/101075148/175837010-bdbfad68-1b7a-40bb-9c0b-ffa71f456325.png)  
   ![Screenshot 2022-06-26 143344-crop](https://user-images.githubusercontent.com/101075148/175837655-350eef0b-67d3-4ade-b7ac-38a091d2f309.png)
   ![Screenshot 2022-06-26 144028-crop](https://user-images.githubusercontent.com/101075148/175837024-1ac89fc3-6f51-400f-8e90-76c1db14fe28.png)

- Multiple items

   ![Screenshot 2022-06-26 143357-crop](https://user-images.githubusercontent.com/101075148/175837773-3a280f49-cbb1-4a01-98b0-a42731eecfc7.png)
   ![Screenshot 2022-06-26 144507-crop](https://user-images.githubusercontent.com/101075148/175837827-831291c7-2b26-4276-8a4d-bc1b26e30745.png)

**Adding Mod(s) to existing item:**

**Note:** Only extracted files and folders, open zipped files then drag and drop to add

   &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;![Screenshot 2022-06-26 144710-crop](https://user-images.githubusercontent.com/101075148/175837076-44cc3b2b-929c-4501-b3c4-14730cba7c09.png)  
   &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;![Screenshot 2022-06-26 144826-crop](https://user-images.githubusercontent.com/101075148/175837078-8d0583d0-bc64-46ee-a103-ad4469f36c60.png)

**Applying - unapplying mod(s):**

- Applying mod(s) to the game

   ![Screenshot 2022-06-26 150449-crop](https://user-images.githubusercontent.com/101075148/175837118-23c1a8f3-28bd-497e-868c-b52397b58b81.png)

- Unapplying

   ![Screenshot 2022-06-26 15063277-crop](https://user-images.githubusercontent.com/101075148/175837209-ec4156b6-4217-4c00-8948-b34e9ba51635.png)  
   ![Screenshot 2022-06-26 150632-crop](https://user-images.githubusercontent.com/101075148/175837210-387cfbb5-48e0-4497-89b6-e63c628a451c.png)

# Known Issues
Drag & drop won't work if app is running with Administrator

# Plans
More improvements  
Maybe a Linux version for steam deck

# Built With

Flutter and various libraries from [pub.dev](https://pub.dev/packages)

Found a bug? [Leave a message here](https://github.com/KizKizz/pso2_mod_manager/issues)

Made by キス★ (KizKizz)  
<sup>I'm not taking any responsibility if your game files messed up</sup>
