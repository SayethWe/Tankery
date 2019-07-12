# Tankery

A co-operative Tanking game demo/proof-of-concept

Drive around ![a field](https://github.com/geekman9097/Tankery/blob/master/screenshots/Overview.png) and fire ![Firing](https://github.com/geekman9097/Tankery/blob/master/screenshots/Firing.png) at enemy tanks.

There are three roles actually planned and somewhat implemented.

###The Commander:
![commander default view] (https://github.com/geekman9097/Tankery/blob/master/screenshots/CommanderNear.png)
Has no direct impact on the tank itself, but has the widest view, and can most quickly look around.
in a 3d-version, would also be responsible for helping to identify and range-find.
Can direct the gunner to targets, and in 3-d, has a sight on the top of the turret that when overlaps with his target, tells the commander the gunner is roughly on line.

Can also drop alert pings on the map for his crewmates to use.

Currently has three optics, the default of which was shown above.

![medium-range](https://github.com/geekman9097/Tankery/blob/master/screenshots/CommanderMid.png)
![long-range](https://github.com/geekman9097/Tankery/blob/master/screenshots/CommanderFar.png)

### The Gunner:
![gunner-view](https://github.com/geekman9097/Tankery/blob/master/screenshots/GunnerView.png)

Controls the turret. Rotates to face targets. Also, understandably, fires the gun.

His view is locked in the direction the weapon is currently facing, and will also rotate as the body of the tank is turned to stay in-line with the turret front.

Has two views currently, teh default of which is very small and not yet fleshed out very well.

### The Driver

![driver-view](https://github.com/geekman9097/Tankery/blob/master/screenshots/DriverView.png)

Responsible for the movement of the hull of the tank. Has one fixed view, permanently looking out of the front of the vehicle. To reverse, relies on the commander.

---

Based on the following pitch document:

---

### The basic concept:
Multiple players work together to control an armored fighting vehicle.

Fight against AI or other human-crewed tanks

for a single-crew option, have the radio operator also command the rest of a tank platoon

#### Roles
* Commander
  * Acquires targets
  * Can also function as the radio operator
* Gunner
  * Ranges targets
  * Aims and Fires Gun(s)
     * Rotates Turret
     * Elevates Weapon
* Driver
  * moves the chassis

Loaders(and bow/machine gunners) existed, but I don't see that as being a particularly enjoyable role for a player.

#### Possiblities:

* VR
* Custom-built AFVs
	* See: Crossout
* Multiplayer Matchmaking
	* Queue up to be put in a tank with other humans

---

Moved to Top-Down view for demo purposes.

Current state: non-firing enemy tanks, all made from TEST parts. Shooting, movement, implemented fog.
