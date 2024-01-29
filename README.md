
![cover RR](https://github.com/GrugLikesRocks/Rising-Revenant/assets/92889945/9721cd3f-e655-4c5c-b7a4-60631e5b8a5c)

***An Introduction to Rising Revenant - The Ultimate Defense Game*** 


Embark on a journey into a new world, where revenants establish outposts amidst the untamed wilds, each bracing for a series of cataclysmic events. Rising Revenant isn't just a game; it's a test of your strategy, resilience, and foresight.

**On-Chain Events**


The precise location of each outpost is stored securely on-chain. Every X (TBC) amount of blocks, a random event strikes, determined transparently via an immutable on-chain method. This is visually represented on the game's tactical map.

**The Map**

The Map is a vibrant realm of burgeoning outposts. While these outposts thrive, they are constantly under threat from five looming perils:

Plague: A virulent disease that can wipe out your revenants.

Goblin Attack: Mischief-makers that emerge from the shadows to raid and plunder.

Earthquake: Ground-shaking tremors that threaten to shatter your defenses.

Hurricane: Destructive winds that can dismantle structures in their wake.

Dragon Attack: Majestic but deadly creatures that descend from the skies with fiery fury.

**Defend Your Outpost**

To safeguard your outpost, you have multiple defense mechanisms to choose from:

Food Storage: Vital to keep your revenants nourished and resilient against the plague.

Barricade: A stronghold against the marauding goblin invaders.

Castle: An emblem of might and stability, able to stand firm against the force of earthquakes.

Obsidian Bunker: The pinnacle of protection, offering refuge during the harshest hurricanes.

Dragon Shelter: Tailored with materials resistant to dragon flames, providing sanctuary from their aerial assaults.

**Boost Your Defenses**

Enhance your survival chances by strengthening your defenses. While each defensive structure has its inherent resistance, reinforcing them can be the deciding factor between endurance and demise. The costs involved in these enhancements contribute to the grand prize pool.

**The Ultimate Prize**

The proud owner of the last-standing outpost reaps a rich pool of $LORDS, sourced from defense setup fees and game initiation. The value of this pool corresponds directly to the total LORDS gathered during gameplay, with a fraction allocated for game developers and Biblio DAO.

**Trade and Tact**

Each outpost and reinforcement in Rising Revenant adheres to the ERC721 NFT standards. Players can trade their outposts and their defences at any game phase, facilitating strategic maneuvers and potential shifts in the map's balance of power.

**Conclusion**

Rising Revenant offers an exhilarating mix of strategy, chance, and foresight, making it a captivating endeavor for gamers and crypto enthusiasts. Will you rise to the challenge and etch your name in the annals of this adventure?
![Cover_WinnerRevenant](https://github.com/GrugLikesRocks/Rising-Revenant/assets/92889945/0777ee0d-9f8f-4209-b9b5-5f0fbd12e413)

***Rising Revenant Game Rules***

**Initial Phase: "The Dawn of Revenants"**

*Summoning the Revenants:* Players begin by invoking Revenants, powerful entities, through a mystical expenditure of $LORDS. Each successful summoning not only brings forth a Revenant but also establishes an Outpost around the game map.

*Building Outposts:* These bastions of power will initially have 1 health. Following a Revenant's summoning, players may fortify these Outposts in the following phase.

*Fortifying Outposts:* Outposts, symbols of your burgeoning empire, can be bolstered up to 20 times in their lifetime. The extent of reinforcements directly influences the Outpost’s defense, manifested in the number of shields it wields:
1-2 reinforcements: Unshielded
3-5 reinforcements: 1 Shield
6-9 reinforcements: 2 Shields
9-13 reinforcements: 3 Shields
14-19 reinforcements: 4 Shields
20 reinforcements: 5 Shields

*The Anticipation Screen:* Post-preparation, players enter a phase of strategic anticipation. Here, the summoning of new Revenants and bolstering of Outposts continues, setting the stage for the impending Main Phase.

**Gameplay Phase: "The Epoch of Confrontation"**

*Commencing the Main Phase:* Following the initial phase, the game escalates into a whirlwind of action, marked by attacks and disorder.

*Diverse Attacks:* Players must confront challenges ranging from cataclysmic natural disasters to the fiery wrath of dragons and the cunning onslaught of goblins.

*Main Phase Limitations:* In this critical phase, the focus shifts from expansion to survival. The creation of new Outposts and reinforcements ceases, though strategic trade with other players will represent the only way to achieve success.

*Endurance of Outposts:* The resilience of an Outpost is key, with its survival odds escalating with every reinforcement. The ultimate ambition? To stand as the last "Rising Revenant."

**Final Rewards**

*The Ultimate Prize:* The game’s transactions feed into a colossal final jackpot, destined for the sole Revenant who outlasts all others.

*Economic Dynamics of "Rising Revenant"*

Preparation Phase:
75% of $LORDS channeled into the final jackpot
10% allocated to transaction confirmation
15% as a creator tribute

Main Phase:
90% of $LORDS flows to the trader
5% augments the final jackpot
5% reserved as a lasting reward for the enduring players

These rules are your compass in the world of "Rising Revenant," guiding you through a labyrinth of summoning, defense, and cunning trade to claim the crown of the ultimate survivor.
--------------------------------------------

***How to launch the game***

After cloning the project:

1. **Terminal 1 - Katana:**

``` cd contracts && katana --disable-fee --block-time 1000 ```
or to have control of the block time
``` cd contracts && katana --disable-fee ```

2. **Terminal 2 - Contract build:**

``` cd contracts && sozo build && sozo migrate && torii --world 0x203899821810220c68f542e1bcd6e5c8db44ab378556bab4460a9b2694919ca ```

3. **Terminal 3 - Burner accounts:**

``` bash ./contracts/scripts/default_auth.sh ```
or (depends on OS)
``` sh ./contracts/scripts/default_auth.sh ```

if on WSL you get an issue about a pipeline look into this thread
https://askubuntu.com/questions/1497926/set-pipefail-failing-on-wsl-windows-11-ubuntu-22-04-3

4. **Terminal 4 - Client Front end:**

``` cd client && yarn && yarn dev ```

Upon completion, launch your browser and navigate to http://localhost:5147/


***How to deploy katana, torii & test erc20 contract at once***

Come to the root directory of the project

```sh run_local.sh```
