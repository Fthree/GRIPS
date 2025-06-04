
// Author: https://makerworld.com/en/@TooManyThings
// Link: https://makerworld.com/en/models/704997
// Copyright (c) 2024-2025. All rights reserved.

// Enter measured size in mm, or, number of Gridfinity units x 42.
Width = 325;

// Enter measured size in mm, or, number of Gridfinity units x 42.
Depth = 275;

// Suggest 2mm where measurements don't already allow for clearance.
Clearance = 0;

Build_Plate_Size=238; //[180: Small (A1 Mini), 238: Standard (X1/P1/A1), 320: Large (H2D)]

/* [Options] */

Interlock_Type= 1; // [0: None (Butt-Together Baseplate), 1: Standard GRIPS Tab, 2: Extra Clearance GRIPS Tab (Looser Fit), 3: M3 Screw and Nut]

// Include a half-width grid in the margin(s) if there is sufficient space.
Half_Sized_Filler = true;

// In mm. For drawers with rounded bottom edges.
Bottom_Edge_Chamfer = 0;

// In mm.
Solid_Base_Thickness = 0;

/* [Magnet Options] */

// Enable for magnet related features.
Magnets = false;

// In mm. Can be 0.
Magnet_Hole_Diameter = 6.5;

// In mm. Can be 0.
Magnet_Hole_Depth = 2.4;

// In mm. Can be 0.
Minimum_Under_Magnet_Thickness = 0.6;

// In mm. Can be 0.
Under_Magnet_Hole_Diameter = 3.2;

// In mm. Can be 0.
Filament_Lock_Hole_Diameter = 1.75;

/* [Advanced] */

Horizontal_Alignment = 0; // [-10000: Left, 0: Center, 10000: Right]
Depth_Alignment = 0; // [10000: Front, 0: Center, -10000: Back]

Minimum_Left_Margin = 0;
Minimum_Right_Margin = 0;
Minimum_Front_Margin = 0;
Minimum_Back_Margin = 0;

// Mirrors the baseplate left-to-right.
Mirror_Horizontally = false;

// Mirrors the baseplate front-to-back.
Mirror_Vertically = false;

// Hollows out large margins where it may give a small filament saving.
Margin_Skeletonization = 0; // [0: None (Solid), 1: Simple, 2: Gridfinity Profile]

// Amount of extra rounding to apply to the corners. This value is limited based on the size of the margins.
Extra_Corner_Rounding = 0;

// Standard Gridfinity is 42 mm.
Base_Unit_Dimension = 42;

// When non-zero, overrides Build Plate Size. MK3, MK4 = 210, Ender 3 = 220, etc.
Build_Plate_Usable_Size_Override = 0;

// Useful when editing STL model before printing.
Show_Assembled = false;

/* [Hidden] */

// Calculate unit counts, margins and whether we have half strips.
adjusted_width = Width - Clearance - Minimum_Left_Margin - Minimum_Right_Margin;
adjusted_depth = Depth - Clearance- Minimum_Front_Margin - Minimum_Back_Margin;

whole_units_wide = floor(adjusted_width / Base_Unit_Dimension);
whole_units_deep = floor(adjusted_depth / Base_Unit_Dimension);

have_vertical_half_strip = 
    Half_Sized_Filler && 
    (adjusted_width - whole_units_wide * Base_Unit_Dimension) >= Base_Unit_Dimension / 2;
have_horizontal_half_strip = 
    Half_Sized_Filler &&
    (adjusted_depth - whole_units_deep * Base_Unit_Dimension) >= Base_Unit_Dimension / 2;
units_wide = whole_units_wide + (have_vertical_half_strip ?  0.5 : 0);
units_deep = whole_units_deep + (have_horizontal_half_strip ?  0.5 : 0);
    
half_margin_h = (adjusted_width - units_wide * Base_Unit_Dimension) / 2;
half_margin_v = (adjusted_depth - units_deep * Base_Unit_Dimension) / 2;
// Cheesed this a little - just used the original Offset_Vertical, Offset_Horizontal logic.
clamped_offset_h = min(max(Horizontal_Alignment, -half_margin_h), half_margin_h);
clamped_offset_v = min(max(Depth_Alignment, -half_margin_v), half_margin_v);
margin_left = half_margin_h + clamped_offset_h + Minimum_Left_Margin;
margin_back = half_margin_v + clamped_offset_v + Minimum_Back_Margin;
margin_right = half_margin_h - clamped_offset_h + Minimum_Right_Margin;
margin_front = half_margin_v - clamped_offset_v + Minimum_Front_Margin;
max_margin = max(max(margin_left, margin_right), max(margin_front, margin_back)); 

base_corner_radius = 4;
max_extra_corner_radius = Margin_Skeletonization > 0 ? 0 : max(min(margin_left, margin_right), min(margin_front, margin_back));
outer_corner_radius = base_corner_radius + max(0, min(Extra_Corner_Rounding, max_extra_corner_radius));

fn_min = 20;
fn_max = 40;
function lerp(x, x0, x1, y0, y1) = y0 + (x - x0) * (y1 - y0) / (x1 - x0);
$fn = max(min(lerp(units_wide*units_deep, 300, 600, fn_max, fn_min), fn_max), fn_min);

max_unit_dimension = max(units_wide, whole_units_wide, whole_units_deep);
selected_plate_size = Build_Plate_Usable_Size_Override > 0 ? Build_Plate_Usable_Size_Override : Build_Plate_Size;

// Need to increase as the cutting tool intentionally extends deeper than necessary.
extra_base_thickness = Solid_Base_Thickness > 0 ? Solid_Base_Thickness + 0.5 : 0;

max_recursion_depth = 12;
part_spacing = Show_Assembled ? 0 : 10;

