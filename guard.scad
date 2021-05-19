ASSEMBLED = "ASSEMBLED";
PRINT_READY = "PRINT_READY";

module guard(
  length,
  max_length,
  thickness,
  nub_depth,
  nub_radius,
  explode,
  layout = ASSEMBLED,
) {
  effective_explode = explode == undef ? thickness * 0.6 : explode;
  // We always need an odd number of segments, to ensure that the nub will be
  // printed flat against the bed, but not be flipped over (since male/female
  // pieces alternate).
  segment_count_raw = ceil(length / max_length);
  is_raw_count_odd = segment_count_raw % 2 == 0;
  segment_count = segment_count_raw + (is_raw_count_odd ? 1 : 0);
  segment_length = length / segment_count - $tolerance * (segment_count - 1);
  spacing = 5;

  module nub () {
    translate([0,(-nub_radius/sqrt(2)+thickness)/2,0])
      cube([nub_depth, nub_radius/sqrt(2), nub_radius/sqrt(2)/2]);
  }

  module segment(i) {
    is_male = i % 2 == 0;
    guard_segment(segment_length, thickness, is_male ? MALE : FEMALE, i != 0, i != segment_count - 1);
    if (i == 0)
      mirror([1,0,0])
        nub();

    if (i == segment_count - 1)
      translate([segment_length, 0, 0])
        nub();
  }

  for (i = [0:segment_count-1]) {
    is_male = i % 2 == 0;
    if (layout == ASSEMBLED)
      translate([i*(segment_length + $tolerance), 0, 0])
        if (is_male) {
          translate([0, 0, -effective_explode])
            segment(i);
        } else {
          translate([0, 0, thickness + effective_explode])
            mirror([0, 0, 1])
              segment(i);
        }

    if (layout == PRINT_READY)
      translate([0, i*(thickness + spacing)])
        segment(i);
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

guard(599.66, 50, 10, 3.3, 15, $tolerance = 0.6);
