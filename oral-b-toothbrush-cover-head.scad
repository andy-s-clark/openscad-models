wall_thickness = 2;

width = 12;
depth = 22;
height = 65;
arc_round_ratio = 0.3;

union() {
  translate([0, 0, wall_thickness]) half_rounded_cube(width, depth, height, arc_round_ratio, wall_thickness);
  color("green", 0.5) drain_end(width, depth, arc_round_ratio, wall_thickness);
}

module half_rounded_cube(width, depth, height, round_ratio, wall_thickness) {
  linear_extrude(height) hollow_rounded_half_box(width, depth, round_ratio, wall_thickness);
}

module hollow_rounded_half_box(width, depth, round_ratio, wall_thickness) {
  difference() {
    rounded_half_box(width+2*wall_thickness, depth+2*wall_thickness, round_ratio);
    translate([0, wall_thickness, 0]) rounded_half_box(width, depth, round_ratio);
  }
}

module drain_end(width, depth, round_ratio, wall_thickness) {
  linear_extrude(wall_thickness) union() {
    hollow_rounded_half_box(width, depth, round_ratio, wall_thickness);
    translate([-1*wall_thickness, wall_thickness/2, 0]) square([wall_thickness*2, depth+wall_thickness]);
    translate([(width+wall_thickness)/-2, depth/2, 0]) square([width+wall_thickness, wall_thickness*2]);
  }
}

module rounded_half_box(width, depth, round_ratio) {
  arc_depth = round_ratio * depth;
  union() {
    translate([0, depth-arc_depth, 0]) difference() {
      scale([1, 2*arc_depth/width, 1]) circle(d=width);
      translate([width/-2, -1*arc_depth, 0]) square([width, arc_depth]);
    }
    translate([width/-2, 0, 0]) square([width, depth-arc_depth]);
  }
}

