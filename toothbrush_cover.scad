flip=true; // Print upside down to avoid using supports.
base_depth=66;
base_width=52;
base_height=30;
base_top_width=40; 
cap_thickness=3;
cap_taper=0.8;
wall_thickness=3;
tube_height=260;
air_hole_width=3;
tube_taper=0.9;
power_notch_width=30;
power_notch_depth=20;
power_notch_height=10;
max_width=100;

base_taper=base_top_width/base_width;

// Force Goldfeather needs to be enabled in preferences for a preview to work okay. Rendering works fine regardless.

translate([0, 0, flip ? base_height+tube_height+cap_thickness : 0]) rotate([flip ? 180 : 0,0,0]) union() {
  tube_base();
  translate([0,0,base_height]) main_tube();
  translate([0, 0, base_height+tube_height]) cap();
}

module main_oval() {
  scale([1,base_depth/base_width,1]) circle(d=base_width+wall_thickness);
}

module main_oval_hollow() {
  difference() {
    main_oval();
    scale([1,base_depth/base_width,1]) circle(d=base_width);
  }
}

module power_notch() {
  cube([power_notch_width, power_notch_depth, power_notch_height]);
}

module tube_base() {
  difference() {
    linear_extrude(height=base_height, scale=base_taper) main_oval_hollow();
    translate([power_notch_width/-2, base_depth/2-power_notch_depth/2, 0]) power_notch();
  }
}

module main_tube() {
  difference() {
    linear_extrude(height=tube_height, scale=tube_taper) scale([base_taper,base_taper,1]) main_oval_hollow();
    main_tube_air_holes();
  }
}

module main_tube_air_holes() {
  dupe_count=floor(tube_height/air_hole_width/2)-1;
  for(j=[1:dupe_count]) {
    hole_rotate = j/2==floor(j/2) ? 0 : 15;
    translate([0,0,j*air_hole_width*2]) rotate([0,0,hole_rotate])
    for(i=[0:30:180]) {
      rotate([90,0,i])
        translate([0,0,max_width/-2])
          linear_extrude(max_width)
            circle(d=air_hole_width);
    }
  }
}

module cap() {
  linear_extrude(height=cap_thickness, scale=cap_taper)
    scale([base_taper*tube_taper, base_taper*tube_taper, 1]) main_oval();
}
