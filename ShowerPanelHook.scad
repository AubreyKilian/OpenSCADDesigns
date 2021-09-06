// Shower panel hook
// Authored by: Aubrey Kilian aka MakerNewt@Thingiverse
// URL: https://www.thingiverse.com/makernewt/designs/
// Usage licence: Creative Commons Attribution - https://creativecommons.org/licenses/by/4.0/

// Notes:
// This is not perfect.  There are some combinations of values that will
// result in an unprintable mess.  Use with caution.
//


// Top plastic clip of panel thickness
Clip_Width = 12; // [10:50]

// Top plastic clip of panel height
Clip_Height = 22; // [10:50]

// Small clip width and height adjustment - just gets added to the Clip width and height values
Hook_Buffer_Space = 0.1; // [0:0.1:1]

// Radius of rounded corners for top clip part
Clip_Rounded_Corner_Radius = 1.5; // [0:0.1:3]

// Width of the top hook part that will clip over the shower panel
Hook_Width = 20; // [5:50]

// Thickness of all walls
Hook_Thickness = 3; // [1:0.1:5]

// Length of the leg going down, measured from the bottom of the top clip
Bottom_Leg_Length = 40; // [0:100]

// Length of the leg protruding at 90 degree angle from glass
Bottom_Protrude_Length = 25; // [10:100]

// Length of final hook part
Bottom_Hook_Length = 15; // [0:50]

// Angle at which final hook part is angled - 115 is a good number
Bottom_Hook_Angle=115;// [0:160]

// Whether to include the semi-circle cutout underneath the bottom protruding leg
Include_Cutout=true;

/* [Debug Parameters] */
// Do not print with this enabled, that would not be wise
Show_Glass_And_Plastic_Panel = false;
// Useful for debugging purposes, set the "Show_Glass_And_Plastic_Panel" variable to true
Glass_Width = 8;

/* [Hidden] */
eps = 0.01;

/********************************************************************************/
if(Show_Glass_And_Plastic_Panel) {
    #union() {
        // Glass
        translate([(Clip_Width + Hook_Buffer_Space + Hook_Thickness * 2)/2-Glass_Width/2,Hook_Thickness+eps+Hook_Buffer_Space/2,-Hook_Width/2])
            mirror([0,1,0])
                cube([Glass_Width, Clip_Height*10, Hook_Width*2]);
        // Plastic
        translate([Hook_Thickness+Hook_Buffer_Space/2,Hook_Thickness+Hook_Buffer_Space/2,-Hook_Width/2])
            cube([Clip_Width, Clip_Height, Hook_Width*2]);
    }

}

module main() {
    sanity_check();
    if(Include_Cutout) {
        difference() {
            MainBody();
            BottomHalfMoon();
        }
    } else {
        MainBody();
    }
}
module MainBody() {
    union()
    {
        difference()
        {
//        color("yellow")
            TopLipEnclosureShape();
            PlasticLipShape();
        }
//        color("red")
        HookClips();
        BottomHookShape();
    }
}

module TopLipEnclosureShape() {
    CUBE_INNER_SIZE_X = (Clip_Width + Hook_Buffer_Space)+(Hook_Thickness*2)-Clip_Rounded_Corner_Radius*2;
    CUBE_INNER_SIZE_Y = Clip_Height+Hook_Buffer_Space+(Hook_Thickness)-Clip_Rounded_Corner_Radius*2+Hook_Thickness;
    if(Clip_Rounded_Corner_Radius == 0) {
        cube([CUBE_INNER_SIZE_X,CUBE_INNER_SIZE_Y,Hook_Width]);
    } else {
        translate([Clip_Rounded_Corner_Radius,Clip_Rounded_Corner_Radius,0])
            cube([CUBE_INNER_SIZE_X,CUBE_INNER_SIZE_Y,Hook_Width]);
        
        TopHookCorners();
       
    }
}

module TopHookCorners() {
    TOP_HOOKS_POS_Y=Hook_Thickness+Clip_Height+Hook_Buffer_Space+Hook_Thickness;
    hull() {
        TopHookBottomCorners();
        translate([0,TOP_HOOKS_POS_Y,0])
            mirror([0,1,0])
                TopHookBottomCorners();
    }
}

module TopHookBottomCorners() {
    union() {
    // bottom-left
    TopHookOneCorner();
    
    // bottom-right
    translate([(Clip_Width + Hook_Buffer_Space)+Hook_Thickness*2,0,0])
        mirror([1,0,0])
            TopHookOneCorner();
    }
}

module TopHookOneCorner() {
    translate([Clip_Rounded_Corner_Radius,Clip_Rounded_Corner_Radius,0])
        difference() {
            translate([-Clip_Rounded_Corner_Radius,-Clip_Rounded_Corner_Radius,0])
                cube([Hook_Thickness,Hook_Thickness,Hook_Width]);

        translate([0,0,-eps])
            rotate([0,0,180])
                difference() {
                    cube([Hook_Thickness,Hook_Thickness,Hook_Width*2]);
                    translate([0,0,-eps])
                        cylinder(h=Hook_Width+1,r1=Clip_Rounded_Corner_Radius, r2=Clip_Rounded_Corner_Radius, $fn=100);
                }
            }
}

