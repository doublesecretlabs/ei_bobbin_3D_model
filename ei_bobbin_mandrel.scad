/* [Shoulder] */
shoulder_x = 50;
shoulder_y = 50;
shoulder_z = 10;
shoulder_radius = 3;

/* [Core] */
core_x = 25;
core_y = 25;
core_z = 30;
core_radius = 3;

/* [Hole] */
hole_radius = 5;

/* [Countersink] */
countersink_depth = 2;
countersink_angle = 45;

module roundedcube(xdim, ydim, zdim, rdim){
    hull(){
        translate([rdim,rdim,0])cylinder(h=zdim,r=rdim);
        translate([xdim-rdim,rdim,0])cylinder(h=zdim,r=rdim);
        translate([rdim,ydim-rdim,0])cylinder(h=zdim,r=rdim);
        translate([xdim-rdim,ydim-rdim,0])cylinder(h=zdim,r=rdim);
    }
}

module countersink(radius, depth, angle=45) {
    // Creates a conical chamfer for the hole entry/exit
    cylinder(h=depth, r1=radius + depth*tan(angle), r2=radius, $fn=64);
}

// Calculate core position (centered on shoulder)
core_offset_x = (shoulder_x - core_x) / 2;
core_offset_y = (shoulder_y - core_y) / 2;

difference(){
    union(){
        roundedcube(shoulder_x, shoulder_y, shoulder_z, shoulder_radius);
        translate([core_offset_x, core_offset_y, shoulder_z])
            roundedcube(core_x, core_y, core_z, core_radius);
    }
    // Main hole
    translate([shoulder_x/2, shoulder_y/2, -1])
        cylinder(shoulder_z + core_z + 2, hole_radius, hole_radius);

    // Bottom countersink (shoulder entry)
    translate([shoulder_x/2, shoulder_y/2, -0.01])
        countersink(hole_radius, countersink_depth, countersink_angle);

    // Top countersink (core exit)
    translate([shoulder_x/2, shoulder_y/2, shoulder_z + core_z + 0.01])
        mirror([0, 0, 1])
            countersink(hole_radius, countersink_depth, countersink_angle);
}