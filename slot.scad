#include <BOSL2/std.scad>

$fa = 1;
$fs = $preview ? 0.5 : 0.2;

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

module slot_hole(h=5, r=2.5, l=10, snap=false, snap_x=false, snap_s=2, chamfered=false, tolerance=0, rot=180, cutout=false, cutout_t=0.5, base) {
  difference() {
    union() {
      hull() {
        translate([0,-(l)/2,0]) cylinder(h=h+tolerance, r=r+tolerance, center=true);
        translate([0,l/2,0]) cylinder(h=h+tolerance, r=r+tolerance, center=true);
      }

      if (snap) {
        if (!snap_x) {
          for (i=[0:1]) {
            intersection() {
              translate([0,l/2-i*l,0]) rotate_extrude(rot, (180-rot)/2 + 180*i) translate([r,0,0]) tri(snap_s+(2*tolerance));
              if (chamfered) {
                translate([0,l-(i*2*l),0]) rotate([90-180*i,0,0]) chamfer(ss=(r+tolerance)*2, l=l*1.2);
              }
            }
          }
        } else {
          for (i=[0:1]) {
            intersection() {
              rotate([0,0,180*i]) translate([r,(l*0.4)/2,0]) rotate([90,0,0]) linear_extrude(l*0.4) tri(snap_s+(2*tolerance));
              if (chamfered) {
                translate([0,0,0]) rotate([0,90,i*180]) chamfer(ss=(r+tolerance)*2, l=r*2);
              }
            }
          }
        }
      }
    }

    if (cutout) {
      hull() {
        translate([0,-(l)/2,0]) cylinder(h=h+tolerance+1, r=r+tolerance-cutout_t, center=true);
        translate([0,l/2,0]) cylinder(h=h+tolerance+1, r=r+tolerance-cutout_t, center=true);
      }

      translate([0,l/2-cutout_t*2,0]) cube([r*2+1, cutout_t*2, h+tolerance+1], center=true);
      translate([0,-l/2+cutout_t*2,0]) cube([r*2+1, cutout_t*2, h+tolerance+1], center=true);
    }
  }

  if (base) {
    translate([0,0,-h/2-0.5]) hull() {
      translate([0,-(l)/2,0]) cylinder(h=1, r=r+tolerance, center=true);
      translate([0,l/2,0]) cylinder(h=1, r=r+tolerance, center=true);
    }
  }
}

difference() {
  union() {
    difference() {
      slot_hole(h=5, r=5, l=10, snap_x=true);
      slot_hole(h=5, r=2.5, l=10, snap=true, snap_s=2, chamfered=false, tolerance=0.1, snap_x=true);
    }

    translate([10,0,0]) slot_hole(h=5, r=2.5, l=10, snap=true, snap_s=2, snap_x=true, chamfered=true, rot=170, cutout=true, base=true);
  }

  // translate([10,0,0]) cube(20, center=true);
  // translate([0,10,0]) cube(20, center=true);
}
