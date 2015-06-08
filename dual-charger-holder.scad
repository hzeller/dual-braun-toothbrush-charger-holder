$fn=128;
epsilon=0.05;
slack=0.5;
wall_thick=0.6;
mink_fn=8;
plug_roundness=4;
plug_width=32 - 2*plug_roundness;
super_param=2.1;   // super-ellipse parameter
plug_height=9.5;

module rounded_cube(p=[1,1,1], r=0.2) {
    hull() {
	translate([0,   0]) cylinder(r=r, h=p[2]);
	translate([p[0], 0]) cylinder(r=r, h=p[2]);
	translate([p[0], p[1]]) cylinder(r=r, h=p[2]);
	translate([0, p[1]]) cylinder(r=r, h=p[2]);
    }
}

function superellipse_quadrant(a=1, b=1, n=2, steps=120) =
    [ for (i=[0:(steps/4)]) [ a * pow(cos(i/steps * 360), 2/n), b * pow(sin(i/steps * 360), 2/n)] ];

// Looks like the shape is a slight super-ellipse
// http://en.wikipedia.org/wiki/Superellipse
module superellipse2(a=1, b=1, n=2, steps=120) {
    points = concat(superellipse_quadrant(a, b, n, steps),
	            superellipse_quadrant(-a, b, n, steps),
	            superellipse_quadrant(-a, -b, n, steps),
	            superellipse_quadrant(a, -b, n, steps));
    polygon(points);
}

module charger(cable_extra=0,outer_shape=false) {
    o=1;  // fudging...
    hull() {
      translate([0,0,24]) linear_extrude(height=0.1) superellipse2(a=41/2, b=54.5/2, n=super_param);  // top
      translate([0,0,14]) linear_extrude(height=0.1) superellipse2(a=47/2, b=60/2, n=super_param);
      translate([0,0,4.2]) linear_extrude(height=0.1) superellipse2(a=48/2, b=62/2, n=super_param);
      translate([0,0,0])  linear_extrude(height=0.1) superellipse2(a=48/2, b=62/2, n=super_param);  // bottom
  }
  translate([-plug_width/2,19-plug_roundness,0]) rounded_cube([plug_width,15,plug_height], r=plug_roundness);

  hull() {
      translate([0,0,4.5]) rotate([-90,0,0]) cylinder(r=3,h=34+cable_extra);
      if (outer_shape) {
          translate([0,0,plug_height-6-wall_thick]) rotate([-90,0,0]) cylinder(r=6,h=34);
	  translate([-12/2,0,0]) cube([12,34,2]);
      }
      translate([-6/2,0,0]) cube([6,34+cable_extra,4.5]);
  }
}

module square() {
difference() {
  translate([0,-30,0]) cube([24,65,24]);
  translate([0,0,-epsilon]) charger();
 }
}

module xray() {
    intersection() {
	difference() {
	    minkowski() { cylinder(r=wall_thick, $fn=8); charger(); }
	    charger();
	}
	translate([0,-30,0]) cube([24,65,24]);
    }
}

module outer_hull(cable_extra=0,outer_shape=false) {
    union() {
	hull() minkowski() {   // soft shape around charger.
	    sphere(r=wall_thick, $fn=mink_fn);
	    charger();
	}
	minkowski() {   // same thing again, but with cable poking out.
	    sphere(r=wall_thick, $fn=mink_fn);
	    charger(cable_extra=cable_extra,outer_shape=outer_shape);
	}
	//	    translate([0,0,1]) cube([50,50,2], center=true);
	hull() {
	    translate([0,0,4.2]) linear_extrude(height=0.1) superellipse2(a=46/2, b=59/2, n=super_param);
	    translate([0,0,0])  linear_extrude(height=0.1) superellipse2(a=47/2, b=60/2, n=super_param);  // bottom
	}
    }
}

module print(cable_extra=5, distance=49) {
    difference() {
	union() {
	    hull() {
		outer_hull();
		translate([distance,0,0]) outer_hull();
	    }
	    /// Just to get the cable extra. That should probably be
	    outer_hull(cable_extra=cable_extra, outer_shape=true);
	    translate([distance,0,0]) outer_hull(cable_extra=cable_extra, outer_shape=true);
	}
	charger(cable_extra=cable_extra+1);
	translate([distance,0,0]) charger(cable_extra=cable_extra+1);

	translate([0,0,-15+epsilon]) cube([200,200,30], center=true);
	translate([0,0,24+1.5]) cube([200,200,3], center=true);
    }
}

rotate([180,0,0]) print();
//charger(cable_extra=5);
