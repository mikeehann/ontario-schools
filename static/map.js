document.addEventListener('DOMContentLoaded', function () {
            
    // 1. Initialize the map
    // Set the map's center to Toronto, Ontario, and set a zoom level
    const map = L.map('map').setView([43.6532, -79.3832], 12);

    L.tileLayer('https://tile.openstreetmap.org/{z}/{x}/{y}.png', {
        maxZoom: 19,
        attribution: '&copy; <a href="http://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors'
    }).addTo(map);

    const colourScale = chroma.scale(['#d73027', '#fee08b', '#1a9850']).domain([0, 100]);

    fetch("static/ontario_schools.geojson")
        .then(response => response.json())
        .then(data => {
            L.geoJSON(data, {
                pointToLayer: function (feature, latLng) {
                    const props = feature.properties
                    const valueStr = props.pctOverallM_L34
                    const valueNum = parseFloat(valueStr)

                    const pointColour = isNaN(valueNum) ? '#808080' : colourScale(valueNum).hex()

                    return L.circleMarker(latLng, {
                        radius: 4,
                        fillColor: pointColour,
                        color: "#000",
                        weight: 0.5,
                        opacity: 1,
                        fillOpacity: 0.9,
                    });
                },
                onEachFeature: function (feature, layer) {
                    const props = feature.properties;
                    if (props) {
                        layer.bindPopup(
                            `<h4>${props.SchoolName}</h4>
                             <b>Board:</b> ${props.BoardName}<br>
                             <b>Math Proficiency (L3/4):</b> ${props.pctOverallM_L34}`
                        );
                    }
                }
            }).addTo(map);
        })
        .catch(error => console.error('Error loading GeooJSON data', error));
});