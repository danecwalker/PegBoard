#include <BOSL2/std.scad>

$fa = 1;
$fs = $preview ? 0.5 : 0.1;

module tri(s=2) {
  polygon([
    [-1,s/2],
    [0,s/2],
    [tan(45)*s/2,0],
    [0,-s/2],
    [-1,-s/2]
  ]);
}

module chamfer(ss=10, l=10) {
  hull() {
    cube([ss,ss,1], center=true);
    translate([0,0,l]) cube(1, center=true);
  }
}

module slot_hole(h=5, r=2.5, l=10, snap=false, snap_s=2, chamfered=false, shrink=0) {
  scale([1,1,1]*(1+shrink)) union() {
    hull() {
      translate([0,-l/2,0]) cylinder(h=h, r=r, center=true);
      translate([0,l/2,0]) cylinder(h=h, r=r, center=true);
    }

    if (snap) {
      for (i=[0:1]) {
        intersection() {
          translate([0,l/2-i*l,0]) rotate_extrude(180, i*180) translate([r,0,0]) tri(snap_s);
          if (chamfered) {
            translate([0,l-(i*2*l),0]) rotate([90-180*i,0,0]) chamfer(ss=r*3, l=l*1.2);
          }
        }
      }
    }
  }
}

difference() {
  union() {
    difference() {
      slot_hole(h=5, r=5, l=10);
      slot_hole(h=6, r=2.5, l=10, snap=true, snap_s=2, shrink=0.02);
    }

    slot_hole(h=5, r=2.5, l=10, snap=true, snap_s=2, chamfered=true);
  }

  // translate([10,0,0]) cube(20, center=true);
}
