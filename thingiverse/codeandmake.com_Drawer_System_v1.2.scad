/*
 * Copyright 2022 Code and Make (codeandmake.com)
 * 
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 * 
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 */

/*
 * Drawer System by Code and Make (https://codeandmake.com/)
 *
 * https://codeandmake.com/post/fully-customizable-drawer-system
 *
 * Drawer System v1.2 (2 March 2022)
 */

/* [General] */

// Drawer or Chest?
Part = 1; // [1: Drawer, 2: Chest, 3: All - Preview Only]

// Thickness of the material
Material_Thickness = 3; // [1:0.1:5]

/* [Drawer] */

// Width of the drawer
Drawer_Width = 180; // [20:1:300]

// Height of the drawer
Drawer_Height = 40; // [20:1:300]

// Depth of the drawer
Drawer_Depth = 180; // [20:1:300]

// Number of sections across
Drawer_Sections_Across = 2; // [1:1:10]

// Number of sections deep
Drawer_Sections_Deep = 2; // [1:1:10]

// Height of section wall as percentage of possible height
Drawer_Section_Wall_Height_Percent = 70; // [0:1:100]

// Width of handle as percentage of possible width
Handle_Width_Percent = 60; // [0:1:100]

// Height of handle as percentage of possible height
Handle_Height_Percent = 30; // [0:1:100]

// How to cutout section walls based on handle settings
Section_Wall_Cutout = 1; // [0: None, 1: Straight, 2: Rotational]

/* [Chest] */

// Number of drawers across
Drawers_Across = 1; // [1:1:10]

// Number of drawers high
Drawers_High = 4; // [1:1:10]

// Amount of gap around each side of the drawer (sides, top and rear)
Drawer_Gap = 1; // [0.1:0.1:5]

// Width of runners as percentage of possible width
Runner_Width_Percent = 50; // [1:1:100]

// Height of runners as multiplier of material thickness
Runner_Height_Multiplier = 1; // [1:0.1:10]

/* [All - Preview] */

// Show drawers in chest in 'All - Preview Only' mode
Show_Drawers_In_Preview = 0; // [0: No, 1: Yes]

// Amount to slide out drawers in 'All - Preview Only' mode as percentage of drawer depth
Slide_Out_Drawers_In_Preview_Percent = 0; // [0:1:200]

module drawerSystem() {
  $fn = 60;

  drawerSectionWidth = (Drawer_Width - (Material_Thickness * (Drawer_Sections_Across + 1))) / Drawer_Sections_Across;
  drawerSectionDepth = (Drawer_Depth - (Material_Thickness * (Drawer_Sections_Deep + 1))) / Drawer_Sections_Deep;

  chestSectionWidth = Drawer_Width + (Drawer_Gap * 2);
  chestSectionHeight = Drawer_Height + Drawer_Gap;
  chestSectionDepth = Drawer_Depth + Drawer_Gap;

  runnerHeight = Material_Thickness * Runner_Height_Multiplier;

  module drawerSectionProfile() {
    translate([Material_Thickness, Material_Thickness, 0]) {
      offset(r = Material_Thickness) {
        square(size = [drawerSectionWidth - (Material_Thickness * 2), drawerSectionDepth - (Material_Thickness * 2)]);
      }
    }
  }

  module drawerSectionsProfile() {
    for (x = [0:Drawer_Sections_Across - 1]) {
      for (y = [0:Drawer_Sections_Deep - 1]) {
        translate([Material_Thickness + (x * (drawerSectionWidth + Material_Thickness)),
          Material_Thickness + (y * (drawerSectionDepth + Material_Thickness)),
          0]) {
          drawerSectionProfile();
        }
      }
    }
  }

  module drawerOuterProfile() {
    translate([Material_Thickness, Material_Thickness, 0]) {
      offset(r = Material_Thickness) {
        square(size = [Drawer_Width - (Material_Thickness * 2), Drawer_Depth - (Material_Thickness * 2)]);
      }
    }
  }

