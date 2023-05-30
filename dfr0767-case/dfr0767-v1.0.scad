// See https://image.dfrobot.com/image/data/DFR0767/[DFR0767]V1.0_Dimension.jpg
// as referenced in https://www.dfrobot.com/product-2242.html .
// Oriented with RJ45s facing the front and on the bottom side of the case.
// All measurements are in mm.

// Interior dimensions.
case_width = 55.00;
case_height = 30.00; // Does not include the heat sink which sticks out the top.
case_depth = 61.50;

wall_thickness = 2.00; // YMMV.
punch_out_width = 0.25; // Cutouts used for support to be punched out after printing. Set to zero if printed with supports.
pcb_tolerance = 2.00; // Extra space around the edges of the PCB.
pcb_height = 18.00; // Height above the bottom of the case.

bolt_support_hole_diameter = 3.5; // M2.5 slides in okay.
bolt_support_height_offset = 3.00; // Account for bolts and washers on the bottom of the PCB.
bolt_support_wall_thickness = 2.00;
bolt_support_pcb_far_offset = 3.50;
bolt_support_pcb_left_offset = 3.50;
bolt_support_x_distance = 48.00; // x distance between the sets of supports.
bolt_support_y_distance = 33.00; // y distance between the sets of supports.

rj45_cutout_height = 16.00;
rj45_cutout_width = 32.00;

power_cutout_width = 12.00;
power_cutout_height = 4.00;
power_cutout_x_offset = 5.00;

gpio_cutout_width = 34.00;
gpio_cutout_depth = 6.00;

usb_cutout_height = 3.50;
usb_cutout_width = 20.00;

sdcard_cutout_height = 5.00;
sdcard_cutout_width = 25.00;

fan_wires_track_width = 5;
fan_wires_track_height = 10;

mount_support_width = 16.00;
mount_support_hole_diameter = 4.00;



interior_width = case_width+pcb_tolerance;
interior_depth = case_depth+pcb_tolerance;
interior_height = case_height;

bolt_support_height = pcb_height - bolt_support_height_offset;
bolt_support_x_center_offset = bolt_support_x_distance/2; // x distance between the center and the bolt_support.
bolt_support_far_y_center_offset = interior_depth/2-bolt_support_pcb_far_offset; // y distance between the center and the far bolt_support.

color("blue", 0.5)
union() {
  // case_bottom w/ cutouts
  difference() {
    case_bottom(interior_width, interior_depth, interior_height, wall_thickness);
    
    // RJ45 cutout
    translate([-interior_width/2, -wall_thickness-interior_depth/2 , pcb_height-rj45_cutout_height])
      difference() {
        cube([rj45_cutout_width, wall_thickness, rj45_cutout_height]);
        translate([0, (wall_thickness-punch_out_width)/2, 0])
          cube([rj45_cutout_width, punch_out_width, rj45_cutout_height]);
      }
    
    // Power cutout
    translate([interior_width/2 - power_cutout_width - power_cutout_x_offset, -(interior_depth/2+wall_thickness-punch_out_width*0), pcb_height-power_cutout_height])
      difference() {
        cube([power_cutout_width, wall_thickness, power_cutout_height]);
        translate([0, (wall_thickness-punch_out_width)/2, 0])
          cube([power_cutout_width, punch_out_width, power_cutout_height]);
      }

    // USB/reset cutout
    translate([interior_width/2, -interior_depth/2, pcb_height-usb_cutout_height])
      difference() {
        cube([wall_thickness, usb_cutout_width, usb_cutout_height]);
        translate([(wall_thickness-punch_out_width)/2, 0, 0])
          cube([punch_out_width, usb_cutout_width, usb_cutout_height]);
      }

    // SDCard / Power Light cutout
    translate([-interior_width/2-wall_thickness, 0, pcb_height-sdcard_cutout_height])
      difference() {
        cube([wall_thickness, sdcard_cutout_width, sdcard_cutout_height]);
        translate([(wall_thickness-punch_out_width)/2, 0, 0])
          cube([punch_out_width, sdcard_cutout_width, sdcard_cutout_height]);
      }

    // GPIO cutout
    translate([-gpio_cutout_width/2, interior_depth/2-gpio_cutout_depth, 0])
      cube([gpio_cutout_width, gpio_cutout_depth, wall_thickness]);

    // Fan wires track
    translate([-fan_wires_track_width/2, interior_depth/2, pcb_height/2])
      cube([fan_wires_track_width, wall_thickness/2, fan_wires_track_height]);
  }


  // Far left bolt support.
  translate([-bolt_support_x_center_offset, bolt_support_far_y_center_offset, 0])
    bolt_support(bolt_support_height, bolt_support_hole_diameter, bolt_support_wall_thickness);

  // Far right bolt support.
  translate([bolt_support_x_center_offset, bolt_support_far_y_center_offset, 0])
    bolt_support(bolt_support_height, bolt_support_hole_diameter, bolt_support_wall_thickness);

  // Near left bolt support.
  translate([-bolt_support_x_center_offset, bolt_support_far_y_center_offset-bolt_support_y_distance, 0])
    bolt_support(bolt_support_height, bolt_support_hole_diameter, bolt_support_wall_thickness);

  // Near right bolt support.
  translate([bolt_support_x_center_offset, bolt_support_far_y_center_offset-bolt_support_y_distance, 0])
    bolt_support(bolt_support_height, bolt_support_hole_diameter, bolt_support_wall_thickness);
  
  // Left mount support.
  translate([-(interior_width/2+wall_thickness), 0, 0])
    mount_support(mount_support_width, wall_thickness, mount_support_hole_diameter);

  // Right mount support.
  translate([interior_width/2+wall_thickness, 0, 0])
    rotate([0, 0, 180])
      mount_support(mount_support_width, wall_thickness, mount_support_hole_diameter);
}
  




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
    cylinder(h=height, d1=diameter+4*wall_thickness, d2=diameter+wall_thickness, center=true);
    translate([0, 0, wall_thickness/2])
      cylinder(h=height-wall_thickness, d=diameter, center=true);
  }
}

module mount_support(width, thickness, hole_diameter) {
  difference() {
    cylinder(h=thickness, r=width);
    translate([0, -width, 0])
      cube([width, width*2, thickness]);
    translate([-width/2, 0, 0])
      cylinder(h=thickness, d=hole_diameter);
  }
}