cut_overshoot = 0.1;
non_grips_edge_clearance = 0.25;
min_corner_radius = Interlock_Type == 3 ? 0.25 : 1;
grips_min_margin_for_full_tab = 2.75;

m3_clearance_hole_size = 3.2;
m3_nut_wrench_size = 5.5; // Across the flats.
m3_nut_wrench_min_wall_thickness = m3_nut_wrench_size/2;
m3_nut_thickness = 2.3;
m3_screw_size_extra_thickness = 1.7; // + 6mm for the baseplate = 10mm long screw.
m3_max_head_diameter = m3_nut_wrench_size + 0.4 * 2;
m3_boss_half_contact_length = m3_nut_wrench_size /2;
m3_boss_half_clearance = 0;
m3_corner_contact_clearance = 0.05;
m3_boss_non_contact_clearance = non_grips_edge_clearance;
m3_min_bottom_vertical_height = m3_max_head_diameter;

circumscribed_square_scale = 1.414;
circumscribed_hexagon_scale = 1.1547;
circumscribed_octagon_scale = 1.0824;
slope_60_degrees =  1.732;

// New baseplate generation code.

// Predefine/precalculate values.
magnet_tab_min_bottom_vertical_height =
    Magnet_Hole_Depth + max(0, Minimum_Under_Magnet_Thickness - Solid_Base_Thickness);
magnet_tab_wall_thickness = 1.2;

filament_lock_top_thickness = 0.25;
filament_lock_min_bottom_thickness = 0.4;
filament_lock_min_bottom_vertical_height = 
    Filament_Lock_Hole_Diameter + filament_lock_top_thickness + 
        max(0, filament_lock_min_bottom_thickness - Solid_Base_Thickness);
        
b_top_chamfer_height = 1.9;
b_center_height = 1.8;
b_bottom_chamfer_height = 0.8;
b_bottom_vertical_height = Magnets ? 
    max(Interlock_Type == 3 ? m3_min_bottom_vertical_height : filament_lock_min_bottom_vertical_height, magnet_tab_min_bottom_vertical_height) : 
    (Interlock_Type == 3 ? m3_min_bottom_vertical_height : 0);
b_total_height = b_top_chamfer_height + b_center_height + b_bottom_chamfer_height + b_bottom_vertical_height + Solid_Base_Thickness;

b_cut_overshoot = 0.1;
b_tool_top_chamfer_height = b_top_chamfer_height + cut_overshoot;
b_tool_bottom_chamfer_height = b_bottom_chamfer_height + (Solid_Base_Thickness > 0 || b_bottom_vertical_height > 0 ? 0 : cut_overshoot);
b_tool_bottom_vertical_height = b_bottom_vertical_height > 0 ? (b_bottom_vertical_height + (Solid_Base_Thickness > 0 ? 0 : cut_overshoot)) : 0;

b_corner_center_inset = 4;
b_corner_center_radius = 1.85;
b_tool_top_scale = (b_corner_center_radius + b_tool_top_chamfer_height) / b_corner_center_radius;
b_tool_bottom_scale = (b_corner_center_radius - b_tool_bottom_chamfer_height) / b_corner_center_radius;

b_have_join_holes = Magnets || Interlock_Type == 3;
b_join_hole_diameter = Interlock_Type == 3 ? m3_clearance_hole_size : Filament_Lock_Hole_Diameter;
b_join_hole_center_down_offset = 
    Interlock_Type == 3 ? 
        m3_min_bottom_vertical_height / 2 : 
        (filament_lock_top_thickness + Filament_Lock_Hole_Diameter / 2);
b_join_hole_center_height = 
    b_total_height - b_top_chamfer_height - b_center_height - b_bottom_chamfer_height - b_join_hole_center_down_offset;

b_magnet_center_inset = 8;

extra_radius_for_simple_margin_hole = 0.65;
margin_hole_margin_adjust = Margin_Skeletonization == 1 ? -b_bottom_chamfer_height - extra_radius_for_simple_margin_hole : 0;
min_width_for_margin_hole = b_corner_center_inset * 2;


module uncut_baseplate(units_x, units_y, r_fl, r_bl, r_br, r_fr, m_l, m_b, m_r, m_f) {

    main_width = Base_Unit_Dimension*units_x;
    main_depth = Base_Unit_Dimension*units_y;

    difference() {
        // Baseplate body.
        hull() {
            translate([r_fl-m_l, r_fl-m_f, 0])
                cylinder(r=r_fl, h=b_total_height, center=false);
            translate([r_bl-m_l, main_depth-r_bl+m_b, 0])
                cylinder(r=r_bl, h=b_total_height, center=false);
            translate([main_width-r_br+m_r, main_depth-r_br+m_b, 0])
                cylinder(r=r_br, h=b_total_height, center=false);
            translate([main_width-r_fr+m_r, r_fr-m_f, 0])
                cylinder(r=r_fr, h=b_total_height, center=false);
        }        
        // Grid of cutting tools.
        for(y=[1:ceil(units_y)]) {
            for(x=[1:ceil(units_x)]) {
                translate([Base_Unit_Dimension*(x-0.5), Base_Unit_Dimension*(y-0.5),0])
                    gridfinity_cutting_tool(x > units_x, y > units_y);
            }
        }
        if (Margin_Skeletonization > 0) {
            margin_cutting_tools(
                units_x, 
                units_y, 
                m_l + margin_hole_margin_adjust, 
                m_b + margin_hole_margin_adjust, 
                m_r + margin_hole_margin_adjust, 
                m_f + margin_hole_margin_adjust
            );
        }
    }
}

module gridfinity_cutting_tool(half_x, half_y) {
    base_offset = Base_Unit_Dimension/2 - b_corner_center_inset;