module PlasticLipShape() {
//color("cyan")    
    union() {
        // Plastic lip shape
        color("purple") 
        translate([Hook_Thickness,Hook_Thickness,-Hook_Width/2])
            cube([(Clip_Width + Hook_Buffer_Space), Clip_Height+Hook_Buffer_Space, Hook_Width*2]);

        // extra remove bottom piece
        color("red") 
        translate([Hook_Thickness,-0.1,-Hook_Width/2])
            cube([(Clip_Width + Hook_Buffer_Space), Hook_Thickness+0.2,Hook_Width*2]);
    }
}

    




module HookClips() {
    HookClip();
    translate([(Clip_Width + Hook_Buffer_Space)+(Hook_Thickness*2),0,0])
        mirror([1,0,0])
            HookClip();
}

module HookClip() {
    translate([Hook_Thickness,Hook_Thickness/2,0])
        cylinder(h=Hook_Width, r=Hook_Thickness/2, $fn=100, center=false);

}

module RotatedRoundRod(length, width, rotate_on_left=0, rotate_on_right=0, rotate_degrees=0) {
    
    assert(rotate_on_left != rotate_on_right, "You can't rotate on both ends, pick one!");
    
    if(rotate_on_left > 0) {
        translate([0,width/2,0])
            rotate([0,0,rotate_degrees])
                translate([0,-width/2,0])
                    Rod(length, width, 1, 1);
    }
    if(rotate_on_right > 0) {
        translate([length,width/2,0])
            rotate([0,0,rotate_degrees])
                translate([-length,-width/2,0])
                Rod(length, width, 1, 1);
    }
}
module Rod(length, width, rounded_left=0, rounded_right=0) {
    
    cube([length, width, Hook_Width]);
    if(rounded_left > 0) {
        translate([0,width/2,0])
            cylinder(r=width/2, h=Hook_Width, $fn=100);
    }
    if(rounded_right > 0) {
        translate([length,width/2,0])
        cylinder(r=width/2, h=Hook_Width, $fn=100);
    }
}


module BottomHalfMoon() {
    CYL_SIZE=Bottom_Protrude_Length + Hook_Thickness*3;

    HALFMOON_POS_X=Hook_Thickness/2+(Clip_Width + Hook_Buffer_Space)-eps;
    HALFMOON_POS_Y=-(Bottom_Leg_Length+Hook_Width);
    HALFMOON_POS_Z=Hook_Width/2;

    translate([HALFMOON_POS_X,HALFMOON_POS_Y,HALFMOON_POS_Z])
        rotate([0,90,0])
            cylinder(h=CYL_SIZE, r=Hook_Width, $fn=100);
}




module BottomHookShape() {

    // Down row
    DOWN_SIZE_X=Hook_Thickness;
    DOWN_SIZE_Y=Bottom_Leg_Length+Hook_Thickness;
    DOWN_VERT_POS_X=Hook_Thickness/2+(Clip_Width + Hook_Buffer_Space);
    DOWN_VERT_POS_Y=Hook_Thickness/2-DOWN_SIZE_Y;
    
//    color("red")
        translate([DOWN_VERT_POS_X,DOWN_VERT_POS_Y,0])
            Rod(DOWN_SIZE_X, DOWN_SIZE_Y);

    // Out rod
    OUT_VERT_POS_X=DOWN_VERT_POS_X+Hook_Thickness-eps;
    OUT_VERT_POS_Y=-DOWN_SIZE_Y+Hook_Thickness/2;
    OUT_SIZE_X=Bottom_Protrude_Length+Hook_Thickness;
    OUT_SIZE_Y=Hook_Thickness;
    
//    color("yellow")
    translate([OUT_VERT_POS_X,OUT_VERT_POS_Y,0])
        Rod(OUT_SIZE_X, OUT_SIZE_Y, 0, 1);
    
    // Up-and-back-hook
    BACK_DOWN_SIZE_X=Hook_Thickness;
    BACK_DOWN_SIZE_Y=Bottom_Hook_Length+Hook_Thickness/2;
    BACK_VERT_POS_X=DOWN_VERT_POS_X+OUT_SIZE_X+Hook_Thickness;
    BACK_VERT_POS_Y=-DOWN_SIZE_Y+Hook_Thickness/2;

//    color("cyan")
    translate([BACK_VERT_POS_X,BACK_VERT_POS_Y,0])
        RotatedRoundRod(BACK_DOWN_SIZE_Y,BACK_DOWN_SIZE_X,1,0,Bottom_Hook_Angle);

}

module sanity_check() {
    
    assert(Clip_Width > Glass_Width, "Clip_Width cannot be smaller than Glass_Width");
    assert(Hook_Thickness >= Clip_Rounded_Corner_Radius, "Hook_Thickness cannot be smaller than Clip_Rounded_Corner_Radius, it causes irregularites on the corners.");
    assert(Hook_Thickness >= Clip_Rounded_Corner_Radius, "Hook_Thickness needs to be bigger than Clip_Rounded_Corner_Radius, or else some unexpected behaviour could occur.");
}



main();
