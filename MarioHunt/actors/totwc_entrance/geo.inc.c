#include "src/game/envfx_snow.h"

const GeoLayout totwc_entrance_001_switch_opt1[] = {
	GEO_NODE_START(),
	GEO_OPEN_NODE(),
		GEO_DISPLAY_LIST(LAYER_OPAQUE, totwc_entrance_000_displaylist_001_mesh_layer_1_mat_override_empty_0),
		GEO_DISPLAY_LIST(LAYER_TRANSPARENT, totwc_entrance_000_displaylist_001_mesh_layer_5_mat_override_empty_0),
	GEO_CLOSE_NODE(),
	GEO_RETURN(),
};
const GeoLayout totwc_entrance_geo[] = {
	GEO_CULLING_RADIUS(1500),
	GEO_OPEN_NODE(),
		GEO_CULLING_RADIUS(600),
		GEO_OPEN_NODE(),
			GEO_SWITCH_CASE(2, geo_switch_anim_state),
			GEO_OPEN_NODE(),
				GEO_NODE_START(),
				GEO_OPEN_NODE(),
					GEO_DISPLAY_LIST(LAYER_OPAQUE, totwc_entrance_000_displaylist_001_mesh_layer_1),
					GEO_DISPLAY_LIST(LAYER_TRANSPARENT, totwc_entrance_000_displaylist_001_mesh_layer_5),
				GEO_CLOSE_NODE(),
				GEO_BRANCH(1, totwc_entrance_001_switch_opt1),
			GEO_CLOSE_NODE(),
		GEO_CLOSE_NODE(),
		GEO_DISPLAY_LIST(LAYER_OPAQUE, totwc_entrance_material_revert_render_settings),
		GEO_DISPLAY_LIST(LAYER_TRANSPARENT, totwc_entrance_material_revert_render_settings),
	GEO_CLOSE_NODE(),
	GEO_END(),
};
