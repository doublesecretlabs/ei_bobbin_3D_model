/* [Flange] */
flange_x = 40;
flange_y = 50;
flange_z = 1.5;
flange_radius = 2;

/* [Core Area] */
core_inside_x = 23.5;
core_inside_y = 23.5;
core_wall = 0.75;
core_z = 30;
core_radius = 0.5;

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

// Calculate core outside dimensions from inside + wall
core_x = core_inside_x + 2 * core_wall;
core_y = core_inside_y + 2 * core_wall;

// Calculate core position (centered on flange)
core_offset_x = (flange_x - core_x) / 2;
core_offset_y = (flange_y - core_y) / 2;

// Calculate hole position (centered on flange)
hole_offset_x = (flange_x - core_inside_x) / 2;
hole_offset_y = (flange_y - core_inside_y) / 2;

difference(){
    union(){
        roundedcube(flange_x, flange_y, flange_z, flange_radius);
        translate([core_offset_x, core_offset_y, flange_z])
            roundedcube(core_x, core_y, core_z, core_radius);
    }
    // Rectangular hole (inside dimensions of core area)
    translate([hole_offset_x, hole_offset_y, -1])
        roundedcube(core_inside_x, core_inside_y, flange_z + core_z + 2, core_radius);
    // Flange notches on front/back (Y-axis edges)
    notches();
}
