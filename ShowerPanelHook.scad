// Shower panel hook
// Authored by: Aubrey Kilian aka MakerNewt@Thingiverse
// URL: https://www.thingiverse.com/makernewt/designs/
// Usage licence: Creative Commons Attribution - https://creativecommons.org/licenses/by/4.0/

// Notes:
// This is not perfect.  There are some combinations of values that will
// result in an unprintable mess.  Use with caution.
//
// GLASS_WIDTH is for reference and checking only.  But try to have it as accurate as possible, else the clip might not have a snug fit onto the panel.
//
// More Notes:
// There are some auto-adjustments that get made when the width increases, such as the small clips protrude more.  This is required to make the down hook part have a snug fit against the glass.

LIP_WIDTH = 12; // [10:50]
LIP_HEIGHT = 22; // [10:50]
HOOK_WIDTH = 20; // [1:50]
HOOK_THICKNESS = 3; // [1:10]
HOOK_BOTTOM_HEIGHT = 30; // [0:100]
HOOK_BOTTOM_PROTRUDE = 20; // [0:50]
HOOK_BOTTOM_UP_HOOK = 15; // [0:50]
HOOK_BOTTOM_ANGLE=115;// [20:160]
GLASS_WIDTH = 8; // [0:20]
OUTSIDE_ROUNDED_RADIUS = 1.5; // [0:0.5:3]

/* [Change with caution] */
HOOK_CLIP_SIZE = 1; // [0.1:0.1:2]

// Internal variables
_full_width = LIP_WIDTH + HOOK_THICKNESS * 2;
_side_width = HOOK_THICKNESS + HOOK_CLIP_SIZE * 2;
_missing = (_full_width - GLASS_WIDTH) / 2 - HOOK_THICKNESS - HOOK_CLIP_SIZE*2 ;

sanity_check();
    DOWN_SIZE_Y=HOOK_BOTTOM_HEIGHT+HOOK_CLIP_SIZE;
    DOWN_VERT_POS_X=HOOK_THICKNESS + _missing + HOOK_CLIP_SIZE*2 + GLASS_WIDTH;
    OUT_VERT_POS_Y=-DOWN_SIZE_Y+HOOK_CLIP_SIZE;

difference() {
    MainBody();
//    BottomHalfMoon();
}

module MainBody() {
    difference() {
        linear_extrude(height=HOOK_WIDTH)
        {
            union() {
                difference()
                {
                    TopHookShape();
                    PlasticLipShape();
                }
                HookClips();
                BottomHookShape();
            }
        }
    }
}
//                BottomHookShape();

//    color("red") BottomHalfMoon2D();

module BottomHalfMoon() {
    translate([DOWN_VERT_POS_X-1,OUT_VERT_POS_Y-HOOK_WIDTH+HOOK_THICKNESS/2,HOOK_WIDTH/2])
    rotate([0,90,0])
    cylinder(HOOK_WIDTH*2, HOOK_WIDTH, HOOK_WIDTH, $fn=100);
}

module BottomHalfMoon2D() {
    translate([DOWN_VERT_POS_X-1,OUT_VERT_POS_Y-HOOK_WIDTH+HOOK_THICKNESS/2,HOOK_WIDTH/2])
    rotate([0,90,0])
        linear_extrude(height=HOOK_BOTTOM_PROTRUDE+HOOK_THICKNESS*2)
            circle(HOOK_WIDTH, $fn=100);
}

module BottomHookShape() {

    // Down row
    DOWN_SIZE_X=HOOK_THICKNESS;
    DOWN_SIZE_Y=HOOK_BOTTOM_HEIGHT+HOOK_CLIP_SIZE;
    DOWN_VERT_POS_X=HOOK_THICKNESS + _missing + HOOK_CLIP_SIZE*2 + GLASS_WIDTH;
    DOWN_VERT_POS_Y=0;
    
//    color("red")
    mirror([0,1,0])
        translate([DOWN_VERT_POS_X,DOWN_VERT_POS_Y-HOOK_CLIP_SIZE,0])
            Rod(DOWN_SIZE_X, DOWN_SIZE_Y);

    // Out rod
    OUT_VERT_POS_X=DOWN_VERT_POS_X;
    OUT_VERT_POS_Y=-DOWN_SIZE_Y+HOOK_CLIP_SIZE;
    OUT_SIZE_X=HOOK_BOTTOM_PROTRUDE+HOOK_THICKNESS;
    OUT_SIZE_Y=HOOK_THICKNESS;
    
//    color("yellow")
    translate([OUT_VERT_POS_X,OUT_VERT_POS_Y,0])
        Rod(OUT_SIZE_X, OUT_SIZE_Y, 0, 1);
    
