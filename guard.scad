MALE = "MALE";
FEMALE = "FEMALE";

module guard_segment(
  length, // How long the part should be _excluding_ any male connections
  thickness,
  type, // MALE or FEMALE
  include_left_joint,
  include_right_joint,
) {
  difference() {
    cube([length, thickness, thickness]);
    if (type == FEMALE) {
      if (include_left_joint)
        translate([0, thickness/3 - $tolerance/4, thickness/3 - $tolerance/2])
          cube([thickness, thickness/3 + $tolerance/2, 2*thickness/3 + $tolerance/2]);
      if (include_right_joint)
        translate([length-thickness, thickness/3 - $tolerance/4, thickness/3 - $tolerance/2])
          cube([thickness, thickness/3 + $tolerance/2, 2*thickness/3 + $tolerance/2]);
    }
  }
  if (type == MALE) {
    if (include_left_joint)
      translate([-thickness, thickness/3 + $tolerance/4, 0])
        cube([thickness, thickness/3 - $tolerance/2, 2*thickness/3 - $tolerance/2]);
    if (include_right_joint)
      translate([length, thickness/3 + $tolerance/4, 0])
        cube([thickness, thickness/3 - $tolerance/2, 2*thickness/3 - $tolerance/2]);
  }
}

guard_segment(50, 10, MALE, true, true, $tolerance = 0.6);
