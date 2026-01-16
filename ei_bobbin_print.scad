// Print plate for EI bobbin and cap
// Imports both parts and places them side by side for printing

/* [Spacing] */
spacing = 10;  // Gap between parts

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

/* [Recess] */
recess_x = 25;
recess_y = 25;
recess_depth = 1;
recess_clearance = 0.2;
recess_radius = 0.5;

/* [Hole] */
hole_x = 23.5;
hole_y = 23.5;
hole_radius = 0.5;

/* [Notches] */
notch_count = 4;
notch_width = 2;
notch_depth = 5;

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
        translate([x - notch_width/2, -1, -0.01])
            cube([notch_width, notch_depth + 1, flange_z + 0.02]);
        translate([x - notch_width/2, flange_y - notch_depth, -0.01])
            cube([notch_width, notch_depth + 1, flange_z + 0.02]);
    }
}

module ei_bobbin() {
    core_x = core_inside_x + 2 * core_wall;
    core_y = core_inside_y + 2 * core_wall;
    core_offset_x = (flange_x - core_x) / 2;
    core_offset_y = (flange_y - core_y) / 2;
    hole_offset_x = (flange_x - core_inside_x) / 2;
    hole_offset_y = (flange_y - core_inside_y) / 2;

    difference(){
        union(){
            roundedcube(flange_x, flange_y, flange_z, flange_radius);
            translate([core_offset_x, core_offset_y, flange_z])
                roundedcube(core_x, core_y, core_z, core_radius);
        }
        translate([hole_offset_x, hole_offset_y, -1])
            roundedcube(core_inside_x, core_inside_y, flange_z + core_z + 2, core_radius);
        notches();
    }
}

module ei_bobbin_cap() {
    recess_actual_x = recess_x + recess_clearance;
    recess_actual_y = recess_y + recess_clearance;
    recess_offset_x = (flange_x - recess_actual_x) / 2;
    recess_offset_y = (flange_y - recess_actual_y) / 2;
    hole_offset_x = (flange_x - hole_x) / 2;
    hole_offset_y = (flange_y - hole_y) / 2;

    difference(){
        roundedcube(flange_x, flange_y, flange_z, flange_radius);
        translate([recess_offset_x, recess_offset_y, flange_z - recess_depth])
            roundedcube(recess_actual_x, recess_actual_y, recess_depth + 1, recess_radius);
        translate([hole_offset_x, hole_offset_y, -1])
            roundedcube(hole_x, hole_y, flange_z + 2, hole_radius);
        notches();
    }
}

// Place bobbin and cap side by side
ei_bobbin();
translate([flange_x + spacing, 0, 0])
    ei_bobbin_cap();