    if (half_x || half_y) {
        adjust_x = half_x ? Base_Unit_Dimension/4 : 0;
        adjust_y = half_y ? Base_Unit_Dimension/4 : 0;
        translate([-adjust_x, -adjust_y, 0])
            gridfinity_cutting_tool_from_offsets(half_x, half_y, base_offset - adjust_x, base_offset - adjust_y);
    }
    else {
        gridfinity_cutting_tool_from_offsets(false, false, base_offset, base_offset);
    }
}

module gridfinity_cutting_tool_main(offset_x, offset_y) {
    top_z_offset = b_total_height - b_top_chamfer_height;
    middle_z_offset = top_z_offset - b_center_height;
    bottom_z_offset = middle_z_offset  - b_bottom_chamfer_height;

    union() {
        hull() {
            for (x = [-offset_x, offset_x])
                for (y = [-offset_y, offset_y])
                    translate([x , y , top_z_offset]) 
                        linear_extrude(height=b_tool_top_chamfer_height, scale=[b_tool_top_scale, b_tool_top_scale])
                            circle(r=b_corner_center_radius);
        }

        hull() {
            for (x = [-offset_x, offset_x])
                for (y = [-offset_y, offset_y])
                    translate([x , y , middle_z_offset]) {
                        cylinder(r=b_corner_center_radius, h=b_center_height, center=false);
                        mirror([0, 0, 1]) 
                            linear_extrude(height=b_tool_bottom_chamfer_height, scale=[b_tool_bottom_scale, b_tool_bottom_scale])
                                circle(r=b_corner_center_radius);
                    }
        }
        if (b_tool_bottom_vertical_height > 0) {
            tool_bottom_z_offset = bottom_z_offset - b_tool_bottom_vertical_height;
            hull() {
                for (x = [-offset_x, offset_x])
                    for (y = [-offset_y, offset_y])
                        translate([x , y , tool_bottom_z_offset]) {
                            cylinder(r=b_corner_center_radius * b_tool_bottom_scale, h=b_tool_bottom_vertical_height, center=false);
                        }
            }
        }
    }
}

module gridfinity_cutting_tool_from_offsets(half_x, half_y, offset_x, offset_y) {

    magnet_offset_x = offset_x - b_magnet_center_inset + b_corner_center_inset;
    magnet_offset_y = offset_y - b_magnet_center_inset + b_corner_center_inset;
    
    union() {
        difference() {
            gridfinity_cutting_tool_main(offset_x, offset_y);
            if (b_tool_bottom_vertical_height > 0) {
                magnet_tab_tool(-magnet_offset_x , -magnet_offset_y);
                mirror([1, 0, 0])
                    magnet_tab_tool(-magnet_offset_x , -magnet_offset_y);
                mirror([0, 1, 0])
                    magnet_tab_tool(-magnet_offset_x , -magnet_offset_y);
                mirror([1, 0, 0])
                    mirror([0, 1, 0])
                        magnet_tab_tool(-magnet_offset_x , -magnet_offset_y);
            }
/* 
            // Removed from m3 screw interlock type, however might be useful for something else later.
            if (Interlock_Type == 3) {
                // Little inset around the sides for extra thickness to support the screws.
                inset_offset = b_corner_center_radius - b_tool_bottom_chamfer_height - m3_screw_size_extra_thickness;
                translate([0, 0, -cut_overshoot])
                    linear_extrude(height = bottom_z_offset + cut_overshoot)
                        difference() {
                            square(Base_Unit_Dimension, center = true);
                            square([(offset_x + inset_offset) * 2, (offset_y + inset_offset) * 2], center = true);
                        }
            }
*/            
        }
        if (Magnets) {
            magnet_hole_tool(-magnet_offset_x , -magnet_offset_y);
            if (!half_x)
                mirror([1, 0, 0])
                    magnet_hole_tool(-magnet_offset_x , -magnet_offset_y);
            if (!half_y)
                mirror([0, 1, 0])
                    magnet_hole_tool(-magnet_offset_x , -magnet_offset_y);
            if (!half_x && !half_y)
                mirror([1, 0, 0])
                    mirror([0, 1, 0])
                        magnet_hole_tool(-magnet_offset_x , -magnet_offset_y);
        }
    }
}

module margin_hole_cutter(offset_x, offset_y) {
    if (Margin_Skeletonization == 1) {
        height = b_total_height + b_cut_overshoot + (Solid_Base_Thickness ? -Solid_Base_Thickness : b_cut_overshoot);    
        offset_z = Solid_Base_Thickness ? Solid_Base_Thickness : - b_cut_overshoot;
        hull()
            for (x = [-offset_x, offset_x])
                for (y = [-offset_y, offset_y])
                    translate([x , y , offset_z])
                        cylinder(r=b_corner_center_radius + extra_radius_for_simple_margin_hole, h=height, center=false);
    }
    else
        gridfinity_cutting_tool_main(offset_x, offset_y);
}

module margin_hole_strip_cutter(units, margin_thickness) {
    half_margin = margin_thickness / 2;
    offset_x = margin_thickness / 2 - b_corner_center_inset;
    offset_y = Base_Unit_Dimension / 2 - b_corner_center_inset;
 
    for(i=[1:ceil(units)]) {
        y_adjust = i > units ? Base_Unit_Dimension / 4 : 0;
        translate([-half_margin, Base_Unit_Dimension*(i-0.5) - y_adjust, 0])
            margin_hole_cutter(offset_x, offset_y - y_adjust); 
    }
}

