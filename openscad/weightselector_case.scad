$fn=90;

cutout_wdh = [27,55,28];
sensorbase_d = 15;
bme680_funnel_wd = [18,25];
bme680_pcb_w = 4;
bme680_pcb_indent = 10;
bme680_pcb_throughhole_wh = [6,6];

pcb_holder_height = 11;

ccs811_pcb_throughhole_whd = [22,8,10];
wall_w = 1.0;

tape_strip_w = 9;

corner_r = 3;

bme680_y_offset = cutout_wdh[1]+sensorbase_d-corner_r-bme680_pcb_w;
ccs811_y_offset = cutout_wdh[1]+sensorbase_d-corner_r-30;

difference()
{
  translate([corner_r,corner_r,0])
  {
  difference()
  {
    minkowski()
    {
      cube([
        cutout_wdh[0]+2*wall_w-corner_r,
        cutout_wdh[1]+sensorbase_d+2*wall_w-corner_r,
        cutout_wdh[2]
        ]);
      //cylinder(r=corner_r,h=1);
      sphere(r=corner_r);
    }
    translate([-500,-500,-1000])
      cube([1000,1000,1000]);
  }
  }

  translate([wall_w+corner_r/2,wall_w+corner_r/2,-2*wall_w])
  {
    difference()
    {
      cube([cutout_wdh[0],cutout_wdh[1]+sensorbase_d,cutout_wdh[2]+corner_r]);
      for (yoff=[
          tape_strip_w,
          //cutout_wdh[1]/2+tape_strip_w,
          //ccs811_y_offset-0.5*ccs811_pcb_throughhole_whd[1],
          cutout_wdh[1]+sensorbase_d-2.5*bme680_pcb_throughhole_wh[1],
          ])
        translate([0,yoff-tape_strip_w,0])
          cube([cutout_wdh[0],tape_strip_w,3*wall_w]);
    }
  }


  translate([
    cutout_wdh[0]/2+wall_w+corner_r/2,
    cutout_wdh[1]+sensorbase_d-10,
    cutout_wdh[2]-ccs811_pcb_throughhole_whd[2]]) {
    rotate([0,0,90])
    translate([-1.3,-12,0])
      cube([2.6,5,30]);
    cylinder(r=10,h=30);
  }

  translate([
    wall_w+corner_r/2+cutout_wdh[0]/2,
    wall_w+corner_r/2+wall_w,
    cutout_wdh[2]-5])
    rotate([90,0,0])
      cylinder(r=5,h=corner_r+2*wall_w);
}

