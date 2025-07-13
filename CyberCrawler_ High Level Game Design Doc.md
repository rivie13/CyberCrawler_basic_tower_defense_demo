# **CyberCrawler: High-Level Game Design & Solo Dev Plan**

## **1\. Core Pillars & Vision**

Before any specific decision, let's define the core experience. Every design choice should serve these pillars.

* **Pillar 1: The Ghost & The Machine:** The player should feel like a powerful, yet vulnerable, entity. A "ghost" during the stealth sections (clever, unseen, precise) and a "machine" during the hacking sections (strategic, commanding, powerful).  
* **Pillar 2: Asymmetrical Warfare:** The player is an underdog fighting a behemoth. This should be reflected in gameplay. You don't win with brute force, but with cunning, sabotage, and exploiting weaknesses. The "Rival Hacker" mechanic is a perfect embodiment of this.  
* **Pillar 3: A Living, Breathing Dystopia:** The world shouldn't just be a backdrop. The story, characters, and environment should tell a story of technological oppression and the human spirit of rebellion.

## **2\. The Big Question: 2D vs. 3D & Art Style**

This is the most critical decision for a solo dev as it dictates the scope of asset creation.

#### Recommendation: Stylized 2.5D (Isometric)

This approach gives you the best of both worlds and is significantly more manageable.

* **Why Isometric?**  
  * **Stealth Gameplay:** A top-down or isometric view (like in *Shadowrun Returns* or *Invisible, Inc.*) is perfect for stealth. It allows the player to clearly see guard patrols, vision cones, and layout, making for tactical and readable gameplay.  
  * **Asset Management:** You primarily create 2D sprites and tilesets, which is much faster than modeling, rigging, and animating full 3D characters and environments. You can use 3D-rendered sprites for a high-fidelity look without the full 3D workload.  
  * **Seamless Transition:** The visual perspective of an isometric stealth game can transition beautifully into the "network view" of the tower defense game, which would likely be a 2D grid.

#### Art Style Recommendation: "Hi-Bit" Pixel Art or Vector Noir

* **Hi-Bit Pixel Art:** Think games like *Katana ZERO* or *The Last Night*. It's detailed enough to convey a complex cyberpunk world but still relies on the efficiency of pixel art. It allows for beautiful lighting effects, rain-slicked streets, and neon glows that are essential to the genre.  
* **Vector Noir:** A clean, high-contrast style using shapes and gradients. Think of the art in games like *Inside* or the visual identity of the *Deus Ex: Human Revolution* marketing. This can be incredibly stylish and is very efficient to produce, as you focus on silhouette, color, and light rather than intricate detail.

**AVOID photorealism or complex 3D.** The asset creation pipeline will overwhelm a solo developer. A strong, consistent, and achievable art style is better than an unfinished, inconsistent realistic one.

## **3\. Core Gameplay Loops: A Deeper Dive**

### **A. The Stealth Loop (The "Crawl")**

* **Objective:** Infiltrate a location, avoid or neutralize guards, and reach one or more network terminals.  
* **Core Mechanics:**  
  * **Vision & Sound:** Standard stealth mechanics. Guards have vision cones, and actions create sound that can attract attention.  
  * **Cover System:** Simple, cover-based movement (hiding behind desks, in vents, etc.).  
  * **Gadgets:** EMP grenades to temporarily disable cameras, noise-makers to distract guards, optic camo for short-term invisibility. These are your primary tools.  
  * **Non-Lethal Takedowns:** A high-risk, high-reward option. Getting close enough for a takedown should be a challenge in itself.  
  * **Lethal Takedowns:** A very-high risk, low reward option. When you get caught the guns come out if they have to and you can try to defend yourself with force although this probably will not work (especially early game)… if you start the level guns blazing it can be hard to get through it since you will have a bunch of enemies on you.  
  * **Alert System:** A multi-stage alert system.  
    * **Level 0 (Green):** Normal patrols.  
    * **Level 1 (Yellow):** Guards are suspicious, actively searching.  
    * **Level 2 (Red):** Alarms are triggered, guards actively hunt you, and—most importantly—**the Rival Hacker is alerted before you even start the hack.**

### **B. The Hacking Loop (The "Tower Defense")**

This is your unique selling point. Let's call the Rival Hacker the **"Hunter."**

* **The Map:** A visualized computer network, represented as a grid with nodes, pathways, and a "Core" you must breach.  
* **Player Goal:** Guide your "Data Packet" program from the entry point to the Core by building a path and defending it.  
* **Player Towers (Programs):**  
  * **Scanners:** Reveal hidden enemy programs (ICE).  
  * **Brute-Forcers:** Standard single-target attack towers.  
  * **Firewalls:** Defensive walls that slow or block enemy programs.  
  * **Data Siphons:** "Generator" towers that produce the resources needed to build more programs.  
