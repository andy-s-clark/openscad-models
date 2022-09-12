wall_thickness = 2;

// Inner dimensions for all widths and depths.

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
spire_cap_height = 6;

tube_spire_transition_height = 10;

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

  color("yellow", 0.5) translate([0, 0, base_height+tube_height])
    tube_spire_transition(tube_diameter, spire_diameter, tube_spire_transition_height, wall_thickness);

  color("green", 0.5) translate([0, 0, base_height+tube_height+tube_spire_transition_height]) difference() {
    tube(spire_diameter, spire_height - tube_spire_transition_height, wall_thickness);
    tube_air_holes(spire_diameter+3*wall_thickness, spire_height - tube_spire_transition_height, wall_thickness, 45);
  }
  
  color("red", 0.5) translate([0, 0, base_height+tube_height+spire_height])
    spire_cap(spire_diameter, spire_cap_height, wall_thickness);
  
  // TODO Head Holder
}

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
  // LATER Figure out why the bottom is slightly larger than the top of the base.
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
  translate([0, depth/2, height/2]) cube([width, depth, height], center=true);
}

// Use the lesser taper to ensure clearance (closest to 1.0)
function get_minimal_taper(bottom_depth, bottom_width, top_depth, top_width) = (top_width / bottom_width) > (top_depth / bottom_depth) ? top_width / bottom_width : top_depth / bottom_depth;

module basic_base(depth, width, height, wall_thickness, taper) {
  linear_extrude(height, scale=taper) difference() {
    scale([1,depth/width,1]) circle(d=width+2*wall_thickness);
    scale([1,depth/width,1]) circle(d=width);
  }
}

module tube_spire_transition(bottom_diameter, top_diameter, height, wall_thickness) {
  difference() {
    cylinder(h=height, r1=bottom_diameter/2+wall_thickness, r2=top_diameter/2+wall_thickness);
    cylinder(h=height, r1=bottom_diameter/2, r2=top_diameter/2);
  }
}

module spire_cap(diameter, height, wall_thickness) {
  difference() {
    color("blue", 0.5) cylinder(h=height, r1=diameter/2+wall_thickness, r2=diameter/20+wall_thickness);
    cylinder(h=height, r1=diameter/2, r2=wall_thickness);
  }
}