    // Up-and-back-hook
    BACK_DOWN_SIZE_X=HOOK_THICKNESS;
    BACK_DOWN_SIZE_Y=HOOK_BOTTOM_UP_HOOK+HOOK_CLIP_SIZE;
    BACK_VERT_POS_X=DOWN_VERT_POS_X+OUT_SIZE_X;
    BACK_VERT_POS_Y=-DOWN_SIZE_Y+HOOK_CLIP_SIZE;

//    color("cyan")
    translate([BACK_VERT_POS_X,BACK_VERT_POS_Y,0])
        RotatedRoundRod(BACK_DOWN_SIZE_Y,BACK_DOWN_SIZE_X,1,0,HOOK_BOTTOM_ANGLE);

}


module TopHookShape() {
    SQUARE_INNER_SIZE_X = LIP_WIDTH+(HOOK_THICKNESS*2)-OUTSIDE_ROUNDED_RADIUS*2;
    SQUARE_INNER_SIZE_Y = LIP_HEIGHT+(HOOK_THICKNESS)-OUTSIDE_ROUNDED_RADIUS*2+HOOK_CLIP_SIZE*2;
    if(OUTSIDE_ROUNDED_RADIUS == 0) {
        square([SQUARE_INNER_SIZE_X,SQUARE_INNER_SIZE_Y]);
    } else {
        translate([OUTSIDE_ROUNDED_RADIUS,OUTSIDE_ROUNDED_RADIUS,0])
        minkowski() {
            square([SQUARE_INNER_SIZE_X,SQUARE_INNER_SIZE_Y]);
            circle(r=OUTSIDE_ROUNDED_RADIUS, $fn=100);
        }
    }
}
    
module HookClips() {
    HookClip();
    translate([LIP_WIDTH+(HOOK_THICKNESS*2),0,0])
        mirror([1,0,0])
            HookClip();
}

module HookClip() {
    translate([HOOK_THICKNESS,0,0])
        square([HOOK_CLIP_SIZE+_missing, HOOK_CLIP_SIZE*2]);
    translate([HOOK_THICKNESS+HOOK_CLIP_SIZE+_missing,HOOK_CLIP_SIZE,0])
        circle(HOOK_CLIP_SIZE, $fn=100);
}

// Debug only
module show_reference_height_width() {
    translate([0,LIP_HEIGHT+(HOOK_THICKNESS)+HOOK_CLIP_SIZE/2,0.1])
    square(HOOK_THICKNESS);
    translate([LIP_WIDTH+HOOK_THICKNESS,LIP_HEIGHT+(HOOK_THICKNESS)+HOOK_CLIP_SIZE/2,0.1])
    square(HOOK_THICKNESS);
}

module PlasticLipShape() {
    union() {
        // Plastic lip shape
//        color("purple") 
        translate([HOOK_THICKNESS,HOOK_CLIP_SIZE*2,0])
            square([LIP_WIDTH, LIP_HEIGHT]);

        // Glass piece
//        color("green") 
        translate([LIP_WIDTH/2+HOOK_THICKNESS,-LIP_HEIGHT/2+HOOK_CLIP_SIZE*2,0])
            square([GLASS_WIDTH, LIP_HEIGHT],center=true);

        // extra remove bottom
        color("pink") 
        translate([HOOK_THICKNESS,-0.1,0])
            square([LIP_WIDTH, HOOK_CLIP_SIZE*2+0.2]);
    }
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
    
    square([length, width]);
    if(rounded_left > 0) {
        translate([0,width/2,0])
            circle(width/2, $fn=100);
    }
    if(rounded_right > 0) {
        translate([length,width/2,0])
        circle(width/2, $fn=100);
    }
}

module sanity_check() {
    
    assert(LIP_WIDTH > GLASS_WIDTH, "LIP_WIDTH cannot be smaller than GLASS_WIDTH");
    assert(HOOK_THICKNESS >= OUTSIDE_ROUNDED_RADIUS, "HOOK_THICKNESS cannot be smaller than OUTSIDE_ROUNDED_RADIUS, it causes irregularites on the corners.");
    assert( _side_width <= (_full_width - GLASS_WIDTH) / 2, "Glass width, lip width and clip radius values are incompatible.  Try decreasing HOOK_CLIP_SIZE -OR- double check your glass and/or lip width values.");
//    assert(HOOK_CLIP_SIZE >= OUTSIDE_ROUNDED_RADIUS, "HOOK_CLIP_SIZE needs to be bigger than EXTRA_RADIUS, or else some unexpected behaviour could occur.");
}

