wall_thickness = 2;

// Inner dimensions for all widths and depths.

base_bottom_width = 50;
base_bottom_depth = 62;
base_top_width = 42;
base_top_depth = 55;
base_height = 26;

power_notch_width = 32;
power_notch_depth = 20;
power_notch_height = 8;
power_notch_offset = 10;

base_tube_transition_height = 10;

tube_diameter = 42;
tube_height = 206;

head_case_mount_width = 12;
head_case_mount_height = 65;

// Calculated
base_taper = get_minimal_taper(base_bottom_depth, base_bottom_width, base_top_depth, base_top_width);
base_top_width_actual = base_bottom_width * base_taper;
base_top_depth_actual = base_bottom_depth * base_taper;

union() {
  color("yellow", 0.5) difference() {
    basic_base(base_bottom_depth, base_bottom_width, base_height, wall_thickness, base_taper);
    translate([0, base_bottom_depth/2-power_notch_offset, 0])
      power_notch(power_notch_width, power_notch_depth, power_notch_height);
  }

  color("green", 0.5) translate([0, 0, base_height])
    base_tube_transition(base_top_width_actual, base_top_depth_actual, tube_diameter, base_tube_transition_height, wall_thickness);

  color("red", 0.5) translate([0, 0, base_height+base_tube_transition_height]) difference() {
    tube(tube_diameter, tube_height - base_tube_transition_height, wall_thickness);
    tube_air_holes(tube_diameter+3*wall_thickness, tube_height - base_tube_transition_height, wall_thickness, 30);
  }
  
  color("green", 0.5) translate([0, 0, base_height+tube_height])
    cap(tube_diameter, wall_thickness, wall_thickness, wall_thickness);
    
  color("blue", 0.8)
  translate([0, tube_diameter/-2, base_height+base_tube_transition_height]) 
    head_case_mount(head_case_mount_width, head_case_mount_height, wall_thickness);
}

// Use the lesser taper to ensure clearance (closest to 1.0)
function get_minimal_taper(bottom_depth, bottom_width, top_depth, top_width) = (top_width / bottom_width) > (top_depth / bottom_depth) ? top_width / bottom_width : top_depth / bottom_depth;

module tube(diameter, height, wall_thickness) {
  difference() {
    cylinder(h=height, r=diameter/2+wall_thickness);
    cylinder(h=height, r=diameter/2);
  }
}

module tube_air_holes(cylinder_diameter, cylinder_height, hole_diameter, angular_increment) {
  for(i=[1:floor((cylinder_height-2*hole_diameter)/hole_diameter/2)]) {
    translate([0, 0, i*hole_diameter*2-hole_diameter/2]) rotate([0, 0, i/2==floor(i/2) ? 0 : 15])
      for(r=[0:angular_increment:180-angular_increment]) {
        rotate([0, 0, r]) translate([0, cylinder_diameter/2, hole_diameter])
            rotate([90, 0, 0]) cylinder(h=cylinder_diameter, r=hole_diameter);  
      }
  }
}

module base_tube_transition(bottom_width, bottom_depth, top_diameter, height, wall_thickness) {
  increment = 0.1;
  slices = height * 1/increment;
  for(i=[0:slices]) {
    width = bottom_width * (1-i/slices) + top_diameter * i/slices;
    depth = bottom_depth * (1-i/slices) + top_diameter * i/slices;
    translate([0, 0, i*increment]) linear_extrude(increment) difference() {
      scale([1,depth/width,1]) circle(d=width+2*wall_thickness);
      scale([1,depth/width,1]) circle(d=width);
    }
  }
}

module power_notch(width, depth, height) {
  translate([0, depth/2, height/2]) union() {
    cube([width, depth, height], center=true);
    translate([0, 0, height/2]) rotate([90, 0, 0]) cylinder(h=depth, d=width, center=true);
  }
}

module basic_base(depth, width, height, wall_thickness, taper) {
  linear_extrude(height, scale=taper) difference() {
    scale([1,depth/width,1]) circle(d=width+2*wall_thickness);
    scale([1,depth/width,1]) circle(d=width);
  }
}

module cap(diameter, height, wall_thickness, hole_diameter) {
  holes = 8;
  difference() {
    cylinder(h=height, r=diameter/2+wall_thickness);
    for(i=[0:holes-1]) {
      rotate([0, 0, 360/holes*i]) translate([diameter/4, 0, 0]) cylinder(h=wall_thickness, r=hole_diameter);
    }
  }
}

module head_case_mount(width, height, wall_thickness) {
  // Slotted box
  translate([0, 0, wall_thickness*4]) difference() {
    translate([width/-2, -3*wall_thickness, 0]) cube([width, 3*wall_thickness, height]);
    translate([(width-2*wall_thickness)/-2, -2*wall_thickness, 0]) cube([width-2*wall_thickness, wall_thickness, height]);
    translate([wall_thickness/-2, -3*wall_thickness, 0]) cube([wall_thickness, wall_thickness, height]);
  }
  // Support
  translate([0, 0, wall_thickness*4])
  rotate([180, 0, 0]) linear_extrude(height=3*wall_thickness, scale=0) translate([width/-2, 0, 0]) square([width, wall_thickness*3]);
}