module margin_cutting_tools(units_x, units_y, m_l, m_b, m_r, m_f) {
    if (m_l > min_width_for_margin_hole)
        margin_hole_strip_cutter(units_y, m_l);
    if (m_r > min_width_for_margin_hole)
        translate([units_x * Base_Unit_Dimension, 0, 0])
            mirror([1, 0, 0])
                margin_hole_strip_cutter(units_y, m_r);
    if (m_f > min_width_for_margin_hole)
        rotate([0, 0, -90])
            mirror([1, 0, 0])
                margin_hole_strip_cutter(units_x, m_f);
    if (m_b > min_width_for_margin_hole)
        translate([0, units_y * Base_Unit_Dimension, 0])
            rotate([0, 0, -90])
                margin_hole_strip_cutter(units_x, m_b);
                
    if (m_l > min_width_for_margin_hole && m_f > min_width_for_margin_hole)
        translate([-m_l/2, -m_f/2, 0])
            margin_hole_cutter(m_l/2 - b_corner_center_inset, m_f/2 - b_corner_center_inset); 
    if (m_r > min_width_for_margin_hole && m_f > min_width_for_margin_hole)
        translate([m_r/2 + units_x * Base_Unit_Dimension, -m_f/2, 0])
            margin_hole_cutter(m_r/2 - b_corner_center_inset, m_f/2 - b_corner_center_inset); 
    if (m_l > min_width_for_margin_hole && m_b > min_width_for_margin_hole)
        translate([-m_l/2, m_b/2 + units_y * Base_Unit_Dimension, 0])
            margin_hole_cutter(m_l/2 - b_corner_center_inset, m_b/2 - b_corner_center_inset); 
    if (m_r > min_width_for_margin_hole && m_b > min_width_for_margin_hole)
        translate([m_r/2 + units_x * Base_Unit_Dimension, m_b/2 + units_y * Base_Unit_Dimension, 0])
            margin_hole_cutter(m_r/2 - b_corner_center_inset, m_b/2 - b_corner_center_inset);
}


module magnet_tab_tool(offset_x, offset_y) {
    inner = max(Magnet_Hole_Diameter, Under_Magnet_Hole_Diameter) /2 + magnet_tab_wall_thickness;
    corner = inner * 0.4142;
    outer = -b_magnet_center_inset;
    height = b_tool_bottom_vertical_height + cut_overshoot;
    offset_z = b_total_height - b_top_chamfer_height - b_center_height - b_bottom_chamfer_height - height;

    translate([offset_x, offset_y, offset_z]) {
        linear_extrude(height=height) {
            polygon(points=
                [
                    [outer, outer],
                    [outer, inner],
                    [corner, inner],
                    [inner, corner],
                    [inner, outer],
                ]
            );
        }
    }
}

module magnet_hole_tool(offset_x, offset_y) {
    magnet_cutter_height = Magnet_Hole_Depth + cut_overshoot;
    offset_z = b_total_height - b_top_chamfer_height - b_center_height - b_bottom_chamfer_height - Magnet_Hole_Depth;
    under_hole_height = offset_z + magnet_cutter_height + cut_overshoot;

    translate([offset_x, offset_y, offset_z]) {
        cylinder(h = magnet_cutter_height, r = Magnet_Hole_Diameter/2, $fn = fn_min);
    }
    translate([offset_x, offset_y, -cut_overshoot]) {
        rotate([0, 0, 22.5])
            cylinder(h = under_hole_height, r = Under_Magnet_Hole_Diameter/2*circumscribed_octagon_scale, $fn = 8);
    }    
    
}

// Interlock cutting tools.    
module interlock_cutting_tool_left(start_tab_amount, end_tab_amount, units) {
    if (Interlock_Type == 3)
        // M3 screw and nut.
        m3_screw_boss_cutting_tool(units);
    else
        grips_cutting_tool_common(start_tab_amount, end_tab_amount, units, grips_right_polyline_data(), -1);
    
    lock_hole_cutting_tool(units);
}

module interlock_cutting_tool_right(start_tab_amount, end_tab_amount, units) {
    if (Interlock_Type == 3) {
        // M3 screw and nut.
        mirror([1, 0, 0])
            interlock_cutting_tool_left(start_tab_amount, end_tab_amount, units);
    }
    else {
        // GRIPS tab.
        grips_cutting_tool_common(start_tab_amount, end_tab_amount, units, grips_left_polyline_data(), 1);
        mirror([1, 0, 0])
            lock_hole_cutting_tool(units);
    }
}

module interlock_cutting_tool_back(start_tab_amount, end_tab_amount, units) {
    rotate([0, 0, -90])
        interlock_cutting_tool_left(start_tab_amount, end_tab_amount, units);
}

module interlock_cutting_tool_front(start_tab_amount, end_tab_amount, units) {
    rotate([0, 0, -90])
        interlock_cutting_tool_right(start_tab_amount, end_tab_amount, units);
}

// GRIPS cutting tools.    
    
// Tessellation functions
function tessellate_arc(start, end, bulge, segments = 8) =
    let(
        chord = end - start,
        chord_length = norm(chord),
        sagitta = abs(bulge) * chord_length / 2,
        radius = (chord_length/2)^2 / (2*sagitta) + sagitta/2,
        center_height = radius - sagitta,
        center_offset = [-chord.y, chord.x] * center_height / chord_length,
        center = (start + end)/2 + (bulge >= 0 ? center_offset : -center_offset),
        start_angle = atan2(start.y - center.y, start.x - center.x),
        end_angle = atan2(end.y - center.y, end.x - center.x),
        angle_diff = (bulge >= 0) ?
            (end_angle < start_angle ? end_angle - start_angle + 360 : end_angle - start_angle) :
            (start_angle < end_angle ? start_angle - end_angle + 360 : start_angle - end_angle),
        num_segments = max(1, round(segments * (angle_diff / 360))),
        angle_step = angle_diff / num_segments
    )
    [for (i = [0 : num_segments - 1])
        let(angle = start_angle + (bulge >= 0 ? 1 : -1) * i * angle_step)
        center + radius * [cos(angle), sin(angle)]
    ];
    
