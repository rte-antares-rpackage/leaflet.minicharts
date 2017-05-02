// Copyright © 2016 RTE Réseau de transport d’électricité

/*
- data: Array with one element per time id. Each element has one element per minichart
        that contains data for this minichart.

*/
LeafletWidget.methods.addMinicharts = function(options, data, maxValues, colorPalette, timeLabels, initialTime, popup) {
  var layerManager = this.layerManager;

  // Initialize time slider
  var tslider;
  if (!this.controls._controlsById.tslider) {
    tslider = L.timeSlider({
      timeLabels: timeLabels,
      onTimeIdChange: function(timeId) {
        var charts = layerManager._byCategory.minichart;
        for (var k in charts) {
          charts[k].setTimeId(timeId);
        }
      }
    });
    this.controls.add(tslider, "tslider");
  } else {
    tslider = this.controls._controlsById.tslider;
    tslider.setTimeLabels(timeLabels);
  }

  var timeId = tslider.toTimeId(initialTime);
  tslider.setTimeId(timeId);

  // Add method to update time
  if (!L.Minichart.prototype.setTimeId) {
    L.Minichart.prototype.setTimeId = function(timeId) {
      if (timeId == this.timeId) return;

      if (typeof this.data !== "undefined" && typeof this.data[timeId] !== 'undefined') {
        this.setOptions({data: this.data[timeId]});
      }
      if (typeof this.popups !== "undefined" && typeof this.popups[timeId] !== 'undefined') {
        this.bindPopup(this.popups[timeId]);
      }
      this.timeId = timeId;
    };
  }

  // Create and add minicharts to the map
  for (var i = 0; i < options.lng.length; i++) {
    var opt = {};
    var inddata = [];
    for (var k in options) {
      if (options.hasOwnProperty(k)) opt[k] = options[k][i];
    }

    if (data) {
      for (var j = 0; j < data.length; j++) {
        inddata.push(data[j][i]);
      }

      opt.data = inddata[timeId];


      if (opt.data.length > 1) opt.labelText = null;
    }
    if (maxValues) opt.maxValues = maxValues;
    if (colorPalette) opt.colors = colorPalette;

    var l = L.minichart([options.lat[i], options.lng[i]], opt);

    // Keep a reference of colors and data for later use.
    l.fillColor = opt.fillColor || "blue";
    l.colorPalette = colorPalette || ["#1f77b4", "#ff7f0e", "#2ca02c", "#d62728", "#9467bd",
                                      "#8c564b", "e377c2", "#7f7f7f", "#bcbd22", "#17becf"];
    l.data = inddata;
    l.timeId = timeId;

    // Popups
    if (popup) {
      l.popups = [];
      for (var t = 0; t < popup.length; t++) {
        l.popups.push("" + popup[t][i]);
      }
      l.bindPopup(l.popups[timeId]);
    }

    var id = options.layerId ? options.layerId[i] : undefined;
    layerManager.addLayer(l, "minichart", id);
  }

};

LeafletWidget.methods.updateMinicharts = function(options, data, maxValues, colorPalette, timeLabels, initialTime, popup) {
  var tslider = this.controls._controlsById.tslider;
  if (typeof timeLabels != "undefined") tslider.setTimeLabels(timeLabels);

  var timeId;
  if (typeof initialTime != "undefined" && initialTime !== null) {
    console.log(initialTime);
    timeId = tslider.toTimeId(initialTime);
  } else {
    timeId = tslider.getTimeId();
  }
  tslider.setTimeId(timeId);

  for (var i = 0; i < options.layerId.length; i++) {
    var l = this.layerManager.getLayer("minichart", options.layerId[i]);

    var opt = {};
    for (var k in options) {
      if (options.hasOwnProperty(k)) opt[k] = options[k][i];
    }

    if (data) {
      l.data = [];
      for (var j = 0; j < data.length; j++) {
        l.data.push(data[j][i]);
      }

      opt.data = l.data[timeId];
    }

    if (maxValues) opt.maxValues = maxValues;

    if (popup) {
      l.popups = [];
      for (var t = 0; t < popup.length; t++) {
        l.popups.push("" + popup[t][i]);
      }

      l.bindPopup(l.popups[timeId]);
    }

    if (colorPalette) l.colorPalette = colorPalette;
    if (opt.fillColor) l.fillColor = opt.fillColor;
    if (l.data[0].length == 1) opt.colors = l.fillColor;
    else opt.colors = l.colorPalette;
    l.setOptions(opt);
  }

  if (typeof timeLabels != "undefined") {
    this.controls._controlsById.tslider.setTimeLabels(timeLabels);
  }
};

LeafletWidget.methods.removeMinicharts = function(layerId) {
  if (layerId.constructor != Array) layerId = [layerId];
  for (var i = 0; i < layerId.length; i++) {
    this.layerManager.removeLayer("minichart", layerId[i]);
  }
};

LeafletWidget.methods.clearMinicharts = function() {
  this.layerManager.clearLayers("minichart");
};
