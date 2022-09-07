flip = false; // Print upside down to avoid using supports.
wall_thickness = 2;

base_bottom_width = 50;
base_bottom_depth = 62;
base_top_width = 42;
base_top_depth = 55;
base_height = 26;

power_notch_width = 32;
power_notch_depth = 20;
power_notch_height = 11;
power_notch_offset = 10;

base_tube_transition_height = 10;

tube_diameter = 42;
tube_height = 166;

spire_diameter = 16;
spire_height = 40;

// Calculated
base_taper = get_minimal_taper(base_bottom_depth, base_bottom_width, base_top_depth, base_top_width);
base_max_bottom_diameter = base_bottom_width > base_bottom_depth ? base_bottom_width : base_bottom_depth;
base_max_top_diameter = base_max_bottom_diameter * base_taper;

color("yellow", 0.8) difference() {
  basic_base(base_bottom_depth, base_bottom_width, base_height, wall_thickness, base_taper);
  translate([0, base_bottom_depth/2-power_notch_offset, 0]) power_notch(power_notch_width, power_notch_depth, power_notch_height);
}

translate([0, 0, base_height]) base_tube_transition(base_max_top_diameter, tube_diameter, base_tube_transition_height, wall_thickness);

translate([0, 0, base_height+base_tube_transition_height]) tube(tube_diameter, tube_height - base_tube_transition_height, wall_thickness);

module tube(diameter, height, wall_thickness) {
  difference() {
    cylinder(h=height, r=diameter/2+wall_thickness);
    cylinder(h=height, r=diameter/2);
  }
}

module base_tube_transition(bottom_diameter, top_diameter, height, wall_thickness) {
  buffer = 3;
  translate([0, 0, buffer]) difference() {
    cylinder(h=height-buffer, r1=bottom_diameter/2+wall_thickness, r2=top_diameter/2+wall_thickness);
    cylinder(h=height-buffer, r1=bottom_diameter/2, r2=top_diameter/2);
  }
  difference() {
    cylinder(h=buffer, r=bottom_diameter/2+wall_thickness);
    cylinder(h=buffer, r=bottom_diameter/2);
  }
}

module power_notch(width, depth, height) {
  translate([0, depth/2, height/2]) cube([width, depth, height], center=true);
}

// Use the lesser taper to ensure clearance (closest to 1.0)
function get_minimal_taper(bottom_depth, bottom_width, top_depth, top_width) = (top_width / bottom_width) > (top_depth / bottom_depth) ? top_width / bottom_width : top_depth / bottom_depth;

module basic_base(depth, width, height, wall_thickness, taper) {
  linear_extrude(height, scale=taper) difference() {
    scale([1,depth/width,1]) circle(d=width+wall_thickness);
    scale([1,depth/width,1]) circle(d=width);
  }
}

//cap_thickness=3;
//cap_taper=0.8;
//wall_thickness=3;
//tube_height=260;
//air_hole_width=3;
//tube_taper=0.9;
//power_notch_width=30;
//power_notch_depth=20;
//power_notch_height=10;
//max_width=100;
//
//base_taper=base_top_width/base_width;
//
//// Force Goldfeather needs to be enabled in preferences for a preview to work okay. Rendering works fine regardless.
//tube_base();
//
//* translate([0, 0, flip ? base_height+tube_height+cap_thickness : 0]) rotate([flip ? 180 : 0,0,0]) union() {
//  tube_base();
//  translate([0,0,base_height]) main_tube();
//  translate([0, 0, base_height+tube_height]) cap();
//}
//
//module main_oval() {
//  scale([1,base_depth/base_width,1]) circle(d=base_width+wall_thickness);
//}
//
//module main_oval_hollow() {
//  difference() {
//    main_oval();
//    scale([1,base_depth/base_width,1]) circle(d=base_width);
//  }
//}
//
//module power_notch() {
//  cube([power_notch_width, power_notch_depth, power_notch_height]);
//}
//
//module tube_base() {
//  difference() {
//    linear_extrude(height=base_height, scale=base_taper) main_oval_hollow();
//    translate([power_notch_width/-2, base_depth/2-power_notch_depth/2, 0]) power_notch();
//  }
//}
//
//module main_tube() {
//  difference() {
//    linear_extrude(height=tube_height, scale=tube_taper) scale([base_taper,base_taper,1]) main_oval_hollow();
//    main_tube_air_holes();
//  }
//}
//
//module main_tube_air_holes() {
//  dupe_count=floor(tube_height/air_hole_width/2)-1;
//  for(j=[1:dupe_count]) {
//    hole_rotate = j/2==floor(j/2) ? 0 : 15;
//    translate([0,0,j*air_hole_width*2]) rotate([0,0,hole_rotate])
//    for(i=[0:30:180]) {
//      rotate([90,0,i])
//        translate([0,0,max_width/-2])
//          linear_extrude(max_width)
//            circle(d=air_hole_width);
//    }
//  }
//}
//
//module cap() {
//  linear_extrude(height=cap_thickness, scale=cap_taper)
//    scale([base_taper*tube_taper, base_taper*tube_taper, 1]) main_oval();
//}
