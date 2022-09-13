wall_thickness = 2;

width = 12;
depth = 22;
height = 65;
arc_round_ratio = 0.3;

union() {
  color("red", 0.3) difference() {
    translate([0, 0, wall_thickness]) half_rounded_box(width, depth, height, arc_round_ratio, wall_thickness);
    half_rounded_box_air_holes(width+2*wall_thickness, depth, height, wall_thickness);
  }

  color("green", 0.5) drain_end(width, depth, arc_round_ratio, wall_thickness);
}

module half_rounded_box(width, depth, height, round_ratio, wall_thickness) {
  linear_extrude(height) hollow_rounded_half_rectangle(width, depth, round_ratio, wall_thickness);
}

module hollow_rounded_half_rectangle(width, depth, round_ratio, wall_thickness) {
  difference() {
    rounded_half_rectangle(width+2*wall_thickness, depth+2*wall_thickness, round_ratio);
    translate([0, wall_thickness, 0]) rounded_half_rectangle(width, depth, round_ratio);
  }
}

module drain_end(width, depth, round_ratio, wall_thickness) {
  linear_extrude(wall_thickness) union() {
    hollow_rounded_half_rectangle(width, depth, round_ratio, wall_thickness);
    translate([-1*wall_thickness, wall_thickness/2, 0]) square([wall_thickness*2, depth+wall_thickness]);
    translate([(width+wall_thickness)/-2, depth/2, 0]) square([width+wall_thickness, wall_thickness*2]);
  }
}

module rounded_half_rectangle(width, depth, round_ratio) {
  arc_depth = round_ratio * depth;
  union() {
    translate([0, depth-arc_depth, 0]) difference() {
      scale([1, 2*arc_depth/width, 1]) circle(d=width);
      translate([width/-2, -1*arc_depth, 0]) square([width, arc_depth]);
    }
    translate([width/-2, 0, 0]) square([width, depth-arc_depth]);
  }
}

module half_rounded_box_air_holes(width, depth, height, hole_diameter) {
  for(i=[1:floor(height/hole_diameter/2)]) {
    translate([0, 0, 2*i*hole_diameter]) for(j=[1:floor(depth/hole_diameter/2)]) {
      translate([0, 2*j*hole_diameter, 0]) rotate([0, 90, 0]) cylinder(h=width, r=hole_diameter/2, center=true);
    }
    translate([0, depth/2+2*hole_diameter, 2*i*hole_diameter]) rotate([90, 0, 0]) cylinder(h=depth, r=hole_diameter/2, center=true);
  }
}
