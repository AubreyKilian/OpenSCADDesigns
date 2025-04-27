
e = 0.01;
e2 = e*2;
w_adj = 2;
h_adj = 1;

OneStandHeight = 10;
TrayBackLength = 62;
WedgeHeight = 3;
TrayWidth = 200;
LipHeight = 5;

AddHoles = true;
NumHoleRowsInTray = 15;
NumHolesPerRow = 5;
NumberOfSidesForHoles = 4;

FrontWedgeLegsHeight = 15;
FrontWedgeLegLength=10;
FrontWedgeLength = 29 + FrontWedgeLegLength;
TraySlideAngle = 3;

extraFloor=true;
WallWidth = 2;
FloorHeight = 2;

module TrayMain() {
    TrayBack();
    // BackTrayStand(5);
}

module TrayBack() {
    union() {
        translate([0,0,0]) BackTrayStand(2);
        translate([0,0,OneStandHeight]) Wedge(true, true, TrayBackLength, false);
        color("green") translate([0,-FrontWedgeLength+e2,OneStandHeight-WedgeHeight+e2]) Wedge(false, 1, FrontWedgeLength, true); 
    
        difference() {
            union() {
                translate([TrayWidth,0,OneStandHeight*3-FloorHeight]) rotate([0,180,0])  BackTrayStand(2,false,true);
                translate([0,0,OneStandHeight])                                          BackTrayStand(2);
            }
            if(AddHoles) {
                translate([WallWidth  ,0,OneStandHeight*2-FloorHeight-e])    PokeHoles(NumHolesPerRow, NumHoleRowsInTray, TrayBackLength, TrayWidth/2-WallWidth*3, FloorHeight+e2, 3, WallWidth/1.5);
                translate([TrayWidth/2,0,OneStandHeight*2-FloorHeight-e])    PokeHoles(NumHolesPerRow, NumHoleRowsInTray, TrayBackLength, TrayWidth/2-WallWidth*2.5, FloorHeight+e2, 3, WallWidth);
            }
        }

        // Add the legs for the front of the tray, underneath the front wedge
        translate([0,-FrontWedgeLength+e,OneStandHeight-FloorHeight*WedgeHeight-FrontWedgeLegsHeight+1]) {
            color("purple")
            BackTrayStand(10,false,false,FrontWedgeLegLength,FrontWedgeLegsHeight+FloorHeight);
        }

    }

}

// Huh - variables are immutable in OpenSCAD, so we need to use functions to set the offsets
function SetBackWallOffset(wallUser, WallWidth) = (wallUser == true ? WallWidth+e : -e);
function SetFrontWallOffset(wallUser, WallWidth) = (wallUser == true ? WallWidth+e: -e);

module BackTrayStand(numSections=1, frontWall=false, backWall=false, depth=TrayBackLength, height=OneStandHeight) {
    numWalls=numSections+1;
    SectionInnerWidth = (TrayWidth - (numSections + 1) * WallWidth) / numSections;
    FrontWallOffset = SetFrontWallOffset(frontWall, WallWidth);
    BackWallOffset = SetBackWallOffset(backWall, WallWidth);
    SectionInnerDepth = depth - BackWallOffset - FrontWallOffset;

    difference() {
        color("red")
        cube(size=[TrayWidth, depth, height], center=false);

        translate([WallWidth,FrontWallOffset,0])
        union() {
            for(i=[0:1:numSections-1]) {
                xOffset = i * ((TrayWidth - (numSections + 1) * WallWidth) / numSections + WallWidth);
                color("red")
                translate([xOffset,0, -e])
                cube(size=[SectionInnerWidth, SectionInnerDepth, height-FloorHeight], center=false);

            }
        }
    }
}
//FrontWedgeLegsHeight
module Wedge(addLip = true, addSides = true, depth=TrayBackLength, extraFloor=false) {
    union() {
        difference() {
            // Original cube
            color("red")   
            translate([e2,0,0]) 
            cube([TrayWidth-e2*2, depth-e, WedgeHeight-e2], center=false);
            
            // Calculate the angle to ensure the cut reaches the edge
            angle = atan(WedgeHeight / depth); // Angle in degrees
            translate([-e, -e, 0])
            rotate([angle, 0, 0])
            color("red")
            cube([TrayWidth+e2, depth*1.1, WedgeHeight*2], center=false);  // Larger cube for cutting
        }

        if(addLip) {
            // Add a little lip to the top of the wedge
            translate([e,depth-WallWidth+e,0])
            color("red")
            cube([TrayWidth, WallWidth, LipHeight], center=false);
        }

        if(addSides) {
            // Now do the same for the two sides
            translate([e,e,e])
            color("red")
            cube([WallWidth, depth-e, LipHeight], center=false);
            translate([TrayWidth-WallWidth-e,e,e])
            color("red")
            cube([WallWidth, depth-e, LipHeight], center=false);
        }

        if(extraFloor) {
            translate([e,0,-FloorHeight])
            color("red")
            cube([TrayWidth-e*2, depth-e, FloorHeight], center=false);
        }

    }
}