* **Enemy Defenses (ICE \- Intrusion Countermeasures Electronics):**  
  * **Tracers:** Fast-moving, weak programs that try to locate your entry point and shut you down.  
  * **Sentries:** Standard enemy "creeps" that follow the path to attack your programs.  
  * **Worms:** Heavy, slow-moving enemies that can break through your Firewalls.  
* **The "Hunter" AI (The Rival Hacker):**  
  * **Activation:** The Hunter becomes active if the stealth section ended in a Red Alert, OR if you cause too much "noise" during the hack itself (e.g., deploying too many powerful programs at once, they find your entry point, or placing a tower on a honeypot slot).  
  * **Hunter's Goal:** To destroy your entry point.  
  * **Hunter's Actions:** The Hunter plays on the same map in real-time. They can:  
    * **Deploy "Hounds":** Special enemy units that actively hunt your towers, not just follow a path.  
    * **Place "Kill-Scripts":** Their own version of towers that attack your programs.  
    * **Sever Connections:** Temporarily disable nodes on the grid, forcing you to reroute your path. This creates a dynamic, tense duel instead of a static defense. (I REALLY like this idea)

### **C. The Hub Loop (The "Safehouse")**

* **Location:** A hidden base where your hacker crew resides.  
* **Activities:**  
  * **Mission Select:** Choose your next target from a map of the city.  
  * **Character Interaction:** Talk to your crew to get story exposition, side-quests, and lore.  
  * **Upgrades & Crafting:** Use resources gathered from missions to:  
    * Upgrade your cyberdeck (unlock new tower types, increase starting resources for hacking).  
    * Craft or upgrade your stealth gadgets and weapons.  
    * Improve your personal cybernetics (e.g., move quieter, short-range dash).

## **4\. Story & World-Building**

* **The Faction:** Give your hacker group a name. Something that reflects their ideology. Maybe "The Glitch" or "Mainframe."  
* **The Antagonist:** "TFOS NA" is a good start. Let's lean into the corpo-government angle. It's not an evil empire for its own sake; it provides comfort, security, and entertainment to the masses in exchange for absolute control and data. Its public face is friendly and helpful. Its private face is ruthless.  
* **Themes:**  
  * Control vs. Freedom.  
  * What is the cost of security?  
  * Humanity in a world of chrome and code.  
* **Narrative Structure:** An episodic structure would be perfect for a solo dev. Focus on developing 3-4 core story missions that form a complete arc, rather than a sprawling 40-hour epic.

## **5\. The Solo Dev Strategic Roadmap**

This is the most important part. Do not try to build the whole game at once.

**Motto: Prototype the Fun, Build the Frame Later.**

* **Phase 1: The Core Tower Defense Prototype (1-2 weeks)**  
  * **Goal:** Create the most basic version of the hacking game.  
  * **Features:** A single grid map, one type of player tower, one type of enemy creep. Can the player place a tower? Does the enemy move from A to B? Does the tower shoot it?  
  * **NO FANCY ART.** Use colored squares and circles. The goal is to see if the basic TD concept is fun.  
* **Phase 2: The "Hunter" Prototype (1 week)**  
  * **Goal:** Add the Rival Hacker to the prototype.  
  * **Features:** Create a simple AI that can place its own "red squares" (Hunter towers) on the grid that shoot your "blue squares" (Player towers).  
  * **Question to Answer:** Does this add exciting tension, or is it just frustrating and chaotic? Tweak it until it feels like a fair, engaging challenge.  
* **Phase 3: The Stealth Prototype (1-2 weeks)**  
  * **Goal:** In a *separate project*, create the core stealth loop.  
  * **Features:** A character that can move around. A single guard with a visible vision cone that walks a set path. A box to hide behind.  
  * **Question to Answer:** Does the movement feel good? Is the stealth readable and fair?  
* **Phase 4: The Connection (1 week)**  
  * **Goal:** Combine the two prototypes.  
  * **Features:** Make a simple level with the stealth character. When the character interacts with a "terminal" object, it launches the Tower Defense prototype.  
  * This is your **Vertical Slice**. A tiny, ugly, but complete demonstration of your entire game loop.  
* **Phase 5: Build Out & Polish**  
  * *Only after the vertical slice feels fun* do you start adding more. More levels, more tower types, story, dialogue, and the final art assets.

By following this phased approach, you ensure your core mechanics are fun before you invest hundreds of hours into assets and systems that might not work.