  module drawerInnerProfile() {
    translate([Material_Thickness * 2, Material_Thickness * 2, 0]) {
      offset(r = Material_Thickness) {
        square(size = [Drawer_Width - (Material_Thickness * 4), Drawer_Depth - (Material_Thickness * 4)]);
      }
    }
  }

  module drawerBody() {
    difference() {
      linear_extrude(height = Drawer_Height, convexity = 10) {
        drawerOuterProfile();
      }

      translate([0, 0, Material_Thickness]) {
        linear_extrude(height = Drawer_Height, convexity = 10) {
          drawerSectionsProfile();
        }
      }

      if (Drawer_Section_Wall_Height_Percent < 100) {
        translate([0, 0, Drawer_Height + 0.1]) {
          mirror([0, 0, 1]) {
            linear_extrude(height = (Drawer_Height - Material_Thickness) * ((100 - Drawer_Section_Wall_Height_Percent) / 100) + 0.1, convexity = 10) {
              drawerInnerProfile();
            }
          }
        }
      }
    }
  }

  module handleHalfProfile() {
    topX = (((Drawer_Width / 2) - (Material_Thickness * 2)) * (Handle_Width_Percent / 100));
    bottomY = (-Drawer_Height + Material_Thickness) * (Handle_Height_Percent / 100);

    intersection() {
      offset(r = Material_Thickness) {
        offset(r = -Material_Thickness) {
          polygon(points = [
            [-(Material_Thickness * 2), (Material_Thickness * 2)],
            [topX + (Material_Thickness * 2), (Material_Thickness * 2)],
            [max(topX + bottomY, Material_Thickness), max(bottomY, -topX + Material_Thickness)],
            [-(Material_Thickness * 2), max(bottomY, -topX + Material_Thickness)]
          ]);
        }
      }

      polygon(points = [
        [0, 0],
        [topX, 0],
        [max(topX + bottomY, 0), max(bottomY, -topX)],
        [0, max(bottomY, -topX)]
      ]);
    }

    if(Section_Wall_Cutout == 0) {
      square(size = [topX, 1]);
    }
  }

  module handlProfile() {
    handleHalfProfile();
    mirror([1, 0, 0]) {
      handleHalfProfile();
    }
  }

  module handleCutoutBody() {
    hull() {
      translate([Drawer_Width / 2, Material_Thickness, Drawer_Height]) {
        rotate([90, 0, 0]) {
          linear_extrude(height = Material_Thickness + 1, convexity = 10) {
            handlProfile();
          }
        }
      }

      if(Section_Wall_Cutout == 1) {
        translate([Drawer_Width / 2, Material_Thickness, Drawer_Height]) {
          mirror([0, 1, 0]) {
            linear_extrude(height = Material_Thickness + 1, convexity = 10) {
              handlProfile();
            }
          }
        }
      }
    }

    if(Section_Wall_Cutout == 2) {
      seperatorHandleCutoutRotational();
    }
  }

  module seperatorHandleCutoutRotational() {
    translate([Drawer_Width / 2, Material_Thickness, Drawer_Height]) {
      rotate([0, 90, 0]) {
        rotate_extrude(convexity = 10, $fn = 120) {
          rotate([0, 0, 90]) {
            handlProfile();  
          }
        }
      }
    }
  }

  module drawer() {
    difference() {
      drawerBody();
      handleCutoutBody();
    }
  }

  module allDrawers() {
    for (x = [0:Drawers_Across - 1]) {
      for (y = [0:Drawers_High - 1]) {
        translate([(chestSectionWidth + Material_Thickness) * x, (chestSectionHeight + runnerHeight) * y, 0]) {
          translate([Material_Thickness + Drawer_Gap, Material_Thickness, Material_Thickness + Drawer_Gap]) {
            rotate([-90, 0, 0]) {
              translate([0, -Drawer_Depth, 0]) {
                drawer();
              }
            }
          }
        }
      }
    }
  }

  module chestSectionProfile() {
    square(size = [chestSectionWidth, chestSectionHeight]);
  }