function tessellate_polyline(data) =
    let(
        polyline_curve_segments = 8,
        points = [for (i = [0:len(data)-1])
            let(
                start = [data[i][0], data[i][1]],
                end = [data[(i+1) % len(data)][0], data[(i+1) % len(data)][1]],
                bulge = data[i][2]
            )
            if (bulge == 0)
                [start]
            else
                tessellate_arc(start, end, bulge, polyline_curve_segments)
        ]
    )
    [for (segment = points, point = segment) point];
        
// Profile data (as provided before)
function reverse_polyline_data(data) = 
    let(
        n = len(data),
        reversed = [for (i = [n-1:-1:0]) 
            [data[i][0], data[i][1], 
             i > 0 ? -data[i-1][2] : 0]  // Negate bulge from previous point
        ]
    )
    reversed;
       
polyline_017_data_1 = [
    [0.2499999999999975, 38.523373536222223, 0.13165249758739542],
    [0.17229473419497243, 38.813373536222223, 0],
    [-0.77549874656872519, 40.454999999987507, -0.76732698797895982],
    [-0.43399239561125647, 40.796506350944981, 0],
    [0.44430391496627875, 40.289421739604791, 0.57735026918962284],
    [1.0743039149299163, 40.653152409173259, 0]
];

polyline_017_data_2 = [
    [0.90430391492990991, 40.653152409173259, -0.57735026918962595],
    [0.52930391496627871, 40.436646058248151, 0],
    [-0.3489923956112484, 40.943730669588334, 0.76732698797896193],
    [-0.92272306521208713, 40.369999999987513, 0],
    [-0.28349364905389146, 39.262822173508923, -0.13165249758738012],
    [-0.25000000000000011, 39.137822173508923, 0]
];

polyline_025_data_1 = [
    [0.24999999999999759, 38.52480947161672, 0.13165249758739531],
    [0.18301270189221758, 38.77480947161672, 0],
    [-0.74085773041736047, 40.374999999987523, -0.76732698797895982],
    [-0.39935137945989191, 40.716506350944996, 0],
    [0.43076110399664735, 40.237240685163684, 0.57735026918962273],
    [1.1807611039602837, 40.670253387034911, 0]
];
polyline_025_data_2 = [
    [0.93076110396028688, 40.670253387034904, -0.57735026918961174],
    [0.55576110399664325, 40.453747036109789, 0],
    [-0.27435137945989441, 40.933012701891094, 0.7673269879789687],
    [-0.9573640813634583, 40.249999999987523, 0],
    [-0.28349364905389129, 39.082822173508923, -0.13165249758739728],
    [-0.25000000000000011, 38.957822173508923, 0]
];

polyline_data_1 = Interlock_Type == 2 ? polyline_025_data_1 : polyline_017_data_1;
polyline_data_2 = Interlock_Type == 2 ? polyline_025_data_2 : polyline_017_data_2;

function get_min_polyline_x(data) =
    min([for (point = tessellate_polyline(data)) point[0]]);

function get_max_polyline_x(data) =
    max([for (point = tessellate_polyline(data)) point[0]]);

left_tab_extent = -min(0, min(get_min_polyline_x(polyline_data_1), get_min_polyline_x(polyline_data_2)));
right_tab_extent = max(0, max(get_max_polyline_x(polyline_data_1), get_max_polyline_x(polyline_data_2)));
reversed_polyline_data_2 = reverse_polyline_data(polyline_data_2);    
tab_min_clearance = polyline_data_1[len(polyline_data_1)-1].x - polyline_data_2[0].x;

tab_extent_allowance = max(left_tab_extent, right_tab_extent) + cut_overshoot + min_corner_radius;
grips_tool_extent_allowance = tab_extent_allowance + cut_overshoot;

// 2D point array helper functions.
function reverse_points(arr) = [for (i = [len(arr)-1:-1:0]) arr[i]];
function y_mirror_points(points) = [for (point = reverse_points(points)) [point.x, -point.y]];
function y_translate_points(points, y_delta) = [for (point = points) [point.x, point.y + y_delta]];
    
function lower_butt_profile(direction) =
    let(
        close_clearance = tab_min_clearance /2,
        delta = non_grips_edge_clearance - close_clearance,
        start = [close_clearance * -direction, -grips_min_margin_for_full_tab],
        end = [start.x + delta * -direction, start.y - delta],
     )
     [
        end,
        start
     ];

function upper_butt_profile(direction) =
    [[non_grips_edge_clearance * -direction, 0]];

function tesselate_and_adjust_grips_profile(polyline_data) =
    y_translate_points(tessellate_polyline(polyline_data), -42);
     
function lower_half_profile(grips_base_profile) =
    grips_base_profile;

function upper_half_profile(grips_base_profile) =
    y_mirror_points(grips_base_profile);

function full_profile(grips_base_profile) =
    [
        each lower_half_profile(grips_base_profile),
        each upper_half_profile(grips_base_profile)
    ];

function repeat_profile(profile, repetitions, spacing, start_offset) =
    repetitions <= 0 ? [] :
    let(
        repeated = [for (i = [0:repetitions-1])
            [for (point = profile)
                [point.x, point.y + i * spacing + start_offset]
            ]
        ]
    )
    [for (segment = repeated, point = segment) point];

