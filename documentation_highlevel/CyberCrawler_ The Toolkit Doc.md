# **CyberCrawler: The Solo Dev Toolkit**

This document outlines a recommended set of tools for a solo developer on a tight budget to create *CyberCrawler*, based on the 2.5D isometric design. The philosophy here is to use powerful, free, and open-source software wherever possible, only suggesting paid tools if they provide a significant, undeniable workflow advantage.

## **1\. Game Engine: The Core**

Your game engine is the most important choice you'll make. It's the workbench where you'll assemble every part of your game.

#### Primary Recommendation: Godot Engine

* **Cost:** Completely **Free & Open-Source**. No fees, no royalties, no strings attached.  
* **Why it's a great fit:**  
  * **2D/2.5D Powerhouse:** Godot's 2D workflow is considered one of the best available. It handles 2D lighting, tilemaps, and sprites intuitively, which is perfect for both the isometric stealth sections and the grid-based hacking game.  
  * **Easy to Learn:** Its scripting language, GDScript, is very similar to Python. It's clean, easy to read, and designed for making games quickly. This lowers the initial learning curve significantly.  
  * **Lightweight:** The engine itself is a small download and runs well on most hardware.  
  * **Active Community:** While not as large as Unity's, the Godot community is passionate, growing rapidly, and incredibly helpful.

**Verdict:** Start with **Godot**. It aligns perfectly with the project's technical needs and the solo dev philosophy of keeping things streamlined and cost-free.

## **2\. Art & Asset Creation**

You'll need tools for character sprites, environment tiles, UI elements, and visual effects.

#### 2D Art (Sprites, Textures, UI)

* **Adobe Fresco:** I already have Adobe Fresco on my laptop since it is free... I will have to manually create some ideas in here this will probably be where concept art and rough sketches are created
* **Microsoft Paint:** I have Microsoft Paint and access to some AI models to help me create some ideas out and edit the rough ideas into more concrete ideas 

#### 2.5D Isometric Assets

* **Blender (Free):** The ultimate tool for this. You can model simple 3D objects (like buildings, cars, desks), set up an isometric camera, and render them out as 2D sprites. This gives you perfect angles and lighting consistency for free. It has a steep learning curve, but mastering the basics for this workflow is a huge force multiplier.

**Your Art Workflow:**

1. **Concept:** Sketch ideas in Adobe Fresco or Paint.  
2. **Model:** Create simple 3D models of your environment assets in Blender.  
3. **Render:** Render the models from Blender as 2D PNG sprites.  
4. **Animate/Polish:** Import the sprites into Krita or Aseprite (probably Blender) to add details, create character animations, and ensure a consistent pixel art look.

## **3\. Audio: Sound & Music**

Don't neglect audio\! Good sound design is critical for stealth gameplay and setting a cyberpunk mood.

#### Sound Effects (SFX)

* **Audacity (Free):** An essential tool. It's a powerful audio editor you can use to record, cut, mix, and apply effects to any sound.  
* **Freesound.org (Free):** A massive library of user-submitted sounds with various licenses (be sure to check them). Great for finding ambient sounds like rain, city noise, or footsteps.

#### Music

* **LMMS (Free):** A full-featured, open-source Digital Audio Workstation (DAW). If you have any musical inclination, you can create complex, multi-layered tracks here.  
* **Bosca Ceoil (Free):** An incredibly simple and fun music creation tool. It's very limited but fantastic for creating chiptune or simple looped tracks without getting bogged down.  
* **Royalty-Free Libraries:** For a solo dev, using high-quality royalty-free music is often the most efficient route. Check out the **YouTube Audio Library**, **Pixabay Music**, and **Incompetech**.

## **4\. Organization & Version Control**

As a solo dev, you are your own project manager. Staying organized is not optional.

* **Project Management: Trello (Free):** The perfect tool for managing your roadmap. Create a board with columns like "Backlog," "To Do," "In Progress (Prototype)," and "Done." Turn each feature from the GDD into a card and move it across the board. This visual progress is incredibly motivating.  
* **Version Control: Git \+ GitHub (Free):** This is non-negotiable. Version control is a system that saves snapshots of your project. If you break everything, you can rewind time to a working version.  
  * **Git** is the software you run on your computer.  
  * **GitHub** is a website where you can store a remote backup of your project for free.  
  * **Commit early, commit often.** It will save you from disaster.