  module chestSectionsProfile() {
    for (x = [0:Drawers_Across - 1]) {
      for (y = [0:Drawers_High - 1]) {
        translate([Material_Thickness + ((chestSectionWidth + Material_Thickness) * x),
          Material_Thickness + ((chestSectionHeight + runnerHeight) * y),
          0]) {
          chestSectionProfile();
        }
      }
    }
  }

  module chestColumnProfile() {
    translate([Material_Thickness, Material_Thickness, 0]) {
      square(size = [chestSectionWidth, (chestSectionHeight * Drawers_High) + (runnerHeight * (Drawers_High - 1))]);
    }
  }

  module chestColumnsBody() {
    for (x = [0:Drawers_Across - 1]) {
      translate([(chestSectionWidth + Material_Thickness) * x, 0, Material_Thickness]) {
        linear_extrude(height = chestSectionDepth + 1, convexity = 10) {
          chestColumnProfile();
        }
      }
    }
  }

  module chestOuterProfile() {
    translate([Material_Thickness, Material_Thickness, 0]) {
      offset(r = Material_Thickness) {
        square(size = [((chestSectionWidth + Material_Thickness) * Drawers_Across) - Material_Thickness, (chestSectionHeight * Drawers_High) + (runnerHeight * (Drawers_High - 1))]);
      }
    }
  }

  module drawerRunnerProfile() {
    drawRunnerMinX = Drawer_Gap + Material_Thickness;
    drawRunnerMaxX = chestSectionWidth / 2;
    drawRunnerX = drawRunnerMinX + (drawRunnerMaxX - drawRunnerMinX) * (Runner_Width_Percent / 100);

    if (Runner_Width_Percent < 100) {
      intersection() {
        offset(r = Material_Thickness) {
          offset(r = -Material_Thickness) {
            polygon(points = [
              [-Material_Thickness, 0],
              [-Material_Thickness, chestSectionDepth + Material_Thickness],
              [drawRunnerX, chestSectionDepth + Material_Thickness],
              [drawRunnerX, 0],
            ]);
          }
        }

        square(size = [chestSectionWidth, chestSectionDepth]);
      }
    } else {
      square(size = [chestSectionWidth, chestSectionDepth]);
    }
  }

  module chestRunnersBody() {
    for (x = [0:Drawers_Across - 1]) {
      translate([(chestSectionWidth + Material_Thickness) * x, 0, 0]) {
        translate([Material_Thickness, Material_Thickness, Material_Thickness + chestSectionDepth]) {
          rotate([-90, 0, 0]) {
            linear_extrude(height = (chestSectionHeight * Drawers_High) + (runnerHeight * (Drawers_High - 1)), convexity = 10) {
              drawerRunnerProfile();

              translate([chestSectionWidth, 0, 0]) {
                mirror([1, 0, 0]) {
                  drawerRunnerProfile();
                }
              }
            }
          }
        }
      }
    }
  }

  module chestRunnerCutoutBody() {
    difference() {
      chestColumnsBody();
      chestRunnersBody();
    }
  }

  module chestBody() {
    difference() {
      linear_extrude(height = chestSectionDepth + Material_Thickness, convexity = 10) {
        chestOuterProfile();
      }

      translate([0, 0, Material_Thickness]) {
        linear_extrude(height = chestSectionDepth + Material_Thickness, convexity = 10) {
          chestSectionsProfile();
        }
      }

      chestRunnerCutoutBody();
    }
  }

  if (Part == 1) {
    drawer();
  } else if (Part == 2) {
    chestBody();

    if ($preview && Show_Drawers_In_Preview) {
      %allDrawers();
    }
  } else if (Part == 3) {
    if ($preview) {
      translate([0, chestSectionDepth + Material_Thickness, 0]) {
        rotate([90, 0, 0]) {
          %chestBody();
          translate([0, 0, Drawer_Depth * (Slide_Out_Drawers_In_Preview_Percent / 100)]) {
          #allDrawers();
          }
        }
      }
    }
  }
}

drawerSystem();

echo("\r\tThis design is completely free and shared under a permissive license.\r\tYour support is hugely appreciated: codeandmake.com/support\r");
