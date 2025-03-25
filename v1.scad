include <BOSL2/std.scad>
$fa = 1;
$fs = $preview?1:0.1;

w=200; d=200; h=5;
slot_r=2.5; slot_l=10;
sx=20; sy=20;

module linear_pattern(axis=[1,0,0], spacing=10, count=2) {
  for (i = [0:count-1]) {
    translate(axis*spacing*i) children();
  }
}

module slot(l=10, r=2.5, h=5, fillet=false, fillet_r=1) {
  translate([0,0,h/2]) union() {
    hull() {
      translate([-l/2,0,0]) cyl(h+2, r=r);
      translate([l/2,0,0]) cyl(h+2, r=r);
    }
    
    if (fillet) {
      // Fillet Top
      {
        translate([-l/2,0,h/2]) rotate_extrude() translate([-r,0,0]) difference() {
          translate([-fillet_r,-fillet_r,0]) square(2*fillet_r);
          translate([-fillet_r,-fillet_r,0]) circle(r=fillet_r);
        }
        
        translate([l/2,0,h/2]) rotate_extrude() translate([-r,0,0]) difference() {
          translate([-fillet_r,-fillet_r,0]) square(2*fillet_r);
          translate([-fillet_r,-fillet_r,0]) circle(r=fillet_r);
        }
        
        translate([l/2,-r,h/2]) rotate([0,-90,0]) linear_extrude(l) difference() {
          translate([-fillet_r,-fillet_r,0]) square(2*fillet_r);
          translate([-fillet_r,-fillet_r,0]) circle(r=fillet_r);
        }
        
        translate([-l/2,r,h/2]) rotate([0,-90,180]) linear_extrude(l) difference() {
          translate([-fillet_r,-fillet_r,0]) square(2*fillet_r);
          translate([-fillet_r,-fillet_r,0]) circle(r=fillet_r);
        }
      }
      
      // Fillet Bottom
      rotate([180,0,0]) {
        translate([-l/2,0,h/2]) rotate_extrude() translate([-r,0,0]) difference() {
          translate([-fillet_r,-fillet_r,0]) square(2*fillet_r);
          translate([-fillet_r,-fillet_r,0]) circle(r=fillet_r);
        }
        
        translate([l/2,0,h/2]) rotate_extrude() translate([-r,0,0]) difference() {
          translate([-fillet_r,-fillet_r,0]) square(2*fillet_r);
          translate([-fillet_r,-fillet_r,0]) circle(r=fillet_r);
        }
        
        translate([l/2,-r,h/2]) rotate([0,-90,0]) linear_extrude(l) difference() {
          translate([-fillet_r,-fillet_r,0]) square(2*fillet_r);
          translate([-fillet_r,-fillet_r,0]) circle(r=fillet_r);
        }
        
        translate([-l/2,r,h/2]) rotate([0,-90,180]) linear_extrude(l) difference() {
          translate([-fillet_r,-fillet_r,0]) square(2*fillet_r);
          translate([-fillet_r,-fillet_r,0]) circle(r=fillet_r);
        }
      }
    }
  }
}

module board(w=200,d=200,h=5,slot_r=2.5,slot_l=10,sx=20,sy=20) {
  difference() {
    linear_extrude(h) rect([w, d], rounding=8);
    echo(floor(3/2));
    x_n = (w/(sx*2));
    y_n = (d/(sx*2));
    t_n = (x_n*y_n) + ((x_n-1)*(y_n-1));
    echo(x_n, y_n, t_n);
    
    for (i = [0:t_n-1]) {
      idx = i % (x_n+(x_n-1));
      row = floor(i/((x_n+(x_n-1))/2));
      is_even = row%2 == 0;
      col = idx - x_n*(is_even?0:1);
      // echo(row, col);
      x_o = 2*sx*col + (is_even ? 0 : sx);
      y_o = -sy * row;
      translate([-w/2+sx+x_o,d/2-sy+y_o,0]) rotate([0,0,90]) slot(r=slot_r, l=slot_l, h=h, fillet=$preview?false:true);
    }
    
    translate([-w/2+(sx-slot_r)/2,-d/2+(sx-slot_r)/2,0]) joint(r=4, cut=true, clearance=0.2);
    translate([-w/2+(sx-slot_r)/2,d/2-(sx-slot_r)/2,0]) joint(r=4, cut=true, clearance=0.2);
    translate([w/2-(sx-slot_r)/2,-d/2+(sx-slot_r)/2,0]) joint(r=4, cut=true, clearance=0.2);
    translate([w/2-(sx-slot_r)/2,d/2-(sx-slot_r)/2,0]) joint(r=4, cut=true, clearance=0.2);
  }
}

module joint(r=10, l=5, t=0.3, th=0.4, clearance=0, cut=false, ratio=0.7) {
  union() {
    translate([0,0,-(cut?1:0)]) linear_extrude((l)*ratio+(cut?1:0)) circle(r+clearance);
    translate([0,0,(l)*ratio]) linear_extrude(th) circle(r+t+clearance);
    translate([0,0,(l)*ratio]) hull() {
      linear_extrude((l)*(1-ratio)) circle((r*(cut?1:0.85))+clearance);
      linear_extrude(th) circle(r+clearance);
    }
    if (cut) {
      translate([0,0,(l)]) linear_extrude(1) circle((r*(cut?1:0.8))+clearance);
    }
  }
}


module joiner(r=4, gap=20, expansion=1.5, bt=1) {
  joint(r=r, t=0.3, th=0.4);
  translate([gap,0,0]) joint(r=r, t=0.3, th=0.4);
  
  hull() {
    translate([0,0,-bt]) cylinder(bt, r=r*expansion);
    translate([gap,0,-bt]) cylinder(bt, r=r*expansion);
  }
}

*joiner(gap=(sx-slot_r));

*translate([40,0,0]) difference() {
  hull() {
    cylinder(5, r=8);
    translate([(sx-slot_r),0,0]) cylinder(5, r=8);
  }

  joint(r=4, cut=true, clearance=0.2, t=0.3, th=0.4);
  translate([(sx-slot_r),0,0]) joint(r=4, cut=true, clearance=0.2, t=0.3, th=0.4);
}


board();