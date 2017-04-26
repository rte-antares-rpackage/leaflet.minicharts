// Copyright © 2016 RTE Réseau de transport d’électricité

/*
- data: Array with one element per time id. Each element has one element per minichart
        that contains data for this minichart.

*/
LeafletWidget.methods.addMinicharts = function(options, data, maxValues, colorPalette, timeLabels) {
  var layerManager = this.layerManager;
  // Add method to update time
  if (!L.Minichart.prototype.setTimeId) {
    L.Minichart.prototype.setTimeId = function(timeId) {
      if (typeof this.data[timeId] !== 'undefined') {
        this.setOptions({data: this.data[timeId]});
        this.timeId = timeId;
      }
    };
  }

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

      opt.data = inddata[0];


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
    l.timeId = 0;

    if (options.popup) l.bindPopup(options.popup[i]);

    var id = options.layerId ? options.layerId[i] : undefined;
    layerManager.addLayer(l, "minichart", id);
    console.log(this);

  }

  var tslider = L.timeSlider({
    timeLabels: timeLabels,
    onTimeIdChange: function(timeId) {
      var charts = layerManager._byCategory.minichart;
      for (var k in charts) {
        charts[k].setTimeId(timeId);
      }
    }
  });
  this.controls.add(tslider, "tslider");

};

LeafletWidget.methods.updateMinicharts = function(options, data, maxValues, colorPalette) {
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

      opt.data = l.data[l.timeId];
    }

    if (maxValues) opt.maxValues = maxValues;

    if (options.popup) l.bindPopup(options.popup[i]);

    if (colorPalette) l.colorPalette = colorPalette;
    if (opt.fillColor) l.fillColor = opt.fillColor;
    if (l.data.length == 1) opt.colors = l.fillColor;
    else opt.colors = l.colorPalette;
    l.setOptions(opt);
  }
};
