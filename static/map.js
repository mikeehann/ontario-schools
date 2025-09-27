document.addEventListener('DOMContentLoaded', function () {
            
    // 1. Initialize the map
    // Set the map's center to Toronto, Ontario, and set a zoom level
    const map = L.map('map').setView([43.6532, -79.3832], 12);

    L.tileLayer('https://tile.openstreetmap.org/{z}/{x}/{y}.png', {
        maxZoom: 19,
        attribution: '&copy; <a href="http://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors'
    }).addTo(map);

    const colourScale = chroma.scale(['#d73027', '#fee08b', '#1a9850']).domain([0, 100]);

    let schoolData = null;
    let geojsonDataLayer = null;

    // Map short-form to long-form text
    function createLabel(key) {
        let label = key.replace('pctOverall', '').replace('_L34', '');
        switch (label) {
            case 'M': return 'Math Proficiency';
            case 'R': return 'Reading Proficiency';
            case 'W': return 'Writing Proficiency';
            default: return key; // Fallback to the raw key name
        }
    }

    // Populate dropdown with geojson props
    function populateDropdown(features) {
        const attributeSelect = document.getElementById('attribute-select');
        const firstFeatureProperties = features[0].properties;

        // Loop through all properties of the first school
        for (const key in firstFeatureProperties) {
            // We only want to add the proficiency percentages to our dropdown
            if (key.startsWith('pctOverall') && key.endsWith('L34')) {
                const option = document.createElement('option');
                option.value = key; // e.g., "pctOverallM_L34"
                option.textContent = createLabel(key); // e.g., "Math Proficiency"
                attributeSelect.appendChild(option);
            }
        }
    }

    function updateMapStyle(attribute) {
        if (geojsonDataLayer) {
            map.removeLayer(geojsonDataLayer);
        }
        geojsonDataLayer = L.geoJSON(schoolData, {
            pointToLayer: function (feature, latLng) {
                const props = feature.properties;
                const valueStr = props[attribute];
                const valueNum = parseFloat(valueStr);
                const pointColor = isNaN(valueNum) ? '#808080' : colourScale(valueNum).hex();
                return L.circleMarker(latLng, {
                    radius: 4,
                    fillColor: pointColor,
                    color: "#000",
                    weight: 0.5,
                    opacity: 1,
                    fillOpacity: 0.9,
                });
            },
            onEachFeature: function (feature, layer) {
                const props = feature.properties;
                if (props) {
                    const selectedLabel = createLabel(attribute);
                    layer.bindPopup(
                        `<h4>${props.SchoolName}</h4>
                         <b>Board:</b> ${props.BoardName}<br>
                         <b>${selectedLabel}:</b> ${props[attribute]}`
                    );
                }
            }
        }).addTo(map);

        const legendTitle = document.getElementById('legend-title');
        if (legendTitle) {
            legendTitle.innerHTML = createLabel(attribute);
        }
    }

    const attributeSelect = document.getElementById('attribute-select');
    attributeSelect.addEventListener('change', function() {
        const selectedAttribute = this.value;
        updateMapStyle(selectedAttribute);
    });

    fetch("static/ontario_schools.geojson")
    .then(response => response.json())
    .then(data => {
        schoolData = data;
            
        populateDropdown(data.features);

        // Get the first option from the populated dropdown to set the initial map style
        const initialAttribute = document.getElementById('attribute-select').value;
        updateMapStyle(initialAttribute);
    })
    .catch(error => console.error('Error loading GeooJSON data', error));

    // Legend
    const legend = L.control({position: "topright"});

    legend.onAdd = function (map) { 
        const div = L.DomUtil.create("div", "info legend");
        const grades = [0, 20, 40, 60, 80];

        div.innerHTML += '<h4 id="legend-title">Proficiency</h4>';

        for (let i = 0; i < grades.length; i++) {
            const fromGrade = grades[i];
            const toGrade = grades[i + 1];
            const gradeColour = colourScale(fromGrade + 1).hex();
            const item = document.createElement('div');
            
            item.className = 'legend-item';
            item.innerHTML = `
                <i style="--grade-color: ${gradeColour}"></i>
                <span>${fromGrade}${toGrade ? '&ndash;' + toGrade + '%' : '+%'}</span>
            `;
            div.appendChild(item);
        }

        const noDataItem = document.createElement('div');
        noDataItem.className = 'legend-item';
        noDataItem.innerHTML = `
            <i style="--grade-color: #808080"></i>
            <span>No Data</span>
        `;
        div.appendChild(noDataItem);
        return div;
    };

    legend.addTo(map)

});