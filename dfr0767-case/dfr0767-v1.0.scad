// See https://image.dfrobot.com/image/data/DFR0767/[DFR0767]V1.0_Dimension.jpg
// as referenced in https://www.dfrobot.com/product-2242.html .
// Oriented with RJ45s facing the front and on the bottom side of the case.
// All measurements are in mm.

// Interior dimensions.
case_width = 55.00;
case_height = 30.00; // Does not include the heat sink which sticks out the top.
case_depth = 61.50;

wall_thickness = 2.00; // YMMV.
pcb_tolerance = 0.50; // Extra space around the edges of the PCB.

bolt_support_hole_diameter = 2.55;
bolt_support_height = 15; // Need to account for bolts and washers on the bottom.
bolt_support_wall_thickness = 2;
bolt_support_pcb_far_offset = 3.50;
bolt_support_pcb_left_offset = 3.50;
bolt_support_x_distance = 48.00; // x distance between the sets of supports.
bolt_support_y_distance = 33.00; // y distance between the sets of supports.

interior_width = case_width+pcb_tolerance;
interior_depth = case_depth+pcb_tolerance;
interior_height = case_height+pcb_tolerance;

bolt_support_x_center_offset = bolt_support_x_distance/2; // x distance between the center and the bolt_support.
bolt_support_far_y_center_offset = interior_depth/2-bolt_support_pcb_far_offset; // y distance between the center and the far bolt_support.

echo(bolt_support_x_center_offset);
echo(bolt_support_far_y_center_offset);

color("blue", 0.5)
  case_bottom(interior_width, interior_depth, interior_height, wall_thickness);

color("green", 0.5)
  translate([-bolt_support_x_center_offset, bolt_support_far_y_center_offset, 0]) // Far left.
    bolt_support(bolt_support_height, bolt_support_hole_diameter, bolt_support_wall_thickness);

color("green", 0.5)
  translate([bolt_support_x_center_offset, bolt_support_far_y_center_offset, 0]) // Far right.
    bolt_support(bolt_support_height, bolt_support_hole_diameter, bolt_support_wall_thickness);

color("green", 0.5)
  translate([-bolt_support_x_center_offset, bolt_support_far_y_center_offset-bolt_support_y_distance, 0]) // Near left.
    bolt_support(bolt_support_height, bolt_support_hole_diameter, bolt_support_wall_thickness);

color("green", 0.5)
  translate([bolt_support_x_center_offset, bolt_support_far_y_center_offset-bolt_support_y_distance, 0]) // Near right.
    bolt_support(bolt_support_height, bolt_support_hole_diameter, bolt_support_wall_thickness);

module case_bottom(width, depth, height, wall_thickness) {
  translate([0, 0, (height+wall_thickness)/2])
  difference() {
    cube([width+wall_thickness*2, depth+wall_thickness*2, height+wall_thickness], center=true);

    translate([0, 0, wall_thickness/2])
      cube([width, depth, height], center=true);
  }
}

module bolt_support(height, diameter, wall_thickness) {
  translate([0, 0, height/2])
  difference() {
    cylinder(h=height, d=diameter+wall_thickness, center=true);
    translate([0, 0, wall_thickness/2])
      cylinder(h=height-wall_thickness, d=diameter, center=true);
  }
}





