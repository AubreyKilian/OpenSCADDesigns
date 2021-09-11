
e = 0.01;
e2 = e*2;
w_adj = 0;
h_adj = 0.5;

DriveDepth = 117.1;
DriveHeight = 80;
DriveWidth = 20.1;
ThinDriveWidth = 14.5;

// DriveDepth = 100;
// DriveHeight = 80;
// DriveWidth = 20;
// ThinDriveWidth = 10;

DriveWidths = [ThinDriveWidth, ThinDriveWidth, DriveWidth, DriveWidth, ThinDriveWidth];
NumDrives = len(DriveWidths);

WallWidth = 1;
FloorHeight = 2;
RoofHeight = WallWidth;
WedgeWidth = 2;
WedgeStopFromBottom = DriveHeight/4;

CageHeight = DriveHeight + FloorHeight + RoofHeight + h_adj; 
CageWidth = CalcCageTotalWidth(NumDrives, WallWidth, DriveWidths, WedgeWidth);
CageDepth = DriveDepth + WallWidth;

module main() {
    difference() {
        DriveBays(NumDrives);
        //RoofChopOff();
    }
}

module RoofChopOff() {
    translate([-e, -e, CageHeight-RoofHeight-e]) {
        cube(size=[CageWidth + e2 + NumDrives * w_adj, CageDepth + e2, RoofHeight + e2], center=false);
    }
}

module Wedges(driveWidth) {
    Wedge();
    translate([WallWidth*2+driveWidth + WedgeWidth*2, 0, 0]) {
        mirror([1, 0, 0]) {
            Wedge();
        }
    }
}

module Wedge() {
    hull() 
    {
        translate([WallWidth, 0, CageHeight - WallWidth]) {       
            cube(size=[e, CageDepth, e]);
        }
        translate([WallWidth, 0, FloorHeight + WedgeStopFromBottom]) {       
            cube(size=[WedgeWidth, CageDepth, e]);
        }
        translate([WallWidth, 0, FloorHeight]) {       
            cube(size=[WedgeWidth, CageDepth, WedgeStopFromBottom]);
        }
    }
}

module DriveBays(num=1) {
    union() {
        for (i=[0:1:num-1]) {
            indexoffset = (i==0?0:i-1);
            offs = ListAddition(PartialList(DriveWidths,0,indexoffset)) * (i==0?0:1) + w_adj*i;

            translate([(WallWidth*(i))+offs+WedgeWidth*2*i, 0, 0]) {
                OneDriveBay(DriveWidths[i] + w_adj);
            }
            
        }
    }
}



module OneDriveBay(width=DriveWidth) {
    union() {
        difference()
        {
            cube(size=[width+WallWidth*2 + WedgeWidth * 2, DriveDepth + WallWidth, DriveHeight + h_adj + FloorHeight + RoofHeight]);
            translate([WallWidth+e, -e, FloorHeight]) {
                OneWedgeSpace();
            }
            translate([WallWidth+WedgeWidth, -e, FloorHeight]) {
                OneDrive(width);
            }
            translate([WallWidth+width+WedgeWidth-e, -e, FloorHeight]) {
                OneWedgeSpace();
            }
        }
        Wedges(width);
    }
}

module OneDrive(width=DriveWidth) {
    cube(size=[width, DriveDepth, DriveHeight+h_adj]);
}

module OneWedgeSpace() {
    cube(size=[WedgeWidth, DriveDepth, DriveHeight + h_adj]);
}

function PartialList(list,start,end) = [for (i = [start:end]) list[i]];

function ListAddition(v) = [for(p=v) 1]*v;

function CalcCageTotalWidth(numDrives, wallWidth, driveWidths, wedgeWidth) = (numDrives+1) * wallWidth + WedgeWidth * numDrives * 2 + ListAddition(driveWidths) + NumDrives * w_adj;

main();
