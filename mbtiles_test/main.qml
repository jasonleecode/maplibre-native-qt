import QtQuick 6.5
import QtQuick.Window 6.5
import QtLocation 6.5
import QtPositioning 6.5
import MapLibre.Location 4.0

Window {
    id: window
    width: 1024
    height: 768
    visible: true
    title: "MapLibre MBTiles: " + mbtilesPath

    readonly property string mbtilesPath: "/home/lixiang/Downloads/maps/Beijing260513.mbtiles"
    readonly property string mbtilesSrcLayer: "water"

    Plugin {
        id: mapPlugin
        name: "maplibre"
        PluginParameter {
            name: "maplibre.map.styles"
            value: Qt.resolvedUrl("empty_style.json").toString()
        }
        // Enable CJK text rendering via Qt system font (no remote glyph server needed)
        PluginParameter {
            name: "maplibre.map.font.family"
            value: "Noto Sans CJK SC"
        }
    }

    MapView {
        id: mapView
        anchors.fill: parent
        map.plugin: mapPlugin
        map.center: QtPositioning.coordinate(39.9, 116.4)
        map.zoomLevel: 10

        MapLibre.style: Style {
            SourceParameter {
                styleId: "mbtiles-source"
                type: "vector"
                property string url: "mbtiles://" + mbtilesPath
            }

            // Background
            LayerParameter {
                styleId: "background"
                type: "background"
                paint: { "background-color": "#f2efe9" }
            }

            // Land cover (vegetation, bare ground)
            LayerParameter {
                styleId: "landcover-fill"
                type: "fill"
                property string source: "mbtiles-source"
                property string sourceLayer: "landcover"
                paint: { "fill-color": "#d4e8c2" }
            }

            // Land use (residential, commercial, industrial)
            LayerParameter {
                styleId: "landuse-fill"
                type: "fill"
                property string source: "mbtiles-source"
                property string sourceLayer: "landuse"
                paint: { "fill-color": "#e0ddd6" }
            }

            // Parks and green spaces
            LayerParameter {
                styleId: "park-fill"
                type: "fill"
                property string source: "mbtiles-source"
                property string sourceLayer: "park"
                paint: { "fill-color": "#c8e6c9" }
            }

            // Water bodies
            LayerParameter {
                styleId: "water-fill"
                type: "fill"
                property string source: "mbtiles-source"
                property string sourceLayer: "water"
                paint: { "fill-color": "#aad3df" }
            }

            // Waterways (rivers, streams)
            LayerParameter {
                styleId: "waterway-line"
                type: "line"
                property string source: "mbtiles-source"
                property string sourceLayer: "waterway"
                paint: { "line-color": "#aad3df", "line-width": 1 }
            }

            // Aeroway (runways, taxiways)
            LayerParameter {
                styleId: "aeroway-fill"
                type: "fill"
                property string source: "mbtiles-source"
                property string sourceLayer: "aeroway"
                paint: { "fill-color": "#d8d8d8" }
            }

            // Road casing (outline, drawn first/below road fill)
            LayerParameter {
                styleId: "transportation-casing"
                type: "line"
                property string source: "mbtiles-source"
                property string sourceLayer: "transportation"
                paint: { "line-color": "#c0b89a", "line-width": 3, "line-gap-width": 0 }
            }

            // Road fill
            LayerParameter {
                styleId: "transportation-fill"
                type: "line"
                property string source: "mbtiles-source"
                property string sourceLayer: "transportation"
                paint: { "line-color": "#ffffff", "line-width": 2 }
            }

            // Buildings
            LayerParameter {
                styleId: "building-fill"
                type: "fill"
                property string source: "mbtiles-source"
                property string sourceLayer: "building"
                paint: { "fill-color": "#ddd6cb", "fill-outline-color": "#c9c0b0" }
            }

            // Administrative boundaries
            LayerParameter {
                styleId: "boundary-line"
                type: "line"
                property string source: "mbtiles-source"
                property string sourceLayer: "boundary"
                paint: { "line-color": "#9e9cab", "line-width": 1 }
            }

            // Road names (along the line)
            LayerParameter {
                styleId: "transportation-name-label"
                type: "symbol"
                property string source: "mbtiles-source"
                property string sourceLayer: "transportation_name"
                layout: {
                    "text-field": ["coalesce", ["get", "name:latin"], ["get", "name"]],
                    "text-size": 11,
                    "symbol-placement": "line",
                    "text-font": ["Klokantech Noto Sans Regular"],
                    "text-max-angle": 30
                }
                paint: {
                    "text-color": "#333333",
                    "text-halo-color": "#ffffff",
                    "text-halo-width": 1.5
                }
            }

            // Place names (city, town, village, neighbourhood)
            LayerParameter {
                styleId: "place-label"
                type: "symbol"
                property string source: "mbtiles-source"
                property string sourceLayer: "place"
                layout: {
                    "text-field": ["coalesce", ["get", "name:latin"], ["get", "name"]],
                    "text-size": 13,
                    "text-font": ["Klokantech Noto Sans Regular"],
                    "text-max-width": 8
                }
                paint: {
                    "text-color": "#1a1a1a",
                    "text-halo-color": "#f2efe9",
                    "text-halo-width": 1.5
                }
            }

            // Water names
            LayerParameter {
                styleId: "water-name-label"
                type: "symbol"
                property string source: "mbtiles-source"
                property string sourceLayer: "water_name"
                layout: {
                    "text-field": ["coalesce", ["get", "name:latin"], ["get", "name"]],
                    "text-size": 11,
                    "text-font": ["Klokantech Noto Sans Italic"]
                }
                paint: {
                    "text-color": "#4a85a8",
                    "text-halo-color": "#ffffff",
                    "text-halo-width": 1
                }
            }
        }
    }

    Timer {
        interval: 3000; running: true; repeat: true
        onTriggered: {
            if (mapView.map.errorString)
                console.log("Map error:", mapView.map.errorString)
        }
    }
}
