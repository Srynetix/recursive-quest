# gwj2-game

- **Name**: *TBD*

- **Theme**: Hidden within
- **Some rules**:
  - Short game (< 5 min)
  - Not too complicated
  - With a recursion idea
- **Main idea**: Minimal side-scrolling shooter with secrets and depth recursion.

- **Story**:
  - Spaceship seeking for treasure. Sees a space pyramid-thing glowing. Enter in pyramid, get trapped and tries to escape.
  - The pyramid is quite small, but at the only exit, the spaceship get shrunk and another pyramid become visible.
  - Spaceship enters the small pyramid and get trapped again.
  - Each pyramid is darker than the previous one, until pyramid n°3. At the end of pyramid n°3 there is nothing.
  - If all secrets have been found, last pyramid will grow, "replacing" the first one, with the spaceship, and the final exit will be open. Good end game.
  - If secrets are missing, last pyramid will shrink, destroying the ship, saying that we should have done better. Bad end game, starting over.

- **Gameplay**:
  - Type: Side-scrolling shooter.
  - Enemies:
    - Floating rocks
    - Defense systems
      - Shoot lasers
      - Build walls
  - Skills:
    - Laser shoot (classic)
      - Destroy rocks
      - Destroy defense systems
      - Do not destroy walls
    - Drill mode (go through short walls)
      - Destroy everything, BUT has a greater cooldown than lasers, so use with care
  - Paths:
    - As the player goes forward in the level, he can choose paths.
      - Secrets are hidden in paths (shown with gold light)
      - Exit is shown with green light
      - Other paths are normal
  - Movements:
    - Classic directional 8-way movement
    - Shoot lasers (A)
    - Drill mode (B)
    - Always shoot at scroll direction

- **Graphics**:
  - Minimal graphics, simple forms, some colors
  - Play with lights

- **Sound**:
  - Simple sounds, for ambience, lasers, drill, explosions, shrink sound.

- **Technical**:
  - Screen mode: Landscape
  - Resolution: 640x360 with 2x upscaling => 720p
