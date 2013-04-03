function NSLog(data) {
    if (arguments.length === 1) {
        console.log("NSLog: ", data);
        bridgeJSON({"log":data});
    } else {
        console.log("NSLog: ", arguments);
        bridgeJSON({"log":arguments});
    }
}

function bridgeJSON(json) {
    var JSONString = JSON.stringify(json);
    var uri = "bridge://bridge#" + escape(JSONString);
    var iframe = document.createElement("IFRAME");
    iframe.setAttribute("src", uri);
    document.documentElement.appendChild(iframe);
    iframe.parentNode.removeChild(iframe);
    iframe = null;
}

var ListeningNYC = W.Object.extend({
    buildNumber : 1,
    constructor : function (options) {
        // events
        W.extend(this, W.EventMixin);
        // maps
        this.mapLoaded = false;
        this.allCartoLayer = undefined;
        this.likeonlyCartoLayer = undefined;
        this.dislikeonlyCartoLayer = undefined;
        this.map = undefined;
        // state
        this.queryType = null; // none, all, likeonly, dislikeonly
        this.mapCenter = new L.LatLng(40.714517, -74.005945); 
        this.latitude = this.mapCenter.lat;
        this.longitude = this.mapCenter.lng;
        this.zoom = 10;
        this.isTrackingEnabled = true;
        this.displayLocationCircle = true;
        this.debug = false;
        this.shouldConstrain = (options && options.shouldConstrain);
        this.mapBounds = new L.LatLngBounds([
            new L.LatLng(40.914031, -73.910522),
            new L.LatLng(40.752459, -73.701096), 
            new L.LatLng(40.502705, -74.258823),
            new L.LatLng(40.477248, -74.227924)
        ]);
                                   
        // load the carto css file
        var xhrRequest = new XMLHttpRequest();
        xhrRequest.open("GET", "carto.css");
        xhrRequest.onload = W.bind(function (progressEvent) {
            this.cartoCSS = progressEvent.currentTarget.responseText;
            this.createMapElement();
        }, this);
        xhrRequest.send();
    },
    createMapElement : function() {
        var mapOptions = {
            zoomControl: false,
            attributionControl: false
        };
        if (this.shouldConstrain) {
            NSLog("Constraigning");
            mapOptions.maxBounds = this.mapBounds;
        } else {
            NSLog("not constringing");
        }
        this.map = L.map('map', mapOptions);

        L.tileLayer('http://{s}.tile.cloudmade.com/10380a30d44f42e2b9ed814d8880e454/{styleId}/256/{z}/{x}/{y}.png', {
            attribution: "add artti",
            maxZoom: 18,
            styleId: 998 // 1714
        }).addTo(this.map);
        
        if (this.debug) {
            this.setQueryType("all");
        }

        this.map.on("dragstart", W.bind(function () {
            this.isTrackingEnabled = false;
        }, this));

        this.map.on("click", function () {
        });
                                   
        bridgeJSON({"event":"mapDidCreate"});
        NSLog("mapDidCreate");
        if (this.latitude !== undefined && this.longitude!== undefined  && this.zoom!== undefined ) {
            this.updateUserPosition(this.latitude, this.longitude, this.zoom);
        } else {
            NSLog("no at set");
            console.log(this);
        }
    },
    // bridge methods
    setZoom : function (zoom) {
        this.zoom = zoom;
        this.map.setZoom(this.zoom);
        NSLog("setting zoom to", this.zoom);
    },
    updateUserPosition : function (latitude, longitude, zoom) {
        NSLog("updating users position", latitude, longitude, zoom);
        if (latitude && longitude) {
            this.latitude = latitude;
            this.longitude = longitude;
        }
        var location = new L.LatLng(this.latitude, this.longitude);
        if (latitude && longitude && this.shouldConstrain) {
            if (!this.mapBounds.contains(location)) {
                this.isTrackingEnabled = false;
                if (zoom) {
                    this.map.setView(this.mapCenter, zoom);
                } else {
                    this.map.panTo(this.mapCenter);
                }
                NSLog("bailing");
                return;
            }
        }


        if (zoom) {
            this.zoom = zoom;
        }
        if (!this.map) {
            return;
        }
        if (this.isTrackingEnabled) {
            // NSLog("Tracking enable so setting view", latitude, longitude, zoom);
            if (zoom) {
                this.map.setView(location, zoom);
            } else {
                this.map.panTo(location);
            }
        } else {
            // NSLog("Tracking not enabled so not setting view", latitude, longitude, zoom);
        }
        if (!this.circle) {
            this.circle = L.circle(location, 3, {
                color: 'grey',
                fillColor: 'grey',
                fillOpacity: 0.5
            });
        } else {
            this.circle.setLatLng(location);
        }

        if (this.displayLocationCircle) {
            this.circle.addTo(this.map);
        }
        console.log("done updating location");
    },
    setQueryType : function (type) {
        if (type === this.queryType) { return; }
        this.queryType = type;
        NSLog("Should be updateing query type to:", this.queryType);

        if (this.queryType === "all") {
            if (this.likeonlyCartoLayer) { this.map.removeLayer(this.likeonlyCartoLayer); }
            if (this.dislikeonlyCartoLayer) { this.map.removeLayer(this.dislikeonlyCartoLayer); }
            console.log("switched to all");
            if (!this.allCartoLayer) {
                console.log("creating carto layer");
                this.allCartoLayer = new L.CartoDBLayer({
                    map: this.map,
                    user_name:'rossc1',
                    table_name: 'listeningnyc',
                    query: "SELECT * FROM {{table_name}} ORDER BY updated_at DESC",
                    //tile_style: this.cartoCSS,
                    interactivity: "feed_id",
                    featureClick: this.cartoFeatureClick,
                    featureOut: this.cartoFeatureOut,
                    featureOver: this.cartoFeatureOver,
                    auto_bound: false
                });
            }
            this.map.addLayer(this.allCartoLayer);
        } else if (this.queryType === "none") {
            if (this.allCartoLayer) { this.map.removeLayer(this.allCartoLayer); }
            if (this.likeonlyCartoLayer) { this.map.removeLayer(this.likeonlyCartoLayer); }
            if (this.dislikeonlyCartoLayer) { this.map.removeLayer(this.dislikeonlyCartoLayer); }
        } else if (this.queryType === "likeonly") {
            if (this.allCartoLayer) { this.map.removeLayer(this.allCartoLayer); }
            if (this.dislikeonlyCartoLayer) { this.map.removeLayer(this.dislikeonlyCartoLayer); }
            
            if (!this.likeonlyCartoLayer) {
                this.likeonlyCartoLayer = new L.CartoDBLayer({
                    map: this.map,
                    user_name:'rossc1',
                    table_name: 'listeningnyc',
                    query: "SELECT * FROM {{table_name}} WHERE likedislike > 0.5 ORDER BY updated_at DESC",
                    //tile_style: this.cartoCSS,
                    interactivity: "feed_id",
                    featureClick: this.cartoFeatureClick,
                    featureOut: this.cartoFeatureOut,
                    featureOver: this.cartoFeatureOver,
                    auto_bound: false
                });
            }
            this.map.addLayer(this.likeonlyCartoLayer);
        } else if (this.queryType === "dislikeonly") {
            if (this.allCartoLayer) { this.map.removeLayer(this.allCartoLayer); }
            if (this.likeonlyCartoLayer) { this.map.removeLayer(this.likeonlyCartoLayer); }

            if (!this.dislikeonlyCartoLayer) {
                this.dislikeonlyCartoLayer = new L.CartoDBLayer({
                    map: this.map,
                    user_name:'rossc1',
                    table_name: 'listeningnyc',
                    query: "SELECT * FROM {{table_name}} WHERE likedislike < 0.5 ORDER BY updated_at DESC",
                    //tile_style: this.cartoCSS,
                    interactivity: "feed_id",
                    featureClick: this.cartoFeatureClick,
                    featureOut: this.cartoFeatureOut,
                    featureOver: this.cartoFeatureOver,
                    auto_bound: false
                });
            }
            this.map.addLayer(this.dislikeonlyCartoLayer);
        }
    },
    setDisplayLocationCircle : function (yN) {
        if (this.displayLocationCircle === yN) {
            return;
        }
        this.displayLocationCircle = yN;
        if (this.circle) {
            if (this.displayLocationCircle) {
                this.circle.addTo(this.map);
            } else {
                this.map.removeLayer(this.circle);
            }
        } 
    },
    // get information
    getLocationString : function () {
        var latlng = this.map.getCenter();
        return latlng.lat + "," + latlng.lng;
    },
    // carto events
    cartoFeatureClick : function(ev, latlng, pos, data) {
        bridgeJSON({
            "event":"cartoFeatureClick",
            "data":data
        });
    },
    cartoFeatureOut : function() {},
    cartoFeatureOver : function(ev, latlng, pos, data) {}
});

// start up
function main() {
    bridgeJSON({"event":"main will execute"});
    if (window.location.hash === "#debug") {
        listeningNYC = new ListeningNYC();
        listeningNYC.updateUserPosition(51.5, 0, 8);
        listeningNYC.debug = true;
    } else {
        console.log("to use in browser add \"#debug\" to url and refresh.");

    }
    bridgeJSON({"event":"main did execute"});
}