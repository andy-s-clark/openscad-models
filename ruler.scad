length=100;
width=15;
base_height=1.5;
rule_width=0.25;
rule_length=6;
rule_height=0.5;
rule_tick_length=3;

union() {
  base();
  translate([0,0,base_height]) rule();
  for(i=[1:length/10]) {
    translate([0, (i-1)*10, base_height]) cm_rule_block(i);
  }
}

module rule() {
  cube([rule_length, rule_width, rule_height]);
}

module rule_tick() {
  cube([rule_tick_length, rule_width, rule_height]);
}

module base() {
  cube([10, length+rule_width, base_height]);
}

module cm_rule_block(cm_count) {
  translate([rule_tick_length, 9, 0]) linear_extrude(height=rule_height) text(str(cm_count), size=4, font="DejaVu Sans", halign="left", valign="top");
  for(i=[1:9]) {
    translate([0, i, 0]) rule_tick();
  }
  translate([0, 10, 0]) rule();
}