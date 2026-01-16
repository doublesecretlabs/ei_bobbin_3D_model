/* [Flange] */
flange_x = 40;
flange_y = 50;
flange_z = 1.5;
flange_radius = 2;

/* [Recess] */
// These should match the core outside dimensions from ei_bobbin.scad
recess_x = 25;        // core_inside_x + 2*core_wall
recess_y = 25;        // core_inside_y + 2*core_wall
recess_depth = 1;     // How deep the core slots into the cap
recess_clearance = 0.2;  // Extra clearance for fit
recess_radius = 0.5;

/* [Hole] */
// These should match the core inside dimensions from ei_bobbin.scad
hole_x = 23.5;
hole_y = 23.5;
hole_radius = 0.5;

/* [Notches] */
notch_count = 4;
notch_width = 2;
notch_depth = 5;  // How far the notch cuts into the flange from the edge

module roundedcube(xdim, ydim, zdim, rdim){
    hull(){
        translate([rdim,rdim,0])cylinder(h=zdim,r=rdim);
        translate([xdim-rdim,rdim,0])cylinder(h=zdim,r=rdim);
        translate([rdim,ydim-rdim,0])cylinder(h=zdim,r=rdim);
        translate([xdim-rdim,ydim-rdim,0])cylinder(h=zdim,r=rdim);
    }
}

module mirror_copy(v) {
    children();
    mirror(v) children();
}

module notches() {
    step = flange_x / (notch_count + 1);
    for (x = [step : step : flange_x - step]) {
        // Front edge (Y=0) - notch cuts inward from outside
        translate([x - notch_width/2, -1, -0.01])
            cube([notch_width, notch_depth + 1, flange_z + 0.02]);
        // Back edge (Y=flange_y) - notch cuts inward from outside
        translate([x - notch_width/2, flange_y - notch_depth, -0.01])
            cube([notch_width, notch_depth + 1, flange_z + 0.02]);
    }
}

// Calculate recess dimensions with clearance
recess_actual_x = recess_x + recess_clearance;
recess_actual_y = recess_y + recess_clearance;

// Calculate recess position (centered on flange)
recess_offset_x = (flange_x - recess_actual_x) / 2;
recess_offset_y = (flange_y - recess_actual_y) / 2;

// Calculate hole position (centered on flange)
hole_offset_x = (flange_x - hole_x) / 2;
hole_offset_y = (flange_y - hole_y) / 2;

difference(){
    roundedcube(flange_x, flange_y, flange_z, flange_radius);
    // Recess for core area to slot into
    translate([recess_offset_x, recess_offset_y, flange_z - recess_depth])
        roundedcube(recess_actual_x, recess_actual_y, recess_depth + 1, recess_radius);
    // Center hole (matches core inside dimensions)
    translate([hole_offset_x, hole_offset_y, -1])
        roundedcube(hole_x, hole_y, flange_z + 2, hole_radius);
    // Flange notches on front/back (Y-axis edges)
    notches();
}