module grips_cutting_tool_profile(start_tab_amount, end_tab_amount, units, base_polyline, direction) {
    grips_base_profile = tesselate_and_adjust_grips_profile(base_polyline);
    full_tab_profile = full_profile(grips_base_profile);
    start_profile = 
        start_tab_amount == 0 ? upper_butt_profile(direction) : 
            (start_tab_amount < 1 ? upper_half_profile(grips_base_profile) : full_tab_profile);
    end_profile = 
        end_tab_amount == 0 ? lower_butt_profile(direction) : 
            (end_tab_amount < 1 ? lower_half_profile(grips_base_profile) : full_tab_profile);
    translated_end_profile = y_translate_points(end_profile, Base_Unit_Dimension * units);
    
    repeated = repeat_profile(full_tab_profile, floor(units - 0.5), Base_Unit_Dimension, Base_Unit_Dimension);
            
    x_ext = grips_tool_extent_allowance * direction;
    down_ext = start_profile[0] + [0, -Base_Unit_Dimension-max_margin];
    up_ext = translated_end_profile[len(translated_end_profile)-1] + [0, Base_Unit_Dimension+max_margin];

    start_ext = [x_ext, down_ext.y];
    end_ext = [x_ext, up_ext.y];
        
    polygon([
        start_ext,
        down_ext,
        each start_profile,
        each repeated,
        each translated_end_profile,
        up_ext,
        end_ext,
        [end_ext.x, start_ext.y]
    ]);
}

cutting_tool_height = (b_total_height + cut_overshoot) * 2;

function grips_left_polyline_data() =
    reversed_polyline_data_2;

function grips_right_polyline_data() =
    polyline_data_1;

module grips_cutting_tool_common(start_tab_amount, end_tab_amount, units, base_polyline, direction) {
    linear_extrude(height=cutting_tool_height, center=true)
        grips_cutting_tool_profile(start_tab_amount, end_tab_amount, units, base_polyline, direction);
}

// M3 screw boss interlock cutting.
module m3_boss_cutting_tool_profile(units) {
    contact_lower_half_profile = [ 
        [m3_boss_non_contact_clearance, -m3_boss_half_contact_length - m3_boss_non_contact_clearance + m3_boss_half_clearance],
        [m3_boss_half_clearance, -m3_boss_half_contact_length],
    ];
    contact_profile = [
        each contact_lower_half_profile,
        each y_mirror_points(contact_lower_half_profile),
    ];
    corner_lower_half_profile = [ 
        [m3_boss_non_contact_clearance, -m3_boss_half_contact_length - m3_boss_non_contact_clearance + m3_corner_contact_clearance],
        [m3_corner_contact_clearance, -m3_boss_half_contact_length],
    ];
    corner_profile = [
        each corner_lower_half_profile,
        each y_mirror_points(corner_lower_half_profile),
    ];
    whole_profile = [
        each contact_profile,
        each y_translate_points(corner_profile, Base_Unit_Dimension * 0.5),
    ];

    repeated = repeat_profile(whole_profile, floor(units), Base_Unit_Dimension, Base_Unit_Dimension * 0.5);
    end = floor(units) != units ? y_translate_points(corner_profile, units * Base_Unit_Dimension) : [];
    down_ext =  + [corner_profile[0].x, -max_margin];
    up_ext = [repeated[len(repeated)-1].x , units * Base_Unit_Dimension + max_margin];
    x_ext = -grips_tool_extent_allowance;
    start_ext = [x_ext, down_ext.y];
    end_ext = [x_ext, up_ext.y];
        
    polygon([
        start_ext,
        down_ext,
        each corner_profile,
        each repeated,
        each end,
        up_ext,
        end_ext,
        [end_ext.x, start_ext.y]
    ]);
}

module m3_boss_trim_cutting_tool_profile(units) {
    lower_half_profile = [
        [-grips_tool_extent_allowance, -cutting_tool_height/2],
        [m3_boss_non_contact_clearance, -cutting_tool_height/2],
        [m3_boss_non_contact_clearance, -m3_boss_half_contact_length - m3_boss_non_contact_clearance + m3_boss_half_clearance],
        [m3_boss_half_clearance, -m3_boss_half_contact_length],
    ];
    
    whole_profile = [
        each lower_half_profile,
        each y_mirror_points(lower_half_profile)
    ];
    
    translated = y_translate_points(whole_profile, -b_join_hole_center_height);
        
    polygon(translated);
}

module m3_screw_boss_cutting_tool(units) {
    union() {
        linear_extrude(height=cutting_tool_height, center=true)
            m3_boss_cutting_tool_profile(units);
        translate([0, -max_margin, 0])
            rotate([-90, 0, 0])
                linear_extrude(height=units*Base_Unit_Dimension + max_margin * 2)
                    m3_boss_trim_cutting_tool_profile(units);
    }
}

module m3_nut_holder_half_profile() {
    half_m3_nut_wrench_size = m3_nut_wrench_size / 2;
    y_side_point = half_m3_nut_wrench_size * circumscribed_hexagon_scale;
    y_top_points = y_side_point - half_m3_nut_wrench_size / slope_60_degrees;
    y_outer = y_side_point + m3_nut_wrench_min_wall_thickness;
    
    profile = [
        [0, y_side_point],
        [-half_m3_nut_wrench_size, y_top_points],
        [-half_m3_nut_wrench_size, y_outer],
        [b_join_hole_center_height, y_outer],
        [b_join_hole_center_height, y_top_points],
        [half_m3_nut_wrench_size, y_top_points],
    ];
    
    polygon(profile);
}

module m3_nut_holder() {
    translate([b_corner_center_inset - b_corner_center_radius, 0, b_join_hole_center_height])
        rotate([0, 90, 0])
            linear_extrude(height=m3_nut_thickness + b_bottom_chamfer_height) {
                m3_nut_holder_half_profile();
                mirror([0, 1, 0]) 
                    m3_nut_holder_half_profile();
            }
}

