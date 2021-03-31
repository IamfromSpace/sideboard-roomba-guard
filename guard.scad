module guard(
  length,
  max_length,
  thickness,
  explode,
) {
  effective_explode = explode == undef ? thickness * 0.6 : explode;
  segment_count = ceil(length / max_length);
  segment_length = length / segment_count - $tolerance * (segment_count - 1);
  module segment(args) guard_segment(segment_length, thickness, args[0], args[1], args[2]);

  for (i = [0:segment_count-1]) {
    is_male = i % 2 == 0;
    args = [is_male ? MALE : FEMALE, i != 0, i != segment_count - 1];

    translate([i*(segment_length + $tolerance), 0, 0])
      if (is_male) {
        translate([0, 0, -effective_explode])
          segment(args);
      } else {
        translate([0, 0, thickness + effective_explode])
          mirror([0, 0, 1])
            segment(args);
      }
  }
}

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
          cube([thickness + $tolerance/2, thickness/3 + $tolerance/2, 2*thickness/3 + $tolerance/2]);
      if (include_right_joint)
        translate([length - thickness - $tolerance/2, thickness/3 - $tolerance/4, thickness/3 - $tolerance/2])
          cube([thickness + $tolerance/2, thickness/3 + $tolerance/2, 2*thickness/3 + $tolerance/2]);
    }
  }
  if (type == MALE) {
    if (include_left_joint)
      translate([-thickness + $tolerance/2, thickness/3 + $tolerance/4, 0])
        cube([thickness - $tolerance/2, thickness/3 - $tolerance/2, 2*thickness/3 - $tolerance/2]);
    if (include_right_joint)
      translate([length, thickness/3 + $tolerance/4, 0])
        cube([thickness - $tolerance/2, thickness/3 - $tolerance/2, 2*thickness/3 - $tolerance/2]);
  }
}

guard(299, 50, 10, $tolerance = 0.6);