/*
    Module: PokeHoles

    Description:
        Creates a grid of holes arranged in rows and columns within a rectangular area.
        The holes are evenly spaced, and each row can optionally be offset to create a staggered pattern.

    Parameters:
        - numX (int): Number of holes in each row (columns).
        - numY (int): Number of rows of holes.
        - width (float): Total width of the rectangular area containing the holes.
        - height (float): Total height of the rectangular area containing the holes.
        - depth (float): Depth of the holes.
        - radius (float): Radius of each hole.
        - offsetFromOrigin (float): Offset distance for staggered rows.

    Notes:
        - The spacing between holes is calculated based on the width, height, and number of rows/columns.
        - Rows with an odd index are offset by the specified amount to create a staggered effect.
        - This module uses the `OneHoleRow` module to generate each row of holes.
*/
module PokeHoles(numX, numY, width, height, depth, radius, offsetFromOrigin) {
    Xo = height/numY;
    Yo = width/numX;
    // rotate([0,90,0])
    // mirror([1,0,0])
    union() {
        for (i=[0:1:numY-1]) {
            m = i % 2;
            OneHoleRow(numX, i, Xo, Yo, depth, radius, m, offsetFromOrigin);
        }
    }
}

module OneHoleRow(num, rowNum, Xo, Yo, depth, radius, m, offsetFromOrigin) {

            for (j=[0:1:num-1-m]) {
                x = rowNum*Xo + (Xo/2) + offsetFromOrigin;
                y = (j)*Yo + (Yo/2) + Yo * 0.5 * m;

                // Don't change this
                color("red")
                translate([x,y,-e])
                rotate([0,0,90])
                    cylinder(r=radius, h=depth+e2, center=false, $fn=NumberOfSidesForHoles);
            }   

}

// module main() {
//     difference() {
//         DriveBays(NumDrives);
//         // RoofChopOff();
//         PokeHoles(9,7,CageDepth-WallWidth,CageHeight-FloorHeight-RoofHeight,CageWidth,4.5, FloorHeight);

//     }
// }

// module RoofChopOff() {
//     translate([-e, -e, CageHeight-RoofHeight-e]) {
//         cube(size=[CageWidth + e2 + NumDrives * w_adj, CageDepth + e2, RoofHeight + e2], center=false);
//     }
// }

// module Wedges(TrayWidth) {
//     rotate([90,0,0])
//     union() {
//         Wedge();
//         translate([WallWidth*2+TrayWidth + WedgeWidth*2, 0, 0]) {
//             mirror([1, 0, 0]) {
//                 Wedge();
//             }
//         }
//     }
// }

// module Wedge() {
//     translate([0,0,-CageDepth])
//     hull() 
//     {
//         translate([WallWidth, e, FloorHeight]) {       
//             cube(size=[WedgeWidth, CageHeight-e2, WedgeStopFromBottom]);
//         }
//         translate([WallWidth, e, FloorHeight + WedgeStopFromBottom]) {       
//             cube(size=[WedgeWidth, CageHeight-e2, e]);
//         }
//         translate([WallWidth, e, CageDepth - WallWidth]) {       
//             cube(size=[e, CageHeight-e2, e]);
//         }
//     }
// }

// module DriveBays(num=1) {
//     union()
//     {
//         for (i=[0:1:num-1]) {
//             indexoffset = (i==0?0:i-1);
//             offs = ListAddition(PartialList(TrayWidths,0,indexoffset)) * (i==0?0:1) + w_adj*i;

//             translate([(WallWidth*(i))+offs+WedgeWidth*2*i, 0, 0]) {
//                 OneDriveBay(TrayWidths[i] + w_adj);
//             }
            
//         }
//     }
// }



// module OneDriveBay(width=TrayWidth) {
//     union() {
//         difference()
//         {
//             cube(size=[width+WallWidth*2 + WedgeWidth * 2, DriveDepth + WallWidth, DriveHeight + h_adj + FloorHeight + RoofHeight]);
//             translate([WallWidth+e, -e, FloorHeight]) {
//                 OneWedgeSpace();
//             }
//             translate([WallWidth+WedgeWidth, -e, FloorHeight]) {
//                 OneDrive(width);
//             }
//             translate([WallWidth+width+WedgeWidth-e, -e, FloorHeight]) {
//                 OneWedgeSpace();
//             }
//         }
//         Wedges(width);
//     }
// }

// module OneDrive(width=TrayWidth) {
//     cube(size=[width, DriveDepth, DriveHeight+h_adj]);
// }

// module OneWedgeSpace() {
//     cube(size=[WedgeWidth, DriveDepth, DriveHeight + h_adj]);
// }

// module PokeHoles(numX, numY, width, height, depth, radius, offsetFromOrigin) {
//     Xo = height/numY;
//     Yo = width/numX;
//     rotate([0,90,0]) mirror([1,0,0])
//     union() {
//         for (i=[0:1:numY-1]) {
//             m = i % 2;
//             OneHoleRow(numX, i, Xo, Yo, depth, radius, m, offsetFromOrigin);
//         }
//     }
// }

// module OneHoleRow(num, rowNum, Xo, Yo, depth, radius, m, offsetFromOrigin) {

//             for (j=[0:1:num-1-m]) {
//                 x = rowNum*Xo + (Xo/2) + offsetFromOrigin;
//                 y = (j)*Yo + (Yo/2) + Yo * 0.5 * m;

//                 // Don't change this
//                 translate([x,y,-e])
//                 rotate([0,0,90])
//                     cylinder(r=radius, h=depth+e2, center=false, $fn=6);
//             }   

// }

// function PartialList(list,start,end) = [for (i = [start:end]) list[i]];

// function ListAddition(v) = [for(p=v) 1]*v;

// function CalcCageTotalWidth(numDrives, wallWidth, TrayWidths, wedgeWidth) = (numDrives+1) * wallWidth + WedgeWidth * numDrives * 2 + ListAddition(TrayWidths) + NumDrives * w_adj;

TrayMain();