// Lock hole cutting.
module lock_hole_cutting_tool(units) {
    hole_length = b_corner_center_inset + (Interlock_Type == 3 ? m3_screw_size_extra_thickness : 0);
    if (Magnets || Interlock_Type == 3)
        if (units >= 1)
            rotate([90, 0, 90])
                for (i = [1:floor(units)])
                    translate([(i-0.5)*Base_Unit_Dimension, b_join_hole_center_height, 0])
                        cylinder(h = hole_length, r = b_join_hole_diameter / 2 * circumscribed_hexagon_scale, $fn = 6);                        
}

// Plates / assembly.
function GetCutOffsetForward(prev_offset, margin_start, margin_end, axis_unit_length) =
    let(
        prev_carry_over = prev_offset == 0 ? margin_start : left_tab_extent,
        remaining = prev_carry_over + (axis_unit_length - prev_offset) * Base_Unit_Dimension + margin_end,
        next_offset = prev_offset + floor((selected_plate_size - left_tab_extent - right_tab_extent - (prev_offset == 0 ? margin_start : 0)) / Base_Unit_Dimension),
        next_remaining_approx = (axis_unit_length - next_offset) * Base_Unit_Dimension + margin_end
    )
       
    remaining <= selected_plate_size ? -1 :
    (next_remaining_approx < Base_Unit_Dimension + grips_min_margin_for_full_tab + 0.001) ? next_offset - 1 :
    next_offset;

function GetAltEndOffset(margin_end, axis_unit_length) =
    let(
        space_for_full_units = selected_plate_size - margin_end - left_tab_extent - (axis_unit_length % 1) * Base_Unit_Dimension,
        full_units = floor(space_for_full_units / Base_Unit_Dimension),
        offset = floor(axis_unit_length) - full_units
    )
    offset;

function GetUnitsPerInnerSection(axis_unit_length) =
    let(
        space_for_full_units = selected_plate_size - left_tab_extent - right_tab_extent
    )
    floor(space_for_full_units / Base_Unit_Dimension);

function GetAltStartOffset(margin_start, margin_end, axis_unit_length) =
    let(
        end_offset = GetAltEndOffset(margin_end, axis_unit_length),
        units_per_inner_section = GetUnitsPerInnerSection(axis_unit_length),
        initial_offset = end_offset % units_per_inner_section,
        adjusted_offset = 
            (initial_offset == 0) ?
                (Base_Unit_Dimension * units_per_inner_section + right_tab_extent + margin_start <= selected_plate_size) ?
                    units_per_inner_section : 1
            : initial_offset,
        final_offset = 
            (adjusted_offset == 1 && margin_start < (grips_min_margin_for_full_tab + 0.001)) ?
                2 : adjusted_offset
    )
    final_offset;

function recurse_plates_x(x_depth = 0, start_offset = 0) =
    let(
        end_offset = GetCutOffsetForward(start_offset, margin_left, margin_right, units_wide)
    )
    (end_offset < 0 || x_depth > max_recursion_depth) ?
        // We've reached the right end or recursing too much
        recurse_plates_y(x_depth, start_offset, units_wide)
    :
        // Concatenate left part and recursive right part
        concat(
            recurse_plates_y(x_depth, start_offset, end_offset),
            recurse_plates_x(x_depth + 1, end_offset)
        );

function recurse_plates_y(x_depth, x_start_offset, x_end_offset, y_depth = 0, y_start_offset = 0) =
    let(
        alt_cuts = x_depth % 2 != 0,
        standard_offset = GetCutOffsetForward(y_start_offset, margin_front, margin_back, units_deep),
        y_end_offset = alt_cuts && y_start_offset==0 && standard_offset >= 0 ? 
            GetAltStartOffset(margin_front, margin_back, units_deep) :
            standard_offset
    )
    (y_end_offset < 0 || y_depth > max_recursion_depth) ?
        // We've reached the end or recursing too much
        [[x_depth, y_depth, x_start_offset, x_end_offset, y_start_offset, units_deep]]
    :
        // Concatenate front part and recursive rear part
        concat(
            [[x_depth, y_depth, x_start_offset, x_end_offset, y_start_offset, y_end_offset]],
            recurse_plates_y(x_depth, x_start_offset, x_end_offset, y_depth + 1, y_end_offset)
        );

plates = recurse_plates_x();
do_x1c_adjustment = Build_Plate_Size == 238 && Build_Plate_Usable_Size_Override == 0;
do_h2d_adjustment = Build_Plate_Size == 320 && Build_Plate_Usable_Size_Override == 0;

function plate_centering_translation(plate) =
    let(
        x_start = plate[2],
        x_end = plate[3],
        y_start = plate[4],
        y_end = plate[5],
        left_amount = x_start == 0 ? margin_left : left_tab_extent,
        right_amount = (x_end - x_start) * Base_Unit_Dimension + (x_end == units_wide ? margin_right : right_tab_extent),
        front_amount = y_start == 0 ? margin_front : left_tab_extent,
        back_amount = (y_end - y_start) * Base_Unit_Dimension + (y_end == units_deep ? margin_back : right_tab_extent),
        zone_avoidance_x = do_h2d_adjustment ? max(25 - (350 - (left_amount + right_amount))/2, 0) : (do_x1c_adjustment ? max(18 - (256 - (left_amount + right_amount))/2, 0) : 0),
        zone_avoidance_y = do_x1c_adjustment ? max(18 - (256 - (front_amount + back_amount))/2, 0) : 0,
    )
    [(left_amount - right_amount)/2 + zone_avoidance_x, 
     (front_amount - back_amount)/2 + zone_avoidance_y, 
     0];
    
function overall_centering_translation(plate) =
    let (
        x_depth = plate[0],
        y_depth = plate[1],
        x_start_offset = plate[2],
        y_start_offset = plate[4],
        assembled_center = [-Base_Unit_Dimension*units_wide/2, -Base_Unit_Dimension*units_deep/2, 0],
        exiting_plate_center = plate_centering_translation(plate),
        plate_offset = 
            [x_start_offset * Base_Unit_Dimension + part_spacing * x_depth, 
             y_start_offset * Base_Unit_Dimension + part_spacing * y_depth,
             0],
        combined = assembled_center + plate_offset - exiting_plate_center,
    )
    [Mirror_Horizontally ? -combined.x : combined.x,
     Mirror_Vertically ? -combined.y : combined.y,
     combined.z];

module bottom_chamfer_cutter(units) {
    total_overshoot = max_margin + cut_overshoot;
    side_length = Bottom_Edge_Chamfer + cut_overshoot * 2;
    extrude_length = units * Base_Unit_Dimension + total_overshoot * 2;

    translate([-cut_overshoot, -total_overshoot, -cut_overshoot])
        rotate([-90, 0, 0] )
            linear_extrude(height=extrude_length)
                polygon(points=
                    [
                        [0, 0],
                        [0, -side_length],
                        [side_length, 0],
                    ]
                );
}     
     
module sub_baseplate(x_depth, y_depth, x_start_offset, x_end_offset, y_start_offset, y_end_offset) {
    w = x_end_offset-x_start_offset;
    d = y_end_offset-y_start_offset;
    
    is_left = x_start_offset == 0;
    is_right = x_end_offset == units_wide;
    is_front = y_start_offset == 0;
    is_back = y_end_offset == units_deep;
    
    r_fl = is_left && is_front ? outer_corner_radius : min_corner_radius;
    r_bl = is_left && is_back ? outer_corner_radius : min_corner_radius;
    r_br = is_right && is_back ? outer_corner_radius : min_corner_radius;
    r_fr = is_right && is_front ? outer_corner_radius : min_corner_radius;
    
    inner_margin = lookup(Interlock_Type, [
        [0, -non_grips_edge_clearance],
        [1, tab_extent_allowance],
        [2, tab_extent_allowance],
        [3, 0]
    ]);
    m_l = is_left ? margin_left : inner_margin;
    m_b = is_back ? margin_back : inner_margin;
    m_r = is_right ? margin_right : inner_margin;
    m_f = is_front ? margin_front : inner_margin;

    union() {
        difference() { 
            uncut_baseplate(w, d, 
                r_fl, r_bl, r_br, r_fr, 
                m_l, m_b, m_r, m_f);
            if (Interlock_Type > 0) {
                front_tab_amount = (is_front && margin_front < grips_min_margin_for_full_tab) ? 0.5 : 1.0;
                back_tab_amount = (is_back && margin_back < grips_min_margin_for_full_tab) ? 0.5 : 1.0;    
                left_tab_amount = is_left ? (margin_left < grips_min_margin_for_full_tab ? 0.5 : 1.0) : 0.0;
                right_tab_amount = is_right ? (margin_right < grips_min_margin_for_full_tab ? 0.5 : 1.0) : 0.0;
    
                if (!is_left)
                    interlock_cutting_tool_left(front_tab_amount, back_tab_amount, d);
                if (!is_right)
                    translate([w * Base_Unit_Dimension, 0, 0])
                        interlock_cutting_tool_right(front_tab_amount, back_tab_amount, d);
                if (!is_front)
                    interlock_cutting_tool_front(left_tab_amount, right_tab_amount, w);
                if (!is_back)
                    translate([0, d * Base_Unit_Dimension, 0])
                        interlock_cutting_tool_back(left_tab_amount, right_tab_amount, w);
            }
            
            if (Bottom_Edge_Chamfer > 0) {
                if (is_left)
                    translate([-margin_left, 0, 0])
                        bottom_chamfer_cutter(d);
                if (is_right)
                    translate([Base_Unit_Dimension * w + margin_right, 0, 0])
                        mirror([1, 0, 0])
                            bottom_chamfer_cutter(d);
                if (is_front)
                    translate([0, -margin_front, 0])
                        rotate([0, 0, -90])
                            mirror([1, 0, 0])
                                bottom_chamfer_cutter(w);
                if (is_back)
                    translate([0, Base_Unit_Dimension * d + margin_back, 0])
                        rotate([0, 0, -90])
                            bottom_chamfer_cutter(w);
            }
        }
        if (Interlock_Type == 3) {
            if (!is_front)
                for(x=[1:floor(w)])
                    translate([(x - 0.5) * Base_Unit_Dimension, 0, 0])
                        rotate([0, 0, 90])
                            m3_nut_holder();
            if (!is_left)
                for(y=[1:floor(d)])
                    translate([0, (y - 0.5) * Base_Unit_Dimension, 0])
                        m3_nut_holder();
        }
    }
}

module sub_baseplate_from_list(plate) {
    translate(plate_centering_translation(plate))
        sub_baseplate(
            plate[0], plate[1],  // x_depth, y_depth
            plate[2], plate[3],  // x_start, x_end
            plate[4], plate[5]   // y_start, y_end
        );
}

module v_mirrored_base_plate(plate) {
    if (Mirror_Vertically)
            mirror([0, 1, 0])
                sub_baseplate_from_list(plate);
    else
        sub_baseplate_from_list(plate);
}

module mirrored_base_plate(plate) {
    if (Mirror_Horizontally)
            mirror([1, 0, 0])
                v_mirrored_base_plate(plate);
    else
        v_mirrored_base_plate(plate);
}

module assembled_plates() {
    for (plate = plates)
        translate(overall_centering_translation(plate))
            mirrored_base_plate(plate);
}

// For regular / STL use. Uncomment when needed.
assembled_plates();


